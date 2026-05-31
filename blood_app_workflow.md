# 🩸 Blood Donation App - Workflow Summary

## 1. Registration aur Signup
- **Splash Screen:** Sab se pehli screen.
- **Signup Options:** Do options honge: **Signup As A Donor** ya **Signup As A Recipient**.
    - **Donor Profile:** Profile Pic, Name, Username, Email, Phone, Blood Group, City, Password.
    - **Recipient Profile:** Profile Pic, Name, Username, Email, City (Dropdown - optional), Password.

## 2. Login aur Dual Mode
- **Login Screen:** Do buttons honge (**Login as Donor** / **Login as Recipient**).
- **Dual Mode:** Jo Donor hai woh login ke waqt Recipient select kar ke Recipient wala dashboard bhi use kar sakta hai (kyun ke donor ko bhi blood ki zaroorat par sakti hai).

## 3. Recipient Flow (Blood Ki Talash)
- **Home Page:** Blood groups ke cards (A+, B+, A-, B-, O+, O-, AB+, AB-) nazar aayenge.
- **Selection:** Blood group select karne par "Search Donor for [Group]" screen khule gi.
- **City Search:** Search bar mein City (e.g., Bahawalpur) likhne par us shehar ke us group ke saare registered donors show honge.
- **Donor Details:** Donor par click karne se uski details (Name, Username, City, Blood Group) show hongi.
- **Send Request Form:** "Send A Request" button click karne par ek form khule ga:
    - Hospital Name, Patient Name, Blood Kitni Dair Tak Chahye (1 Hour, 2 Hours, etc.), aur Message Box.
- **Request State:** Request "Pending" mein chali jaye gi.
- **Limits:** Ek waqt mein 10 requests send ho sakti hain. Agar 5 accept ho gayin to baaki automatically cancel ho jayengi ("Request Full Filled").

## 4. Donor Flow (Blood Dena)
- **Availability:** Donor apni availability status (Online/Offline) bata sake ga.
- **Request Management:** Donor ke paas nayi requests aayengi jinhe woh **Accept** ya **Reject** kar sake ga.

## 5. History aur Timer Logic
- **History Management:** 4 buttons/statuses honge: **Pending, Accepted, Rejected, Cancelled**.
- **Countdown Timer:** Jab request send hogi, to select kiye gaye time ka backward timer start ho jayega dono taraf.
- **Timeout:** Agar time khatam hone tak Donor accept/reject nahi karta, to request khud-ba-khud "Cancelled" (Timeout) ho jaye gi.
- **Acceptance:** Accept hone par hi Donor aur Recipient ko ek doosre ki contact details (Phone Number) show honge.

## 6. Profile Management
- **Editable:** Profile Pic, Name, aur Password (password change karne ke liye purana password dena hoga).
- **Non-Editable:** Email aur Username sirf show honge, change nahi ho saken ge.

## 7. Admin Side
- **Dashboard:** Total Users, Donors, aur Recipients dekh sakta hai.
- **Cities:** Nayi cities add kar sakta hai.
- **Request Tracking:** Dekh sakta hai kisne kisko request send ki.
- **User History:** Har user ki individual details (kitni requests send ki, kitni accept/reject huin) dekh sakta hai.
