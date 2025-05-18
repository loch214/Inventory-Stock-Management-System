<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Returns Management - IMS-185</title>  <style>
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
    /* Form styles */
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
    .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
    .submit-button { background-color: #e50914; color: #fff; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; }
    .submit-button:hover { background-color: #c40810; }
    /* Table styles */
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background-color: #f5f5f5; font-weight: bold; }
    tr:hover { background-color: #f9f9f9; }
    /* Alert styles */
    .error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 10px; margin-bottom: 15px; border-radius: 4px; }
    .success { background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 10px; margin-bottom: 15px; border-radius: 4px; }
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
    </div>    <div class="section">
      <h2>Returns Management</h2>
      <p>Process item returns and restock inventory.</p>
        <% 
        String success = request.getParameter("success");
        if (success != null && success.equals("true")) {
      %>
        <div class="success">
          Return processed successfully!
        </div>
      <% } 
         
        String error = (String) request.getAttribute("error");
        if (error != null) {
      %>
        <div class="error">
          Error: <%= error %>
        </div>
      <% } %>        <form action="<%= request.getContextPath() %>/returns" method="post">        <div class="form-group">
          <label for="orderId">Order ID:</label>
          <input type="text" id="orderId" name="orderId" placeholder="Enter the Order ID (e.g. ORD-2025001)" required>
          <small style="color:#666;font-size:0.8em;margin-top:5px;display:block;">Enter Order ID and press Tab to auto-fill item details</small>
          <small id="orderIdHelp" style="color:#666;font-size:0.8em;display:block;">Valid format: ORD-XXXXXX or just XXXXXX (numbers only)</small>
        </div>
        
        <div class="form-group">
          <label for="itemId">Item Name:</label>
          <input type="text" id="itemId" name="itemId" placeholder="Enter the item name" required>
          <small id="itemIdHelp" style="color:#666;font-size:0.8em;margin-top:5px;display:block;"></small>
        </div>
        
        <div class="form-group">
          <label for="quantity">Quantity:</label>
          <input type="number" id="quantity" name="quantity" min="1" value="1" required>
          <small id="maxQuantityHelp" style="color:#666;font-size:0.8em;margin-top:5px;display:block;"></small>
        </div>
        
        <div class="form-group">
          <label for="returnId">Return Reason:</label>
          <select id="returnId" name="returnId" required>
            <option value="damaged">Damaged Product</option>
            <option value="wrong_item">Wrong Item</option>
            <option value="defective">Defective</option>
            <option value="changed_mind">Customer Changed Mind</option>
            <option value="other">Other</option>
          </select>
        </div>
        
        <button type="submit" class="submit-button">Create Return Request</button>
      </form>        <script>
        document.addEventListener('DOMContentLoaded', function() {
          const orderIdField = document.getElementById('orderId');
          const itemIdField = document.getElementById('itemId');
          const quantityField = document.getElementById('quantity');
          const itemIdHelp = document.getElementById('itemIdHelp');
          const maxQuantityHelp = document.getElementById('maxQuantityHelp');
          const validOrderIdsDiv = document.getElementById('validOrderIds');
          
          // Store valid order IDs
          let validOrderIds = [];
          
          // Load valid order IDs when page loads
          loadValidOrderIds();
          
          // Listen for blur event (when user tabs out or clicks away)
          orderIdField.addEventListener('blur', function() {
            validateOrderId();
          });
          
          // Listen for input event to provide real-time feedback
          orderIdField.addEventListener('input', function() {
            // Remove visual error indicators if the field is empty
            if (orderIdField.value.trim() === '') {
              orderIdField.style.border = '1px solid #ddd';
              orderIdField.style.backgroundColor = '';
              itemIdHelp.textContent = '';
            }
          });
          
          // Listen for form submission
          const form = document.querySelector('form');
          form.addEventListener('submit', function(event) {
            if (!validateOrderId(true)) {
              event.preventDefault(); // Prevent form submission if validation fails
            }
          });
          
          // Load all valid order IDs from the server for client-side validation
          async function loadValidOrderIds() {
            if (validOrderIdsDiv.getAttribute('data-loading') === 'true') {
              return; // Already loading
            }
            
            validOrderIdsDiv.setAttribute('data-loading', 'true');
            
            try {
              const response = await fetch("<%= request.getContextPath() %>/returns?action=getValidOrderIds");
              if (!response.ok) {
                throw new Error('Network response was not ok');
              }
              
              const data = await response.json();
              
              if (data && data.orderIds) {
                validOrderIds = data.orderIds;
                console.log('Loaded valid order IDs:', validOrderIds);
              }
            } catch (error) {
              console.error("Error fetching valid order IDs:", error);
            } finally {
              validOrderIdsDiv.setAttribute('data-loading', 'false');
            }
          }
          
          function validateOrderId(isSubmit = false) {
            const orderId = orderIdField.value.trim();
            if (!orderId) {
              if (isSubmit) {
                alert('Please enter an Order ID');
              }
              return false;
            }
            
            // Remove 'ORD-' prefix if present
            let cleanOrderId = orderId;
            if (orderId.toUpperCase().startsWith('ORD-')) {
              cleanOrderId = orderId.substring(4);
            }
            
            // Check if the Order ID is a valid format
            const isValidFormat = /^\d+$/.test(cleanOrderId);
            if (!isValidFormat) {
              orderIdField.style.border = '2px solid #dc3545';
              orderIdField.style.backgroundColor = '#fff8f8';
              itemIdHelp.textContent = 'Invalid Order ID format. Expected format: ORD-XXXXXX or XXXXXX (numbers only)';
              itemIdHelp.style.color = '#dc3545';
              if (isSubmit) {
                alert('Invalid Order ID format. Please use a numeric Order ID.');
              }
              return false;
            }
            
            // Check if the order ID exists in our valid order IDs list
            if (validOrderIds.length > 0 && !validOrderIds.includes(cleanOrderId)) {
              orderIdField.style.border = '2px solid #dc3545';
              orderIdField.style.backgroundColor = '#fff8f8';
              itemIdHelp.textContent = 'Order ID not found in the system. Please enter a valid Order ID.';
              itemIdHelp.style.color = '#dc3545';
              if (isSubmit) {
                alert('Order ID not found in the system. Please enter a valid Order ID.');
              }
              return false;
            }
            
            // If format is valid, fetch the order details from server
            fetchOrderDetails(cleanOrderId);
            return validOrderIds.length === 0 || validOrderIds.includes(cleanOrderId); // Only allow submission if ID is valid or we couldn't load valid IDs
          }
          
          function fetchOrderDetails(cleanOrderId) {
            // Make an AJAX request to get order details
            fetch("<%= request.getContextPath() %>/returns?action=getOrderDetails&orderId=" + cleanOrderId)
              .then(response => response.json())
              .then(data => {
                if (data && data.found) {
                  // Order found - reset validation styling
                  orderIdField.style.border = '2px solid #28a745';
                  orderIdField.style.backgroundColor = '#f0fff0';
                  itemIdHelp.style.color = '#666';
                  
                  // Auto-fill form fields with order data
                  itemIdField.value = data.itemName;
                  itemIdHelp.textContent = `From order: ${data.customerName}'s ${data.itemName}`;
                  
                  // Set quantity (but don't exceed order quantity)
                  const currentQty = parseInt(quantityField.value) || 1;
                  quantityField.value = Math.min(currentQty, data.quantity);
                  quantityField.max = data.quantity;
                  maxQuantityHelp.textContent = `Max quantity: ${data.quantity}`;
                  
                  // Highlight the fields to show they were auto-filled
                  itemIdField.style.backgroundColor = '#f0fff0';
                  setTimeout(() => {
                    itemIdField.style.backgroundColor = '';
                  }, 1500);
                } else {
                  // Order not found in system, check the returns table
                  const orderFromTable = findOrderInReturnsTable(cleanOrderId);
                  
                  if (orderFromTable) {
                    // Order found in returns table
                    orderIdField.style.border = '1px solid #ffc107';
                    orderIdField.style.backgroundColor = '#fffef0';
                    itemIdField.value = orderFromTable.itemName;
                    itemIdHelp.textContent = `From previous return for order: ${orderFromTable.itemName}`;
                    itemIdHelp.style.color = '#856404';
                  } else {
                    // Order not found anywhere
                    orderIdField.style.border = '2px solid #dc3545';
                    orderIdField.style.backgroundColor = '#fff8f8';
                    itemIdHelp.textContent = 'Order ID not found in the system';
                    itemIdHelp.style.color = '#dc3545';
                    maxQuantityHelp.textContent = '';
                  }
                }
              })
              .catch(error => {
                console.error("Error fetching order details:", error);
                itemIdHelp.textContent = 'Error looking up order';
                itemIdHelp.style.color = '#dc3545';
              });
          }
            function findOrderInReturnsTable(orderId) {
            // Look through the displayed returns table for matching order IDs
            const returnTable = document.querySelector("table");
            if (!returnTable) return null;
            
            const rows = returnTable.querySelectorAll("tbody tr");
            for (let row of rows) {
              const cells = row.querySelectorAll("td");
              if (cells.length >= 2) {
                const orderIdCell = cells[1].textContent;
                // If we find "ORD-XXXX", extract the XXXX part
                const displayedOrderId = orderIdCell.startsWith("ORD-") ? 
                  orderIdCell.substring(4) : orderIdCell;
                  
                if (displayedOrderId === orderId) {
                  return {
                    itemName: cells[2].textContent,
                    quantity: parseInt(cells[3].textContent)
                  };
                }
              }
            }
            return null;
          }
          
          // Preload valid order IDs from data file - for reference only
          // This would be better handled by the server
          async function getValidOrderIds() {
            try {
              const response = await fetch("<%= request.getContextPath() %>/returns?action=getValidOrderIds");
              const data = await response.json();
              
              if (data && data.orderIds) {
                // Store valid order IDs in the hidden div for client-side validation
                validOrderIdsDiv.innerHTML = data.orderIds.map(id => `<span>${id}</span>`).join('');
                validOrderIdsDiv.setAttribute('data-loading', 'false');
              }
            } catch (error) {
              console.error("Error fetching valid order IDs:", error);
            }
          }
          
          // Initial load - get valid order IDs
          getValidOrderIds();
        });
      </script>
      
      <h3 style="margin-top: 30px; margin-bottom: 15px;">Recent Returns</h3>
      
      <% 
        // Load returns from file
        List<String[]> returns = new ArrayList<>();
        String returnsFilePath = application.getRealPath("/") + "returns.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(returnsFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    String[] parts = line.split(",");
                    if (parts.length >= 5) {
                        returns.add(parts);
                    }
                }
            }
        } catch (IOException e) {
            // File might not exist yet
        }
        
        if (!returns.isEmpty()) {
      %>
      <div style="overflow-x: auto;">
        <table>          <thead>
            <tr>
              <th>Return ID</th>
              <th>Order ID</th>
              <th>Item</th>
              <th>Quantity</th>              <th>Return Date</th>
              <th>Reason</th>
            </tr>
          </thead>
          <tbody>
          <% 
            // Display most recent returns first (up to 10)
            int count = 0;
            for (int i = returns.size() - 1; i >= 0 && count < 10; i--, count++) {
              String[] ret = returns.get(i);
              String reason = ret.length > 5 ? ret[5] : "N/A";
              // Get status or default to "Pending"
              String status = ret.length > 6 ? ret[6] : "pending";
              
              // Format the reason for display
              switch(reason) {
                case "damaged": reason = "Damaged Product"; break;
                case "wrong_item": reason = "Wrong Item"; break;
                case "defective": reason = "Defective"; break;
                case "changed_mind": reason = "Customer Changed Mind"; break;
              }
          %>
            <tr>
              <td><%= ret[0] %></td>
              <td>ORD-<%= ret[1] %></td>
              <td><%= ret[2] %></td>
              <td><%= ret[3] %></td>              <td><%= ret[4] %></td>
              <td><%= reason %></td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>
      <% } else { %>
        <p>No returns have been processed yet.</p>
      <% } %>
      
      <!-- Add a hidden div to store valid order IDs for client-side validation -->
      <div id="validOrderIds" style="display: none;" data-loading="false"></div>
    </div>
  </div>
</div>
</body>
</html>