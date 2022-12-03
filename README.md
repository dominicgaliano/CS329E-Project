# CS329E-Project (Homebase App)
## Project Team 19 - App for CS329E Mobile Computing

Team Members: Dominic Galiano, Ray Zhang, Hans Wang, Adrian Cruz

Swift Version: 5.7  
Xcode Version: 14.0.1 (14A400)  
Dependencies: Firebase 9.6.0, CalendarKit 1.1.6
iPhone Model: iPhone 14 Pro Max  

Testing Instructions:

- Start by creating an account using your first and last name as well as email and chosen password.
- If you already have an account, you can just sign in.
- If you have an account and forgot the password, you can reset your password from the first screen. This button will send you an email to reset your password.
- Initially, you will not be a member of any group. You must first create a new group or join an existing group.
- To create a new group, select “Create Group” and input a group name and identifier. This identifier can be shared with other users to allow them to join your group. After you have input the desired group name and identifier, press “Create Group”
- From the Group Selector View Controller, you are also able to access the Event Schedule. You will need to give permission for Homebase to use your calendar. Long press or select “Add Event” to create a new event. Tap edit or delete an event, tap on it. An alternative method of creating an event is using the "Add Event" button on the top right. 
- To join an existing group, select the “Join Group” button. Enter the group identifier of the group you want to join if you have it, or use the scanner to scan the group QR code.
- If you are already in a group, you can select it from the main screen.
- The icon on the top right of the "Group Selector" view controller will take you to the "Individual Settings" page. From here you can change your profile picture using your camera or photo library. You can also request that a change password email is sent to you. Additionally, there are settings to toggle dark mode, notifications, and notification delay. Finally, you can log out or delete your account entirely from this screen.
- From the group page, you can send a message to the other members in your group. This message can be tapped on to create a notification for yourself. You will need to give notification permission for this functionality to work.
- From the shopping list page, you can add items to a collective shopping list. “Add item” will add an item to the shopping list. You can check off items by tapping on them. You can then delete all checked items using the "Remove all Checkmarks" button. To remove all items use the "Remove all items" button. To remove individual items, use a left swipe on the item to be deleted.  
- From the inventory page, you can keep track of commonly purchased items. Add an item using the “add item” button. You can then add the inventory item to the shopping list by tapping on it. You can also delete inventory items by swiping left on them.
- From the group page, if you tap the gear icon you will go to the group settings page. From here you can see your group members, group ID, group ID QR code, and also leave the group. You can change the group name by tapping on the pencil icon near the top and inputting the name you want to change your group to. 


Required Features Checklist:  

- [X] Login/register path
- [X] Settings with three behaviors that can be modified by user. We implemented: Dark Mode, Notifications, and Notification Delay settings
- [X] Non-default fonts, colors and styles. For the font, we used "American Typewriter". We used System Green for the color of our buttons. 

Major Elements:  

- [X] Use of Core Data/Firebase 
- [X] Implementation of user profile path, incl. creation, taking a pic or selecting prexisting, and editing

Minor Elements:  

- [X] At least two of text views, sliders, segemented controllers, date or color pickers, steppers, **switches**, search fields, **bars and bar buttons**, etc. We used switches and bars/bar buttons
- [X] Table View
- [X] Two of the following: Alerts, Popovers, Stack Views, Scroll Views, Haptics, User Defaults
- [X] Local notifications
- [X] Animation - The animation is displayed whenever certain view controllers are taking a longer period of time to load. The animation has a loading symbol that spins. 
- [X] Calendar - The calendar is implemented as an event scheduler that can be used to plan certain events or chores that must be done as a group. 
- [X] QR Code

Work Distribution Table

| Required Feature | Description | Who / Percentage worked on |
|-|-|-|
| Login / Register | Allows user to create account and login. If user forgets their password, they may use the "Forgot Password?" button that button that sends an email for a reset. | Dominic (50%) Ray (50%) |
| Individual Settings | Allows a user to change their profile picture, password, and off and notifications on or off. Finally, user may log out of their account or delete their account. | Dominic (100%) |
| Group Settings | Allows users of a group to change the group name or leave the group. | Adrian (25%), Dom (25%) Ray (50%)|
| Join/Create Group | Allows users to create or join a group using a unique indentifier or QR code. | text here |
| QR Code Function | Groups generate a random QR Code. Others can use that code with their camera to input the group identifier easily.| Hans (100%) |
| Shopping List | Users are able to view the household's shopping list, add items to the shopping list, checkmark items on the shooping list, and delete items from the shooping list. | Adrian (50%), Dominic (50%) |
| Inventory | Users are able to view the household's inventory, add items to the inventory, delete items from the inventory, and send items to the shared shopping list. | Adrian (50%), Dominic (50%) |
| Event Schedule | Users are able to create new events that can be edited and adjusted based on the needs of the group members. Events are created using a long tap on the calendar or by clicking the add events button on the top right. | Ray (100%) |
| Message Board | Allows users to post messages for the household that shows the person who posted it and the time and date posted. Users can then click on a message and set up a reminder notification | Dominic (100%) |
| Firebase | Set up firebase to store all shared information for a user and their shared groups. This allows the app to save and extract information. | Dominic (100%) |
| Formatting            | Formatting the app in a well-designed manner that conforms to the colors and style of the app's logo. | Adrian (25%), Ray (25%), Dom (25%), Hans (25%) |           
| App Idea and Design   | The team shared equally in brainstorming and designing the app.| Adrian (25%), Ray (25%), Dom (25%), Hans (25%) |
