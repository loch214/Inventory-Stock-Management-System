<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="com.ims185.model.Customer" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Customers - IMS-185</title>
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
        input, select, textarea { padding: 5px; width: 200px; }
        textarea { height: 60px; vertical-align: top; }
        button { padding: 5px 10px; background-color: #e50914; color: #fff; border: none; cursor: pointer; border-radius: 3px; }
        button:hover { background-color: #c40812; }
        .error { color: red; margin-bottom: 10px; }
        @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } }
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
        </div>
        <div class="section">
            <h2>Manage Customers</h2>
            <% String error = request.getParameter("error");
                if (error != null) { %>
            <div class="error"><%= error %></div>
            <% } %>
            <h3>Add Customer</h3>
            <form action="<%= request.getContextPath() %>/customer_management" method="post">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label for="addName">Name:</label>
                    <input type="text" id="addName" name="name" required>
                </div>
                <div class="form-group">
                    <label for="addEmail">Email:</label>
                    <input type="email" id="addEmail" name="email" required>
                </div>
                <div class="form-group">
                    <label for="addPhone">Phone:</label>
                    <input type="text" id="addPhone" name="phone" required>
                </div>
                <div class="form-group">
                    <label for="addBalance">Balance:</label>
                    <input type="number" step="0.01" id="addBalance" name="balance" value="0.0">
                </div>
                <div class="form-group">
                    <label for="addorderCount">Order Count:</label>
                    <input type="number" id="addorderCount" name="orderCount" value="0">
                </div>
                <div class="form-group">
                    <label for="addaddress">Address:</label>
                    <textarea id="addaddress" name="address"></textarea>
                </div>
                <div class="form-group">
                    <label for="addnotes">Notes:</label>
                    <textarea id="addnotes" name="notes"></textarea>
                </div>
                <button type="submit">Add Customer</button>
            </form>

            <h3>Update Customer</h3>
            <form action="<%= request.getContextPath() %>/customer_management" method="post">
                <input type="hidden" name="action" value="update">
                <div class="form-group">
                    <label for="id">Customer:</label>
                    <select id="id" name="id" required>
                        <% List<Customer> customers = (List<Customer>) request.getAttribute("customers");
                            if (customers != null) {
                                for (Customer customer : customers) { %>
                        <option value="<%= customer.getId() %>"><%= customer.getName() %> (ID: <%= customer.getId() %>)</option>
                        <% }
                        } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="updateName">Name:</label>
                    <input type="text" id="updateName" name="name" required>
                </div>
                <div class="form-group">
                    <label for="updateEmail">Email:</label>
                    <input type="email" id="updateEmail" name="email" required>
                </div>
                <div class="form-group">
                    <label for="phone">Phone:</label>
                    <input type="text" id="phone" name="phone" required>
                </div>
                <div class="form-group">
                    <label for="balance">Balance:</label>
                    <input type="number" step="0.01" id="balance" name="balance" value="0.0">
                </div>
                <div class="form-group">
                    <label for="orderCount">Order Count:</label>
                    <input type="number" id="orderCount" name="orderCount" value="0">
                </div>
                <div class="form-group">
                    <label for="address">Address:</label>
                    <textarea id="address" name="address"></textarea>
                </div>
                <div class="form-group">
                    <label for="notes">Notes:</label>
                    <textarea id="notes" name="notes"></textarea>
                </div>
                <button type="submit">Update Customer</button>
            </form>

            <h3>Customer List</h3>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Balance</th>
                    <th>Order Count</th>
                    <th>Address</th>
                    <th>Notes</th>
                    <th>Actions</th>
                </tr>
                <% if (customers != null && !customers.isEmpty()) {
                    for (Customer customer : customers) { %>
                <tr>
                    <td><%= customer.getId() %></td>
                    <td><%= customer.getName() %></td>
                    <td><%= customer.getEmail() %></td>
                    <td><%= customer.getPhone() %></td>
                    <td><%= customer.getBalance() %></td>
                    <td><%= customer.getOrderCount() %></td>
                    <td><%= customer.getAddress() != null ? customer.getAddress() : "" %></td>
                    <td><%= customer.getNotes() != null ? customer.getNotes() : "" %></td>
                    <td>
                        <form action="<%= request.getContextPath() %>/customer_management" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="itemId" value="<%= customer.getId() %>">
                            <button type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr><td colspan="9">No customers found.</td></tr>
                <% } %>
            </table>
        </div>
    </div>
</div>
</body>
</html>