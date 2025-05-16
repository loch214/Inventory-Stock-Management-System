package com.ims185.servlet;

import com.ims185.model.Item;
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

@WebServlet("/reports")
public class ReportsServlet extends HttpServlet {
    private List<Item> loadItemsFromFile() {
        List<Item> items = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "inventory.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 10) {
                    Item item = new Item();
                    item.setId(Integer.parseInt(parts[0]));
                    item.setName(parts[1]);
                    item.setCategory(parts[2]);
                    item.setStock(Integer.parseInt(parts[3]));
                    item.setPrice(Double.parseDouble(parts[4]));
                    item.setItemId(parts[5]);
                    item.setImagePath(parts[6]);
                    item.setExpiryDate(parts[7]);
                    item.setAddedDate(parts[8]);
                    item.setLastUpdatedDate(parts[9]);
                    items.add(item);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return items;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String reportType = request.getParameter("reportType");
        List<Item> items = loadItemsFromFile();
        if ("stock".equals(reportType)) {
            request.setAttribute("report", "Stock Levels Report: " + items.size() + " items");
        } else if ("expired".equals(reportType)) {
            List<Item> expired = new ArrayList<>();
            for (Item item : items) {
                if (item.getExpiryDate() != null && item.getExpiryDate().compareTo("2025-05-07") < 0) {
                    expired.add(item);
                }
            }
            request.setAttribute("report", "Expired Items Report: " + expired.size() + " items");
        }
        request.getRequestDispatcher("/reports.jsp").forward(request, response);
    }
}