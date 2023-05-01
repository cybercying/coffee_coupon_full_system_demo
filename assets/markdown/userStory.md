# User story

**NOTE! For obvious reasons, all data and facts described in this story are fictional. They are merely used to illustrate the demo. Also, due to resource constraints, the story is only available in English version.**

---
## The coffee chain
A coffee chain named **"Barista Mill"** wants to create a coupon system to reward repeat customers. IT manager **Brynn Stollenberg** will develop such a system and will be assumed the role of the system administrator. There are currently three branch stores. Their names are **Dynazzy, Zoonoodle, and Centidel**:
1. In store **Dynazzy**, the manager is **Lazar Bonifant**, while the staff are **Tersina Cawkill** and **Madeline Lafont**.
2. In store **Zonoodle**, the manager is **Madeline Lafont**, while the staff are **Josh Baume, Kyrstin Kienl, Adriana Shephard**, and **Tersina Cawkill**.
3. In store **Centidel**, managers are **Toiboid Abbatucci** and **Orelee Gregoretti**, while the staff are **Yalonda Gair, Adriana Shephard**, and **Madeline Lafont**.

## Management delegation
**Brynn**, the administrator, would like to delegate some of the user management tasks to store managers because he doesn't know everyone in every store. Thus, managers of each store are allowed to manage (create, delete update, query) users in that store. Of course, before any of this, **Brynn** has to create the store data record and assign at least one user to it to assume the manager role by using the **Admin APP**.

## Guest registration
When a guest pay for something in a store, the staff will ask if he or she wants to become a member of **Barista Mill** to collect points. If a guest chooses to become a member, the staff will direct the guest to download **Guest APP** and perform account registration. The **Guest APP** will first ask for the guest's phone number to verify identity by SMS. Then the **Guest APP** will require some basic data, including name, Email, birthday, and gender. These data might prove to be useful for future marketing purposes.

## Gift points
After the guest creates an account, the staff will give a certain number of points according to store rules (not included in the demo) to the guest. This is done by the staff designating a number of points in the **Admin APP**, and then asking the guest to show a 2D barcode using the **Guest APP** to scan it. If the transaction is successful, a record will be saved in the server for audit purposes.

## Coupon-redeem
**Brynn** will define a list of chain-wide coupon-redeem policies. For example, an Espresso will require 2 points, and a Double Espresso will require 3 points. When a guest with a sufficient number of points to redeem something according to the policies, he or she will come to a store and ask the staff to redeem it. If a such drink or item is available, the staff will ask the guest to choose exactly which coupon-redeem policy to be used. The **Guest APP** will then generate a 2D barcode for the staff to scan using **Admin APP**. If the transaction is successful, a record will be saved in the server for audit purposes, and the number of points will be deducted from the guest's account.