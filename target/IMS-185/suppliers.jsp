<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.Supplier" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ims185.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Supplier Management - IMS-185</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Roboto', sans-serif; background-color: #f0f0f0; color: #333; line-height: 1.6; }
    .container { display: flex; min-height: 100vh; }
    .sidebar { width: 250px; background-color: #222; color: #fff; padding: 20px; }
    .main-content { flex: 1; padding: 20px; }
    .header { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; margin-bottom: 20px; }
    .header-left { font-size: 1.5em; font-weight: bold; color: #e50914; }
    .header-right { text-align: right; color: #333; }
    .sidebar h1 { font-size: 1.5em; margin-bottom: 20px; color: #e50914; }
    .sidebar ul { list-style: none; padding: 0; }
    .sidebar li { margin-bottom: 10px; }
    .sidebar a { color: #fff; text-decoration: none; display: block; padding: 10px; border-radius: 5px; transition: background-color 0.3s ease; }
    .sidebar a:hover { background-color: #444; }
    .sidebar a.active { background-color: #e50914; font-weight: bold; }
    .section { background-color: #fff; padding: 20px; margin-bottom: 20px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    .section h2 { margin-bottom: 15px; color: #555; border-bottom: 1px solid #eee; padding-bottom: 5px; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background-color: #f5f5f5; font-weight: bold; }
    tr:hover { background-color: #f9f9f9; }
    form { max-width: 400px; margin-bottom: 20px; }
    label { display: block; margin-bottom: 5px; font-weight: bold; }
    input, select { width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 4px; }
    button { background-color: #e50914; color: #fff; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; margin-right: 5px; }
    button:hover { background-color: #c40810; }
    .no-suppliers { color: #555; font-style: italic; }
    @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } }
  </style>
</head>
<body>
<%
  User loggedInUser = (User) session.getAttribute("loggedInUser");
  if (loggedInUser == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
%>
<div class="container">
  <div class="sidebar">
    <h1>Navigation</h1>
    <ul>
      <li><a href="<%= request.getContextPath() %>/dashboard" <%= request.getRequestURI().contains("dashboard") ? "class=\"active\"" : "" %>>Dashboard</a></li>
      <% if (loggedInUser.getIsAdmin()) { %>
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
      <div class="header-right">User: <%= loggedInUser.getUsername() %> (Role: <%= loggedInUser.getIsAdmin() ? "Admin" : "User" %>)</div>
    </div>
    <div class="section">
      <h2>Supplier Management</h2>
      <h3>Add New Supplier</h3>
      <form action="<%= request.getContextPath() %>/suppliers" method="post">
        <input type="hidden" name="action" value="create">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required>
        <label for="contactPerson">Contact Person:</label>
        <input type="text" id="contactPerson" name="contactPerson" required>
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required>
        <label for="phone">Phone:</label>
        <input type="tel" id="phone" name="phone" required>
        <label for="address">Address:</label>
        <input type="text" id="address" name="address" required>
        <button type="submit">Add Supplier</button>
      </form>
      <h3>Current Suppliers</h3>
      <% if (suppliers != null && !suppliers.isEmpty()) { %>
      <table>
        <thead>
        <tr>
          <th>Name</th>
          <th>Contact Person</th>
          <th>Email</th>
          <th>Phone</th>
          <th>Address</th>
          <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <% for (Supplier supplier : suppliers) { %>
        <tr>
          <td><%= supplier.getName() %></td>
          <td><%= supplier.getContactPerson() %></td>
          <td><%= supplier.getEmail() %></td>
          <td><%= supplier.getPhone() %></td>
          <td><%= supplier.getAddress() %></td>
          <td>
            <form action="<%= request.getContextPath() %>/suppliers" method="post" style="display:inline;">
              <input type="hidden" name="action" value="update">
              <input type="hidden" name="id" value="<%= supplier.getId() %>">
              <input type="text" name="name" value="<%= supplier.getName() %>" style="width: 100px;">
              <input type="text" name="contactPerson" value="<%= supplier.getContactPerson() %>" style="width: 100px;">
              <input type="email" name="email" value="<%= supplier.getEmail() %>" style="width: 100px;">
              <input type="tel" name="phone" value="<%= supplier.getPhone() %>" style="width: 100px;">
              <input type="text" name="address" value="<%= supplier.getAddress() %>" style="width: 100px;">
              <button type="submit">Update</button>
            </form>
            <form action="<%= request.getContextPath() %>/suppliers" method="post" style="display:inline;">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="id" value="<%= supplier.getId() %>">
              <button type="submit">Delete</button>
            </form>
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
      <% } else { %>
      <p class="no-suppliers">No suppliers found.</p>
      <% } %>
    </div>
  </div>
</div>
</body>
</html>