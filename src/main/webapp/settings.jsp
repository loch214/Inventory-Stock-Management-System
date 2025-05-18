<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Settings Configuration - IMS-185</title>
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
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 5px; color: #777; }
    .form-group input { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 5px; font-size: 1em; background-color: #f9f9f9; }
    .submit-button { background-color: #e50914; color: #fff; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; transition: background-color 0.3s ease; }
    .submit-button:hover { background-color: #c40812; }
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
      <li><a href="<%= request.getContextPath() %>/notice_board" <%= request.getRequestURI().contains("notice_board") ? "class=\"active\"" : "" %>>Notice Board</a></li>
      <li><a href="<%= request.getContextPath() %>/logout">Logout</a></li>
    </ul>
  </div>
  <div class="main-content">
    <div class="header">
      <div class="header-left">IMS-185</div>
      <div class="header-right">User: <%= user.getUsername() %> (Role: <%= user.getRole() %>)</div>
    </div>    <div class="section">
      <h2>Settings Configuration</h2>
      <% 
        String success = request.getParameter("success");
        if (success != null && success.equals("true")) {
      %>
        <div class="success" style="background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 10px; margin-bottom: 15px; border-radius: 4px;">
          Settings saved successfully!
        </div>
      <% } 
         
        String error = (String) request.getAttribute("error");
        if (error != null) {
      %>
        <div class="error" style="background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 10px; margin-bottom: 15px; border-radius: 4px;">
          Error: <%= error %>
        </div>
      <% } %>
      <form action="<%= request.getContextPath() %>/settings" method="post"><div class="form-group">
          <label for="threshold">Low Stock Threshold:</label>
          <input type="number" id="threshold" name="threshold" value="<%= request.getAttribute("threshold") %>" min="1" required>
          <small style="color: #777; font-size: 0.8em; display: block; margin-top: 5px;">Minimum threshold value is 1</small>
        </div>
        <div id="validationError" class="error-message" style="color: #dc3545; margin-bottom: 15px; display: none;">
          Low Stock Threshold must be at least 1
        </div>
        <button type="submit" class="submit-button">Save Settings</button>
      </form>
      
      <script>
        document.addEventListener('DOMContentLoaded', function() {
          const thresholdInput = document.getElementById('threshold');
          const validationError = document.getElementById('validationError');
          const form = document.querySelector('form');
          
          // Validate on input change
          thresholdInput.addEventListener('input', function() {
            validateThreshold();
          });
          
          // Validate on form submission
          form.addEventListener('submit', function(event) {
            if (!validateThreshold(true)) {
              event.preventDefault(); // Prevent form submission if validation fails
            }
          });
          
          function validateThreshold(isSubmit = false) {
            const value = parseInt(thresholdInput.value);
            
            // Check if the value is at least 1
            if (isNaN(value) || value < 1) {
              thresholdInput.style.border = '2px solid #dc3545';
              validationError.style.display = 'block';
              
              if (isSubmit) {
                // Focus on the input field
                thresholdInput.focus();
              }
              
              return false;
            } else {
              // Reset validation styling
              thresholdInput.style.border = '1px solid #ccc';
              validationError.style.display = 'none';
              return true;
            }
          }
          
          // Initial validation
          validateThreshold();
        });
      </script>
    </div>
  </div>
</div>
</body>
</html>