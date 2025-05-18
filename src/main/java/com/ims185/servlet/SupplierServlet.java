package com.ims185.servlet;

import com.ims185.model.Supplier;
import com.ims185.util.ActivityLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
//Created the SupplierServlet.java
@WebServlet("/suppliers")
public class SupplierServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SupplierServlet.class.getName());
    private static final String SUPPLIERS_FILE_PATH = "WEB-INF/data/suppliers.txt";

    private List<Supplier> loadSuppliers() {
        List<Supplier> suppliers = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + SUPPLIERS_FILE_PATH;
        File file = new File(filePath);
        
        // Ensure data directory exists
        File dataDir = file.getParentFile();
        if (!dataDir.exists()) {
            dataDir.mkdirs();
        }
        
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                LOGGER.severe("Failed to create suppliers.txt: " + e.getMessage());
            }
        }
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length == 6) {
                    Supplier supplier = new Supplier();
                    supplier.setId(parts[0]);
                    supplier.setName(parts[1]);
                    supplier.setContactPerson(parts[2]);
                    supplier.setEmail(parts[3]);
                    supplier.setPhone(parts[4]);
                    supplier.setAddress(parts[5]);
                    suppliers.add(supplier);
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error reading suppliers.txt: " + e.getMessage());
        }
        return suppliers;
    }

    private void saveSuppliers(List<Supplier> suppliers) {
        String filePath = getServletContext().getRealPath("/") + SUPPLIERS_FILE_PATH;
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Supplier supplier : suppliers) {
                writer.write(supplier.getId() + "," +
                        supplier.getName() + "," +
                        supplier.getContactPerson() + "," +
                        supplier.getEmail() + "," +
                        supplier.getPhone() + "," +
                        supplier.getAddress() + "\n");
            }
            LOGGER.info("Saved " + suppliers.size() + " suppliers.");
        } catch (IOException e) {
            LOGGER.severe("Error saving suppliers.txt: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Supplier> suppliers = loadSuppliers();
        request.setAttribute("suppliers", suppliers);
        request.getRequestDispatcher("/suppliers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        List<Supplier> suppliers = loadSuppliers();

        if ("create".equals(action)) {
            String supplierName = request.getParameter("name");
            Supplier supplier = new Supplier(
                    supplierName,
                    request.getParameter("contactPerson"),
                    request.getParameter("email"),
                    request.getParameter("phone"),
                    request.getParameter("address")
            );
            suppliers.add(supplier);
            
            // Log supplier creation
            ActivityLogger.logUserActivity(request, "added", "supplier " + supplierName);
        } else if ("update".equals(action)) {
            String id = request.getParameter("id");
            Supplier supplier = suppliers.stream().filter(s -> s.getId().equals(id)).findFirst().orElse(null);
            if (supplier != null) {
                supplier.setName(request.getParameter("name"));
                supplier.setContactPerson(request.getParameter("contactPerson"));
                supplier.setEmail(request.getParameter("email"));
                supplier.setPhone(request.getParameter("phone"));
                supplier.setAddress(request.getParameter("address"));
                
                // Log supplier update
                ActivityLogger.logUserActivity(request, "updated", "supplier " + supplier.getName());
            }
        } else if ("delete".equals(action)) {
            String id = request.getParameter("id");
            // Find supplier name before removal for logging purposes
            Supplier supplierToDelete = suppliers.stream().filter(s -> s.getId().equals(id)).findFirst().orElse(null);
            String supplierName = supplierToDelete != null ? supplierToDelete.getName() : "unknown";
            
            suppliers.removeIf(s -> s.getId().equals(id));
            
            // Log supplier deletion
            ActivityLogger.logUserActivity(request, "deleted", "supplier " + supplierName);
        }

        saveSuppliers(suppliers);
        response.sendRedirect(request.getContextPath() + "/suppliers");
    }
}