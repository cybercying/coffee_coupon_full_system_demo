/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'images.dart';
import 'protocol.dart';

class UserData {
  var brynn = GenUser(email: 'bstollenbergd@youtube.com', fullName: 'Brynn Stollenberg', phone: '465-518-8326', plainPassword: 'kzg2PVB9AgfZ', fAdmin: true);
  var lazar = GenUser(email: 'lbonifant0@wikimedia.org', fullName: 'Lazar Bonifant', phone: '921-873-0343', plainPassword: 'FW8CQ4dw62Q8');
  var tersina = GenUser(email: 'tcawkill1@ezinearticles.com', fullName: 'Tersina Cawkill', phone: '709-763-6236', plainPassword: '2TEdeFadXL5B');
  var madeline = GenUser(email: 'mlafont2@tripadvisor.com', fullName: 'Madeline Lafont', phone: '484-755-3978', plainPassword: 'wbE54CFSsATu');
  var josh = GenUser(email: 'jbaume4@opera.com', fullName: 'Josh Baume', phone: '677-754-4230', plainPassword: 'FCW7w2VMcDr2');
  var krystin = GenUser(email: 'kkienl5@redcross.org', fullName: 'Kyrstin Kienl', phone: '638-790-8994', plainPassword: 'dFRg5reWqmNv');
  var adriana = GenUser(email: 'ashephard6@soundcloud.com', fullName: 'Adriana Shephard', phone: '791-948-9879', plainPassword: 'cpcjH7j3AkGu');
  var toiboid = GenUser(email: 'tabbatucci7@vistaprint.com', fullName: 'Toiboid Abbatucci', phone: '528-577-2072', plainPassword: 'T6vxtqHX2rxA');
  var orelee = GenUser(email: 'ogregoretti8@last.fm', fullName: 'Orelee Gregoretti', phone: '651-874-3773', plainPassword: '8GgJ43ZjtbV8');
  var yalonda = GenUser(email: 'ygair9@myspace.com', fullName: 'Yalonda Gair', phone: '908-985-1047', plainPassword: 'bS4azEENVnh4');
  var test = GenUser(email: 'testuser@company.com', fullName: 'Test new user', phone: '223-453-7789', plainPassword: 'XqrLYV4ehL28');
  getList() {
    return [brynn, lazar, tersina, madeline, josh, krystin, adriana, toiboid, orelee, yalonda];
  }
}

class GuestData {
  var missy = GenGuest(fullName: 'Missy Yu', phone: '602-669-0963', birthday: DateTime.parse("1989-01-01"), gender: Gender.female, email: 'myu3@buzzfeed.com');
  var mikael = GenGuest(fullName: 'Mikael Norquoy', phone: '502-973-3040', birthday: DateTime.parse('1978-07-16'), gender: Gender.male, email: 'mnorquoy0@fema.gov');
  var elliott = GenGuest(fullName: 'Elliott Bowshire', phone: '641-841-3045', birthday: DateTime.parse('1991-02-11'), gender: Gender.male, email: 'ebowshire1@vk.com');
  var gavan = GenGuest(fullName: 'Gavan Runham', phone: '197-280-8718', birthday: DateTime.parse('2004-04-06'), gender: Gender.male, email: 'grunham2@marketwatch.com');
  var ritchie = GenGuest(
    fullName: 'Ritchie Johananov',
    phone: '225-885-3598',
    birthday: DateTime.parse('2004-01-25'),
    gender: Gender.male,
    email: 'rjohananov3@tripadvisor.com',
    plainPassword: 'JACZQp7vXbkE'
  );
  var haskell = GenGuest(fullName: 'Haskell Robbs', email: 'hrobbse@washington.edu', phone: '511-174-4052', birthday: DateTime.parse('1981-12-21'), gender: Gender.male);
  var shawn = GenGuest(fullName: 'Shawn Timmis', phone: '912-406-6599', birthday: DateTime.parse("1985-04-05"), gender: Gender.male, email: 'stimmisj@foxnews.com');
}

class StoreData {
  var dynazzy = GenStore(
      name: 'Dynazzy',
      address: '145 Goodland Court',
      phone: '410-245-5778',
      imageUrl: imageDefinitions.coffeeShop.imageList[0],
  );
  var zoonoodle = GenStore(
      name: 'Zoonoodle',
      address: '1161 Sachs Point',
      phone: '146-859-1141',
      imageUrl: imageDefinitions.coffeeShop.imageList[1],
  );
  var centidel = GenStore(
      name: 'Centidel',
      address: '63238 Vidon Lane',
      phone: '812-304-8058',
      imageUrl: imageDefinitions.coffeeShop.imageList[2],
  );
}

