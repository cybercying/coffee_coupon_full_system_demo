/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class WidgetFinder {
  final bool skipOffstage;
  bool Function(Element candidate) matcher;
  Element Function(Element)? elementGetter;

  WidgetFinder({ this.skipOffstage = true, required this.matcher, this.elementGetter});

  Iterable<Element> apply(Iterable<Element> candidates) {
    return candidates.where(matcher);
  }

  Iterable<Element> collectAllElementsFrom(
      Element rootElement, {
        required bool skipOffstage,
      }) {
    return CachingIterable<Element>(_DepthFirstChildIterator(rootElement, skipOffstage));
  }

  Iterable<Element> get allCandidates {
    return collectAllElementsFrom(
      WidgetsBinding.instance.renderViewElement!,
      skipOffstage: skipOffstage,
    );
  }

  Iterable<Element>? _cachedResult;

  Iterable<Element> evaluate() {
    final Iterable<Element> result = _cachedResult ?? apply(allCandidates);
    _cachedResult = null;
    return result;
  }

  bool precache() {
    assert(_cachedResult == null);
    final Iterable<Element> result = apply(allCandidates);
    if (result.isNotEmpty) {
      _cachedResult = result;
      return true;
    }
    _cachedResult = null;
    return false;
  }
}

Element elementGetterOfAncestorIsType<T extends Widget>(Element element) {
  Element found = element;
  element.visitAncestorElements((element) {
    if (element.widget is T) {
      found = element;
      return false;
    }
    return true;
  });
  return found;
}

abstract class WidgetMatcher {
  bool call(Element candidate);
}

class KeyMatcher extends WidgetMatcher {
  Key key;
  KeyMatcher({required this.key});
  @override
  bool call(Element candidate) {
    return candidate.widget.key == key;
  }
}

class TypeMatcher extends WidgetMatcher {
  final Type type;
  TypeMatcher({required this.type});
  @override
  bool call(Element candidate) {
    return candidate.widget.runtimeType == type;
  }
}

class _DepthFirstChildIterator implements Iterator<Element> {
  _DepthFirstChildIterator(Element rootElement, this.skipOffstage) {
    _fillChildren(rootElement);
  }

  final bool skipOffstage;

  late Element _current;

  final List<Element> _stack = <Element>[];

  @override
  Element get current => _current;

  @override
  bool moveNext() {
    if (_stack.isEmpty) {
      return false;
    }

    _current = _stack.removeLast();
    _fillChildren(_current);

    return true;
  }

  void _fillChildren(Element element) {
    final List<Element> reversed = <Element>[];
    if (skipOffstage) {
      element.debugVisitOnstageChildren(reversed.add);
    } else {
      element.visitChildren(reversed.add);
    }
    while (reversed.isNotEmpty) {
      _stack.add(reversed.removeLast());
    }
  }
}

TargetPosition getWidgetPosition(WidgetFinder finder, {bool? forcedGlobal = false}) {
  var element = finder.evaluate().single;
  if (finder.elementGetter != null) {
    element = finder.elementGetter!(element);
  }
  try {
    final RenderBox renderBoxRed = element.findRenderObject() as RenderBox;
    final size = renderBoxRed.size;
    Offset offset;
    BuildContext? context;
    if (!(forcedGlobal ?? false)) {
      context = element.findAncestorStateOfType<NavigatorState>()?.context;
    }
    if (context != null) {
      offset = renderBoxRed.localToGlobal(Offset.zero,
          ancestor: context.findRenderObject());
    } else {
      offset = renderBoxRed.localToGlobal(Offset.zero);
    }
    return TargetPosition(size, offset);
  } catch (e) {
    throw NotFoundTargetException();
  }
}

Future<bool> waitWidgetToAppear(WidgetFinder finder, {
      singleWait = const Duration(milliseconds: 100),
      timeout = const Duration(seconds: 5)
  }) async {
  var totalWait = Duration.zero;
  while(totalWait < timeout) {
    await Future.delayed(singleWait);
    if (finder.evaluate().isNotEmpty) {
      return true;
    }
    totalWait += totalWait + singleWait;
  }
  return false;
}

class GestureSimulator {
  final WidgetsBinding binding;

  GestureSimulator({required this.binding});

  factory GestureSimulator.create() {
    return GestureSimulator(binding: WidgetsBinding.instance);
  }

  Future<void> tap(WidgetFinder finder, {int? pointer, int buttons = kPrimaryButton}) async {
    var widgetPosition = getWidgetPosition(finder, forcedGlobal: true);
    return tapAt(widgetPosition.center, pointer: pointer, buttons: buttons);
  }

