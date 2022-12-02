# CS329E-Project (Homebase App)
## Project Team 19 - App for CS329E Mobile Computing

Team Members: Dominic Galiano, Ray Zhang, Hans Wang, Adrian Cruz

Swift Version: 5.7  
Xcode Version: 14.0.1 (14A400)  
Dependencies: Firebase 9.0.0  
iPhone Model: iPhone 14 Pro Max  

Testing Instructions:

- Start by creating an account using your first and last name as well as email and chosen password.
- If you already have an account, you can also just sign in.
- Or if you have an account and forgot the password, you can reset your password from the first screen. This button will send you an email to reset your password.
- Initially, you will not be a member of any group. You must first create a new group or join an existing group.
- To create a new group, select “Create Group” and input a group name and identifier. This identifier can be shared with other users to allow them to join your group Then press “Create Group”
- You can also access your event schedule from the previous screen. You will need to give permission for Homebase to use your calendar. Long press or select “Add Event” to create a new event. You can edit if you tap on it.
- You can also join an existing group by selecting the “Join Group” button. Enter the group identifier of the group you want to join if you have it, or use the scanner to scan the group QR code.
- If you are already in a group, you can just select it from the main screen.
- The settings icon will take you to the individual settings page. From here you can change your profile picture using your camera or photo library. You can also request that a change password email is sent to you. Additionally, there are settings to toggle dark mode, notifications, and notification delay. Finally, you can log out or delete your account entirely from this screen.
- From the group page, you can add a message to the group members. This message can be tapped on to create a notification for yourself. You will need to give notification permission for this functionality to work.
- From the shopping list page, you can add items to a collective shopping list. “Add item” will add an item to the shopping list. You can check off items by tapping on them. You can then delete all checked items or all items or individual items by swiping left on them.
- From the inventory page, you can keep track of commonly purchased items. Add an item using the “add item” button. You can then add the inventory item to the shopping list by tapping on it. You can also delete inventory items by swiping left on them.
- From the group page, if you tap the gear icon you will go to the group settings page. From here you can see your group members, group ID, group ID QR code, and also leave the group. You can also change the group name.


Features checklist:  

- [X] Login/register path
- [X] Settings with three behaviors that can be modified by user
- [X] Non-default fonts, colors and styles

Major Elements:  

- [X] Use of Core Data/Firebase 
- [X] Implementation of user profile path, incl. creation, taking a pic or selecting prexisting, and editing

Minor Elements:  

- [X] At least two of text views, sliders, segemented controllers, date or color pickers, steppers, **switches**, search fields, **bars and bar buttons**, etc.
- [X] Table View
- [X] Two of the following: Alerts, Popovers, Stack Views, Scroll Views, Haptics, User Defaults
- [X] Local notifications
- [X] Animation
- [X] Calendar
- [X] QR Code
