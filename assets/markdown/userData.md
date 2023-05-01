# User Data

class UserData {
  var lazar = GenUser(email: 'lbonifant0@wikimedia.org', fullName: 'Lazar Bonifant', phone: '921-873-0343', plainPassword: 'FW8CQ4dw62Q8');
  var tersina = GenUser(email: 'tcawkill1@ezinearticles.com', fullName: 'Tersina Cawkill', phone: '709-763-6236');
  var madeline = GenUser(email: 'mlafont2@tripadvisor.com', fullName: 'Madeline Lafont', phone: '484-755-3978');
  var josh = GenUser(email: 'jbaume4@opera.com', fullName: 'Josh Baume', phone: '677-754-4230');
  var krystin = GenUser(email: 'kkienl5@redcross.org', fullName: 'Kyrstin Kienl', phone: '638-790-8994');
  var adriana = GenUser(email: 'ashephard6@soundcloud.com', fullName: 'Adriana Shephard', phone: '791-948-9879');
  var toiboid = GenUser(email: 'tabbatucci7@vistaprint.com', fullName: 'Toiboid Abbatucci', phone: '528-577-2072');
  var orelee = GenUser(email: 'ogregoretti8@last.fm', fullName: 'Orelee Gregoretti', phone: '651-874-3773');
  var yalonda = GenUser(email: 'ygair9@myspace.com', fullName: 'Yalonda Gair', phone: '908-985-1047');
  var test = GenUser(email: 'testuser@company.com', fullName: 'Test new user', phone: '223-453-7789');
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
}