  Future<void> tapAt(Offset location, {int? pointer, int buttons = kPrimaryButton}) async {
    final SimulatedGesture gesture = await startGesture(location, pointer: pointer, buttons: buttons);
    await gesture.up();
  }

  Future<SimulatedGesture> startGesture(
      Offset downLocation, {
        int? pointer,
        PointerDeviceKind kind = PointerDeviceKind.touch,
        int buttons = kPrimaryButton,
      }) async {
    final SimulatedGesture result = await createGesture(
      pointer: pointer,
      kind: kind,
      buttons: buttons,
    );
    await result.down(downLocation);
    return result;
  }

  Future<SimulatedGesture> createGesture({
    int? pointer,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int buttons = kPrimaryButton,
  }) async {
    return SimulatedGesture(
      dispatcher: sendEventToBinding,
      kind: kind,
      pointer: pointer ?? _getNextPointer(),
      buttons: buttons,
    );
  }

  Future<void> sendEventToBinding(PointerEvent event) async {
    binding.handlePointerEvent(event);
  }

  int get nextPointer => _nextPointer;

  static int _nextPointer = 1;

  static int _getNextPointer() {
    final int result = _nextPointer;
    _nextPointer += 1;
    return result;
  }
}

typedef EventDispatcher = Future<void> Function(PointerEvent event);

class SimulatedGesture {
  SimulatedGesture({
    required EventDispatcher dispatcher,
    int pointer = 1,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int? device,
    int buttons = kPrimaryButton,
  }) : _dispatcher = dispatcher,
        _pointer = TestPointer(pointer, kind, device, buttons);

  Future<void> up({ Duration timeStamp = Duration.zero }) async {
    await _dispatcher(_pointer.up(timeStamp: timeStamp));
  }

  Future<void> down(Offset downLocation, { Duration timeStamp = Duration.zero }) async {
    return _dispatcher(_pointer.down(downLocation, timeStamp: timeStamp));
  }

  Future<void> downWithCustomEvent(Offset downLocation, PointerDownEvent event) async {
    _pointer.setDownInfo(event, downLocation);
    return _dispatcher(event);
  }

  final EventDispatcher _dispatcher;
  final TestPointer _pointer;

  @visibleForTesting
  Future<void> updateWithCustomEvent(PointerEvent event, { Duration timeStamp = Duration.zero }) {
    _pointer.setDownInfo(event, event.position);
    return _dispatcher(event);
  }

  Future<void> addPointer({ Duration timeStamp = Duration.zero, Offset? location }) {
    return _dispatcher(_pointer.addPointer(timeStamp: timeStamp, location: location ?? _pointer.location));
  }

  Future<void> removePointer({ Duration timeStamp = Duration.zero, Offset? location }) {
    return _dispatcher(_pointer.removePointer(timeStamp: timeStamp, location: location ?? _pointer.location));
  }

  Future<void> moveBy(Offset offset, { Duration timeStamp = Duration.zero }) {
    return moveTo(_pointer.location! + offset, timeStamp: timeStamp);
  }

  Future<void> moveTo(Offset location, { Duration timeStamp = Duration.zero }) {
    if (_pointer._isDown) {
      return _dispatcher(_pointer.move(location, timeStamp: timeStamp));
    } else {
      return _dispatcher(_pointer.hover(location, timeStamp: timeStamp));
    }
  }

  Future<void> cancel({ Duration timeStamp = Duration.zero }) async {
    await _dispatcher(_pointer.cancel(timeStamp: timeStamp));
  }
}

class TestPointer {
  TestPointer([
    this.pointer = 1,
    this.kind = PointerDeviceKind.touch,
    int? device,
    int buttons = kPrimaryButton,
  ]) : _buttons = buttons {
    switch (kind) {
      case PointerDeviceKind.mouse:
        _device = device ?? 1;
        break;
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
      case PointerDeviceKind.touch:
      case PointerDeviceKind.trackpad:
      case PointerDeviceKind.unknown:
        _device = device ?? 0;
        break;
    }
  }

  /// The device identifier used for events generated by this object.
  ///
  /// Set when the object is constructed. Defaults to 1 if the [kind] is
  /// [PointerDeviceKind.mouse], and 0 otherwise.
  int get device => _device;
  late int _device;

  /// The pointer identifier used for events generated by this object.
  ///
  /// Set when the object is constructed. Defaults to 1.
  final int pointer;

  /// The kind of pointing device to simulate. Defaults to
  /// [PointerDeviceKind.touch].
  final PointerDeviceKind kind;