List<GenRedeemPolicy> getRedeemPolicies() {
  var drinks = imageDefinitions.drinks;
  int drinksIdx = 0;
  var coffee = imageDefinitions.coffee;
  int coffeeIdx = 0;
  return [
    GenRedeemPolicy(
      title: "Espresso",
      description: "The espresso, also known as a short black, is approximately 1 oz. of highly concentrated coffee. Although simple in appearance, it can be difficult to master.",
      pointsRequired: 2,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Double Espresso",
      description: "A double espresso may also be listed as doppio, which is the Italian word for double. This drink is highly concentrated and strong.",
      pointsRequired: 3,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Red Eye",
      description: "The red eye's purpose is to add a boost of caffeine to your standard cup of coffee.",
      pointsRequired: 3,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Americano",
      description: "Americanos are popular breakfast drinks and thought to have originated during World War II. Soldiers would add water to their coffee to extend their rations farther. The water dilutes the espresso while still maintaining a high level of caffeine.",
      pointsRequired: 1,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Macchiato",
      description: "The word macchiato means mark or stain. This is in reference to the mark that steamed milk leaves on the surface of the espresso as it is dashed into the drink. Flavoring syrups are often added to the drink according to customer preference.",
      pointsRequired: 3,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Long Macchiato",
      description: "Often confused with a standard macchiato, the long macchiato is a taller version and will usually be identifiable by its distinct layers of coffee and steamed milk.",
      pointsRequired: 3,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Cappuccino",
      description: "This creamy coffee drink is usually consumed at breakfast time in Italy and is loved in the United States as well. It is usually associated with indulgence and comfort because of its thick foam layer and additional flavorings that can be added to it.",
      pointsRequired: 3,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Cafe Latte",
      description: "Cafe lattes are considered an introductory coffee drink since the acidity and bitterness of coffee are cut by the amount of milk in the beverage. Flavoring syrups are often added to the latte for those who enjoy sweeter drinks.",
      pointsRequired: 3,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Mocha",
      description: "The mocha is considered a coffee and hot chocolate hybrid. The chocolate powder or syrup gives it a rich and creamy flavor and cuts the acidity of the espresso.",
      pointsRequired: 3,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Affogato",
      description: "Affogatos are more for a dessert coffee than a drink you would find at a cafe, but they can add a fun twist to your coffee menu. They are made by pouring a shot of espresso over a scoop of vanilla ice cream to create a sweet after-meal treat.",
      pointsRequired: 4,
      imageUrl: coffee.imageList[coffeeIdx++],
    ),
    GenRedeemPolicy(
      title: "Club Strawberry Margarita",
      description: "Premixed cocktail that combines tequila and triple sec with natural strawberry flavors. Ready to serve - no mixing needed. Enjoy over ice or serve chilled, straight from the fridge or cooler.",
      pointsRequired: 5,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Bacardi Zombie",
      description: "Pre-mixed cocktail that combines Bacardi rum (including some 151) with apricot brandy, orange, pineapple and lime juice for a traditional Zombie cocktail. All the flavor without the high proof - 25 proof (the origiinal drink called for almost 4 ounces of liquor).",
      pointsRequired: 5,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Bacardi Bahama Mama",
      description: "Premixed cocktail that combines a blend of Bacardi rums with exotic tropical fruit flavors (peach, orange, coconut, pineapple, tropical punch and grapefruit). Just pour over ice or add ice and blend.",
      pointsRequired: 5,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Barton Long Island Iced Tea",
      description: "Premixed cocktail that contains all the liquors in a traditional Long Island Iced Tea - rum, gin, vodka, tequila and triple sec. Geared to the on-premise customers (though it can certainly be used for take- home entertaining as well) who are looking for a quick and consistent way to make the famous drink. Pour 2 oz Barton's Long Island Iced Tea into a tall glass filled with ice, add sour mix, shake and top with cola. Or for a different twist, add 7-Up instead of cola and add a splash of cranberry juice for a 'Cosmopolitan Iced Tea' (you can decrease the ingredients and serve straight up in a martini glass garnished with a lime, if you would like).",
      pointsRequired: 10,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Ice Box Mudslide",
      description: "Pre-mixed cocktail made with real cream and neutral spirits. Flavors of coffee brandy and Irish Cream liqueur. No blender needed, can be served on the rocks or chilled.",
      pointsRequired: 5,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Kahlua Frozen Mudslide",
      description: "Ready to drink cocktail inspired by the popular frozen drink made with Kahlua, Irish Cream and Vodka. Made with a non-dairy base. 12.5% alcohol or 25 proof. Has a nine months shelf life. Makes 18 drinks. Serve over ice or blended.",
      pointsRequired: 5,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Skinnygirl White Peach Margarita",
      description: "Premixed white peach margarita cocktail made with tequila, agave sweetener (lower in calories and all natural), triple sec and white peach flavors. Skinnygirl uses white peach because it will not stain clothes or furnishings. All natural and low calorie, with only 105 calories per ounce serving. Developed by TV star Bethanny Frankel ('Real Housewives of NYC'). Serve over ice or blend with ice for a frozen peach margarita.",
      pointsRequired: 5,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Jose Cuervo Authentic Light Margarita",
      description: "Ready to serve, premixed cocktail that combines Jose Gold Tequila with triple sec and natural lime flavors for a classic margarita - only this one has just 100 calories per serving ( I won't tell you how many calories a regular Margarita has - let's just say there are more than twice as many in the regular drink). Serve over ice in a salt-rimmed glass, or add ice and blend for a refreshing frozen drink.",
      pointsRequired: 10,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "Chi-Chi's Margarita",
      description: "Pre-mixed cocktail that combines tequila, triple sec (orange flavors), and lime juice for a traditional margarita.",
      pointsRequired: 10,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
    GenRedeemPolicy(
      title: "T.G.I. Friday's Long Island Iced Tea",
      description: "Pre-mixed cocktail that combines white spirits with lemon juice, sugar and cola.",
      pointsRequired: 3,
      imageUrl: drinks.imageList[drinksIdx++],
    ),
  ];
}
