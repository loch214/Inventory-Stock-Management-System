IMS-185: Inventory Management System
Overview
IMS-185 is a web-based Inventory Management System built using Java Servlets, JSP, and Tomcat. It allows users to manage inventory items by adding, updating, and deleting them, with features like image uploads, sorting by expiry date, filtering by search queries, and tracking recent changes using a custom LIFO (Last-In-First-Out) stack.
Project Structure

Source Directory: C:\IMS-185\
Main Servlet: src\main\java\com\ims185\servlet\InventoryServlet.java
Model: src\main\java\com\ims185\model\Item.java
Configuration: src\main\java\com\ims185\config\FilePaths.java
Utilities: src\main\java\com\ims185\util\ActivityLogger.java
JSP: src\main\webapp\inventory.jsp
Data Storage: C:\IMS-185-Data\ (for inventory.txt and uploaded images)

Features

Inventory Management:

Add, update, and delete items with details like name, category, stock, price, item ID, expiry date, and image.
Persist items to inventory.txt.


Image Upload:

Upload images for items, stored in C:/IMS-185-Data/Uploads/images/.
Supports files up to 10 MB (configurable via @MultipartConfig).


Sorting:

Sort items by expiry date (sort=expiry) to prioritize items expiring soon (First-Expired-First-Out, FEFO).
Sort by recent changes (sort=recent) using a custom LIFO stack to show the most recently added or updated items first.


Filtering:

Filter items by name or item ID using a search query (search parameter).


Activity Logging:

Log all inventory actions (add, update, delete) using ActivityLogger.


Custom Stack (LIFO):

A custom CustomStack class in com.ims185.util tracks recently added or updated items in LIFO order, displayed when sort=recent.



Prerequisites

Java 17 or higher
Apache Maven (for building)
Apache Tomcat 10.1.39
A modern web browser

Setup Instructions

Clone or Extract the Project:

Place the project in C:\IMS-185\.


Configure Tomcat:

Ensure Tomcat 10.1.39 is installed at C:\apache-tomcat-10.1.39\.
Add Tomcat to your environment variables or use the full path for scripts.


Build the Project:

Navigate to C:\IMS-185\ in a terminal.
Run:mvn clean package


This generates IMS-185.war in C:\IMS-185\target\.


Deploy to Tomcat:

Stop Tomcat if running: C:\apache-tomcat-10.1.39\bin\shutdown.bat.
Clear old deployments: Delete C:\apache-tomcat-10.1.39\webapps\IMS-185.war and C:\apache-tomcat-10.1.39\webapps\IMS-185\.
Copy the WAR file:copy C:\IMS-185\target\IMS-185.war C:\apache-tomcat-10.1.39\webapps\


Start Tomcat:C:\apache-tomcat-10.1.39\bin\startup.bat




Verify Deployment:

Access http://localhost:8080/IMS-185/inventory in your browser.
Log in with valid credentials (ensure loggedInUser is set in the session via a login servlet).



Usage

Access the Inventory:

Navigate to /inventory after logging in.
View the list of items stored in inventory.txt.


Add an Item:

Submit a POST request to /inventory with action=Add and form parameters (name, category, stock, price, itemId, expiryDate, image).
Example: Use the form in inventory.jsp.


Update an Item:

Submit a POST request with action=Update and the item’s id plus updated fields.
The item will be updated in both the file and the LIFO stack.


Delete an Item:

Submit a POST request with action=Delete and the item’s id.


Sort and Filter:

Sort by expiry date: /inventory?sort=expiry.
Sort by recent changes: /inventory?sort=recent.
Filter by name or item ID: /inventory?search=<query>.



Testing

Add Items:

Add multiple items via the form in inventory.jsp.
Verify they appear in C:/IMS-185-Data/inventory.txt.


Sort by Expiry:

Navigate to /inventory?sort=expiry.
Confirm items are ordered by expiryDate (earliest first).


Sort by Recent Changes:

Add Item1, then Item2, then update Item1.
Navigate to /inventory?sort=recent.
Confirm the order: Item1 (updated last), Item2.


Filter Items:

Use /inventory?search=Item1 to filter items by name or ID.


Image Upload:

Add an item with an image (e.g., a JPG under 10 MB).
Verify the image is saved in C:/IMS-185-Data/Uploads/images/.


Check Logs:

View C:\apache-tomcat-10.1.39\logs\catalina.out for activity logs (add, update, delete actions).



Known Issues

Session Conflicts: If the session contains old data (e.g., java.util.Stack from a previous deployment), a ClassCastException may occur. Clear the session or redeploy with a clean Tomcat instance.
Scalability: The CustomStack uses an ArrayList, which may not be optimal for very large datasets. Consider optimizing for production use.

Future Improvements

Add pagination for large inventories.
Implement user roles and permissions for better access control.

Last Updated

Date: May 19, 2025
Time: 05:56 AM +0530

