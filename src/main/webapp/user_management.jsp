<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - IMS-185</title>
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
        .section h3 { margin: 15px 0 10px; color: #555; }
        .section table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #e50914; color: #fff; }
        .form-group { margin: 10px 0; }
        label { display: inline-block; width: 100px; }
        input, select { padding: 5px; width: 200px; }
        button { padding: 5px 10px; background-color: #e50914; color: #fff; border: none; cursor: pointer; border-radius: 3px; }
        button:hover { background-color: #c40812; }
        @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null || !user.getRole().equals("admin")) {
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
            <li><a href="<%= request.getContextPath() %>/logout">Logout</a></li>
        </ul>
    </div>
    <div class="main-content">
        <div class="header">
            <div class="header-left">IMS-185</div>
            <div class="header-right">User: <%= user.getUsername() %> (Role: <%= user.getRole() %>)</div>
        </div>
        <div class="section">
            <h2>Manage Users</h2>
            <h3>Add User</h3>
            <form action="<%= request.getContextPath() %>/user_management" method="post">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label for="newUsername">Username:</label>
                    <input type="text" id="newUsername" name="username" required>
                </div>
                <div class="form-group">
                    <label for="newPassword">Password:</label>
                    <input type="password" id="newPassword" name="password" required>
                </div>
                <div class="form-group">
                    <label for="addNewRole">Role:</label>
                    <select id="addNewRole" name="role" required>
                        <option value="user">User</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
                <button type="submit">Add User</button>
            </form>

            <h3>Update User</h3>
            <form action="<%= request.getContextPath() %>/user_management" method="post">
                <input type="hidden" name="action" value="update">
                <div class="form-group">
                    <label for="username">Username:</label>
                    <select id="username" name="username" required>
                        <% List<User> users = (List<User>) request.getAttribute("users");
                            if (users != null) {
                                for (User u : users) { %>
                        <option value="<%= u.getUsername() %>"><%= u.getUsername() %> (Role: <%= u.getRole() %>)</option>
                        <% }
                        } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="updatePassword">New Password:</label>
                    <input type="password" id="updatePassword" name="newPassword">
                </div>
                <div class="form-group">
                    <label for="updateNewRole">New Role:</label>
                    <select id="updateNewRole" name="newRole">
                        <option value="user">User</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
                <button type="submit">Update User</button>
            </form>

            <h3>User List</h3>
            <table>
                <tr><th>Username</th><th>Role</th><th>Actions</th></tr>
                <% if (users != null) {
                    for (User u : users) { %>
                <tr>
                    <td><%= u.getUsername() %></td>
                    <td><%= u.getRole() %></td>
                    <td>
                        <form action="<%= request.getContextPath() %>/user_management" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="<%= "admin".equals(u.getRole()) ? "demote" : "promote" %>">
                            <input type="hidden" name="username" value="<%= u.getUsername() %>">
                            <button type="submit"><%= "admin".equals(u.getRole()) ? "Demote" : "Promote" %></button>
                        </form>
                    </td>
                </tr>
                <% }
                } %>
            </table>
        </div>
    </div>
</div>
</body>
</html>