  /// The kind of buttons to simulate on Down and Move events. Defaults to
  /// [kPrimaryButton].
  int get buttons => _buttons;
  int _buttons;

  /// Whether the pointer simulated by this object is currently down.
  ///
  /// A pointer is released (goes up) by calling [up] or [cancel].
  ///
  /// Once a pointer is released, it can no longer generate events.
  bool get isDown => _isDown;
  bool _isDown = false;

  /// Whether the pointer simulated by this object currently has
  /// an active pan/zoom gesture.
  ///
  /// A pan/zoom gesture begins when [panZoomStart] is called, and
  /// ends when [panZoomEnd] is called.
  bool get isPanZoomActive => _isPanZoomActive;
  final bool _isPanZoomActive = false;

  /// The position of the last event sent by this object.
  ///
  /// If no event has ever been sent by this object, returns null.
  Offset? get location => _location;
  Offset? _location;


  /// The pan offset of the last pointer pan/zoom event sent by this object.
  ///
  /// If no pan/zoom event has ever been sent by this object, returns null.
  Offset? get pan => _pan;
  Offset? _pan;

  /// If a custom event is created outside of this class, this function is used
  /// to set the [isDown].
  bool setDownInfo(
      PointerEvent event,
      Offset newLocation, {
        int? buttons,
      }) {
    _location = newLocation;
    if (buttons != null) {
      _buttons = buttons;
    }
    switch (event.runtimeType) {
      case PointerDownEvent:
        assert(!isDown);
        _isDown = true;
        break;
      case PointerUpEvent:
      case PointerCancelEvent:
        assert(isDown);
        _isDown = false;
        break;
      default:
        break;
    }
    return isDown;
  }

  /// Create a [PointerDownEvent] at the given location.
  ///
  /// By default, the time stamp on the event is [Duration.zero]. You can give a
  /// specific time stamp by passing the `timeStamp` argument.
  ///
  /// By default, the set of buttons in the last down or move event is used.
  /// You can give a specific set of buttons by passing the `buttons` argument.
  PointerDownEvent down(
      Offset newLocation, {
        Duration timeStamp = Duration.zero,
        int? buttons,
      }) {
    assert(!isDown);
    assert(!isPanZoomActive);
    _isDown = true;
    _location = newLocation;
    if (buttons != null) {
      _buttons = buttons;
    }
    return PointerDownEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: _device,
      pointer: pointer,
      position: location!,
      buttons: _buttons,
    );
  }

  PointerMoveEvent move(
      Offset newLocation, {
        Duration timeStamp = Duration.zero,
        int? buttons,
      }) {
    assert(
    isDown,
    'Move events can only be generated when the pointer is down. To '
        'create a movement event simulating a pointer move when the pointer is '
        'up, use hover() instead.');
    assert(!isPanZoomActive);
    final Offset delta = newLocation - location!;
    _location = newLocation;
    if (buttons != null) {
      _buttons = buttons;
    }
    return PointerMoveEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: _device,
      pointer: pointer,
      position: newLocation,
      delta: delta,
      buttons: _buttons,
    );
  }

  PointerUpEvent up({ Duration timeStamp = Duration.zero }) {
    assert(!isPanZoomActive);
    assert(isDown);
    _isDown = false;
    return PointerUpEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: _device,
      pointer: pointer,
      position: location!,
    );
  }

  PointerCancelEvent cancel({ Duration timeStamp = Duration.zero }) {
    assert(isDown);
    _isDown = false;
    return PointerCancelEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: _device,
      pointer: pointer,
      position: location!,
    );
  }

  PointerAddedEvent addPointer({
    Duration timeStamp = Duration.zero,
    Offset? location,
  }) {
    _location = location ?? _location;
    return PointerAddedEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: _device,
      position: _location ?? Offset.zero,
    );
  }

  PointerRemovedEvent removePointer({
    Duration timeStamp = Duration.zero,
    Offset? location,
  }) {
    _location = location ?? _location;
    return PointerRemovedEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: _device,
      pointer: pointer,
      position: _location ?? Offset.zero,
    );
  }

  PointerHoverEvent hover(
      Offset newLocation, {
        Duration timeStamp = Duration.zero,
      }) {
    assert(
    !isDown,
    'Hover events can only be generated when the pointer is up. To '
        'simulate movement when the pointer is down, use move() instead.');
    final Offset delta = location != null ? newLocation - location! : Offset.zero;
    _location = newLocation;
    return PointerHoverEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: _device,
      pointer: pointer,
      position: newLocation,
      delta: delta,
    );
  }
}
