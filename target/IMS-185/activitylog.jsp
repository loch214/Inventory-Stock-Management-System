<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="com.ims185.model.ActivityLog" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>User Activity Log - IMS-185</title>  <style>
    /* Existing styles from inventory.jsp */
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Roboto', sans-serif; background-color: #f0f0f0; color: #333; line-height: 1.6; }
    .container { display: flex; min-height: 100vh; }
    .sidebar { width: 250px; background-color: #222; color: #fff; padding: 20px; }
    .main-content { flex: 1; padding: 20px; }
    .header { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; margin-bottom: 20px; }
    .header-left { font-size: 1.5em; font-weight: bold; color: #e50914; }
    .header-right { text-align: right; color: #000000; }
    .sidebar h1 { font-size: 1.5em; margin-bottom: 20px; color: #e50914; }
    .sidebar ul { list-style: none; padding: 0; }
    .sidebar li { margin-bottom: 10px; }
    .sidebar a { color: #fff; text-decoration: none; display: block; padding: 10px; border-radius: 5px; transition: background-color 0.3s ease; }
    .sidebar a:hover { background-color: #444; }
    .sidebar a.active { background-color: #e50914; font-weight: bold; }
    .section { background-color: #fff; padding: 20px; margin-bottom: 20px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    .section h2 { margin-bottom: 15px; color: #555; border-bottom: 1px solid #eee; padding-bottom: 5px; }
    @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } }
    
    /* Activity Log Specific Styles */
    .activity-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    .activity-table th, .activity-table td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
    .activity-table th { background-color: #f5f5f5; font-weight: bold; }
    .activity-table tr:hover { background-color: #f9f9f9; }
    .system-event { background-color: #fffde7; }
    .system-event:hover { background-color: #fff9c4 !important; }
    
    .add-activity { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
    .add-activity h3 { margin-bottom: 10px; font-size: 1.1em; color: #555; }
    .add-activity form { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
    .add-activity label { margin-right: 5px; }
    .add-activity input { padding: 8px; border: 1px solid #ddd; border-radius: 4px; flex: 1; }
    .add-activity button { background-color: #e50914; color: #fff; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; }
    .add-activity button:hover { background-color: #c40810; }
    
    h3 { margin: 15px 0 10px; color: #555; }
  </style>
</head>
<body>
<%
  User user = (User) session.getAttribute("loggedInUser");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
%>
<div class="container">
  <div class="sidebar">
    <h1>Navigation</h1>
    <ul>
      <li><a href="<%= request.getContextPath() %>/dashboard" <%= request.getRequestURI().contains("dashboard") ? "class=\"active\"" : "" %>>Dashboard</a></li>
      <% if (user.getRole().equals("admin")) { %>
      <li><a href="<%= request.getContextPath() %>/user_management" <%= request.getRequestURI().contains("user_management") ? "class=\"active\"" : "" %>>Manage Users</a></li>
      <% } %>
      <li><a href="<%= request.getContextPath() %>/inventory" <%= request.getRequestURI().contains("inventory") ? "class=\"active\"" : "" %>>Manage Inventory</a></li>
      <li><a href="<%= request.getContextPath() %>/customer_management" <%= request.getRequestURI().contains("customer_management") ? "class=\"active\"" : "" %>>Manage Customers</a></li>
      <li><a href="<%= request.getContextPath() %>/update_profile" <%= request.getRequestURI().contains("update_profile") ? "class=\"active\"" : "" %>>Update Profile</a></li>
      <li><a href="<%= request.getContextPath() %>/items" <%= request.getRequestURI().contains("items") ? "class=\"active\"" : "" %>>View Items</a></li>
      <li><a href="<%= request.getContextPath() %>/reports" <%= request.getRequestURI().contains("reports") ? "class=\"active\"" : "" %>>Reports Dashboard</a></li>
      <li><a href="<%= request.getContextPath() %>/analytics" <%= request.getRequestURI().contains("analytics") ? "class=\"active\"" : "" %>>Analytics Overview</a></li>
      <li><a href="<%= request.getContextPath() %>/suppliers" <%= request.getRequestURI().contains("suppliers") ? "class=\"active\"" : "" %>>Supplier Management</a></li>
      <li><a href="<%= request.getContextPath() %>/orders" <%= request.getRequestURI().contains("orders") ? "class=\"active\"" : "" %>>Order Processing</a></li>
      <li><a href="<%= request.getContextPath() %>/returns" <%= request.getRequestURI().contains("returns") ? "class=\"active\"" : "" %>>Returns Management</a></li>
      <li><a href="<%= request.getContextPath() %>/stockalerts" <%= request.getRequestURI().contains("stockalerts") ? "class=\"active\"" : "" %>>Stock Alerts</a></li>
      <li><a href="<%= request.getContextPath() %>/activitylog" <%= request.getRequestURI().contains("activitylog") ? "class=\"active\"" : "" %>>User Activity Log</a></li>
      <li><a href="<%= request.getContextPath() %>/settings" <%= request.getRequestURI().contains("settings") ? "class=\"active\"" : "" %>>Settings Configuration</a></li>
      <li><a href="<%= request.getContextPath() %>/audittrail" <%= request.getRequestURI().contains("audittrail") ? "class=\"active\"" : "" %>>Audit Trail</a></li>
      <li><a href="<%= request.getContextPath() %>/notice_board" <%= request.getRequestURI().contains("notice_board") ? "class=\"active\"" : "" %>>Notice Board</a></li>
      <li><a href="<%= request.getContextPath() %>/logout">Logout</a></li>
    </ul>
  </div>
  <div class="main-content">
    <div class="header">
      <div class="header-left">IMS-185</div>
      <div class="header-right">User: <%= user.getUsername() %> (Role: <%= user.getRole() %>)</div>
    </div>    <div class="section">
      <h2>User Activity Log</h2>
      <p>Track user actions and system events.</p>
      
      <% if (request.isUserInRole("admin")) { %>
      <!-- Admin can add system events -->
      <div class="add-activity">
        <h3>Add System Event</h3>
        <form action="<%= request.getContextPath() %>/activitylog" method="post">
          <label for="action">Action:</label>
          <input type="text" id="action" name="action" required placeholder="performed">
          <label for="details">Details:</label>
          <input type="text" id="details" name="details" required placeholder="system maintenance">
          <button type="submit">Log System Event</button>
        </form>
      </div>
      <% } %>
      
      <h3>Recent Activities</h3>
      <% 
      List<ActivityLog> activityLogs = (List<ActivityLog>) request.getAttribute("activityLogs");
      if (activityLogs != null && !activityLogs.isEmpty()) { 
      %>
      <table class="activity-table">
        <thead>
          <tr>
            <th>Date/Time</th>
            <th>User</th>
            <th>Action</th>
            <th>Details</th>
          </tr>
        </thead>
        <tbody>
        <% for (ActivityLog log : activityLogs) { %>
          <tr class="<%= log.getUsername().equals("SYSTEM") ? "system-event" : "" %>">
            <td><%= log.getFormattedTimestamp() %></td>
            <td><%= log.getUsername() %></td>
            <td><%= log.getAction() %></td>
            <td><%= log.getDetails() %></td>
          </tr>
        <% } %>
        </tbody>
      </table>
      <% } else { %>
      <p>No activity logs found.</p>
      <% } %>
    </div>
  </div>
</div>
</body>
</html>