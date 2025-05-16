package com.ims185.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/suppliers")
public class SupplierServlet extends HttpServlet {
    private List<String[]> loadSuppliersFromFile() {
        List<String[]> suppliers = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "suppliers.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 3) suppliers.add(parts);
            }
        } catch (IOException e) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
                writer.write(""); // Create empty file
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        return suppliers;
    }

    private void saveSuppliersToFile(List<String[]> suppliers) {
        String filePath = getServletContext().getRealPath("/") + "suppliers.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String[] supplier : suppliers) {
                writer.write(String.join(",", supplier) + "\n");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.getRequestDispatcher("/suppliers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<String[]> suppliers = loadSuppliersFromFile();
        String supplierName = request.getParameter("supplierName");
        String contact = request.getParameter("contact");
        if (supplierName != null && contact != null) {
            String[] newSupplier = {String.valueOf(suppliers.size() + 1), supplierName, contact};
            suppliers.add(newSupplier);
            saveSuppliersToFile(suppliers);
        }
        response.sendRedirect(request.getContextPath() + "/suppliers");
    }
}