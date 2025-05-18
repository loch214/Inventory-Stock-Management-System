<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.Item" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Items - IMS-185</title>
    <style>
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
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #e50914; color: #fff; }        @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } }
        
        /* Additional styles for items view */
        .search-section { margin-bottom: 20px; }
        .search-form { display: flex; gap: 10px; }
        .search-form input[type="text"] { 
            flex: 1;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .search-form button {
            padding: 8px 16px;
            background-color: #e50914;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-form button:hover { background-color: #b2070f; }
        .low-stock { color: #e50914; }
        .stock-warning {
            font-size: 0.8em;
            color: #fff;
            background-color: #e50914;
            padding: 2px 6px;
            border-radius: 3px;
            margin-left: 5px;
        }
        .status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.9em;
            font-weight: bold;
        }
        .status.expired { background-color: #dc3545; color: white; }
        .status.low-stock { background-color: #ffc107; color: black; }
        .status.in-stock { background-color: #28a745; color: white; }
        td img {
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        td img:hover {
            transform: scale(2);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
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
        </div>        <div class="section">
            <h2>View Items</h2>
            <!-- Search Form -->
            <div class="search-section">
                <form action="<%= request.getContextPath() %>/items" method="get" class="search-form">
                    <input type="text" name="search" placeholder="Search by name or ID..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                    <button type="submit">Search</button>
                </form>
            </div>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Category</th>
                    <th>Stock</th>
                    <th>Price</th>
                    <th>Item ID</th>
                    <th>Expiry Date</th>
                    <th>Image</th>
                    <th>Status</th>
                </tr>
                <% List<Item> items = (List<Item>) request.getAttribute("items");
                    if (items != null && !items.isEmpty()) {
                        for (Item item : items) { %>
                <tr>                    <td><%= item.getId() %></td>
                    <td><%= item.getName() != null ? item.getName() : "N/A" %></td>
                    <td><%= item.getCategory() != null ? item.getCategory() : "N/A" %></td>                    <% 
                    // Get threshold from request attribute, use default 10 if not set
                    int threshold = 10;
                    if (request.getAttribute("lowStockThreshold") != null) {
                        threshold = (int) request.getAttribute("lowStockThreshold");
                    }
                    %>
                    <td class="<%= item.getStock() < threshold ? "low-stock" : "" %>">
                        <%= item.getStock() %>
                        <% if (item.getStock() < threshold) { %>
                        <span class="stock-warning">Low Stock</span>
                        <% } %>
                    </td>
                    <td>$<%= String.format("%.2f", item.getPrice()) %></td>                    <td><%= item.getItemId() != null ? item.getItemId() : "N/A" %></td>
                    <td><%= item.getExpiryDate() != null ? item.getExpiryDate() : "N/A" %></td>
                    <td>
                        <% if (item.getImagePath() != null && !item.getImagePath().isEmpty()) { %>
                        <img src="<%= request.getContextPath() + "/" + item.getImagePath() %>" alt="Item Image" width="50">
                        <% } else { %>
                        No Image
                        <% } %>
                    </td>                    <td>
                        <% 
                        // Get threshold value from request attribute or use default
                        int stockThreshold = 10;
                        if (request.getAttribute("lowStockThreshold") != null) {
                            stockThreshold = (int) request.getAttribute("lowStockThreshold");
                        }
                        
                        boolean isExpired = item.getExpiryDate() != null && item.getExpiryDate().compareTo(java.time.LocalDate.now().toString()) < 0;
                        boolean isLowStock = item.getStock() < stockThreshold;
                        boolean isOutOfStock = item.getStock() <= 0;
                        
                        if (isExpired) { %>
                            <span class="status expired">Expired</span>
                        <% } else if (isOutOfStock) { %>
                            <span class="status expired">Out of Stock</span>
                        <% } else if (isLowStock) { %>
                            <span class="status low-stock">Low Stock</span>
                        <% } else { %>
                            <span class="status in-stock">In Stock</span>
                        <% } %>
                    </td>
                </tr>
                <% }
                } else { %>
                <tr><td colspan="9">No items found.</td></tr>
                <% } %>
            </table>
        </div>    </div>
</div>
</body>
</html>