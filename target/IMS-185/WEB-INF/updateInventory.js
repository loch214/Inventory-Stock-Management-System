// Script to update inventory when an order is made
document.addEventListener('DOMContentLoaded', function() {
  // Add event listener to the form submission
  const orderForm = document.querySelector('form.order-form');
  if (orderForm) {
    orderForm.addEventListener('submit', function(event) {
      // Get the selected item and quantity
      const itemName = document.getElementById('itemName').value;
      const quantity = parseInt(document.getElementById('quantity').value);
      
      // Store the order details in localStorage to update inventory display
      if (itemName && quantity) {
        const orderDetails = {
          itemName: itemName,
          quantity: quantity,
          timestamp: new Date().toISOString()
        };
        
        // Get existing orders or create new array
        let pendingInventoryUpdates = JSON.parse(localStorage.getItem('pendingInventoryUpdates') || '[]');
        pendingInventoryUpdates.push(orderDetails);
        localStorage.setItem('pendingInventoryUpdates', JSON.stringify(pendingInventoryUpdates));
      }
    });
  }
  
  // Check if we're on the items.jsp page
  if (window.location.href.includes('/items')) {
    // Update stock display based on pending orders
    updateItemsDisplay();
  }
});

// Function to update the items display
function updateItemsDisplay() {
  const pendingUpdates = JSON.parse(localStorage.getItem('pendingInventoryUpdates') || '[]');
  
  // Process each item row in the table
  const itemRows = document.querySelectorAll('table tbody tr');
  if (!itemRows || itemRows.length === 0) return;
  
  itemRows.forEach(row => {
    const nameCell = row.querySelector('td:nth-child(2)');
    const stockCell = row.querySelector('td:nth-child(4)');
    
    if (!nameCell || !stockCell) return;
    
    const itemName = nameCell.textContent.trim();
    let currentStock = parseInt(stockCell.textContent);
    
    if (isNaN(currentStock)) return;
    
    // Apply any pending order reductions
    pendingUpdates.forEach(update => {
      if (update.itemName === itemName) {
        // Reduce stock by quantity in pending order
        currentStock -= update.quantity;
        if (currentStock < 0) currentStock = 0;
      }
    });
    
    // Update display
    stockCell.textContent = currentStock;
    
    // Add low stock warning if needed
    if (currentStock < 10) {
      stockCell.classList.add('low-stock');
      if (!stockCell.querySelector('.stock-warning')) {
        const warningSpan = document.createElement('span');
        warningSpan.className = 'stock-warning';
        warningSpan.textContent = 'Low Stock';
        stockCell.appendChild(warningSpan);
      }
    } else {
      stockCell.classList.remove('low-stock');
      const warningSpan = stockCell.querySelector('.stock-warning');
      if (warningSpan) {
        stockCell.removeChild(warningSpan);
      }
    }
    
    // Update status column
    const statusCell = row.querySelector('td:nth-child(9)');
    if (statusCell) {
      let statusSpan = statusCell.querySelector('span');
      if (!statusSpan) {
        statusSpan = document.createElement('span');
        statusCell.appendChild(statusSpan);
      }
      
      if (currentStock === 0) {
        statusSpan.className = 'status expired';
        statusSpan.textContent = 'Out of Stock';
      } else if (currentStock < 10) {
        statusSpan.className = 'status low-stock';
        statusSpan.textContent = 'Low Stock';
      } else {
        statusSpan.className = 'status in-stock';
        statusSpan.textContent = 'In Stock';
      }
    }
  });
}
