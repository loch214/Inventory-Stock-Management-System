package com.ims185.servlet;

import com.ims185.model.Item;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AnalyticsServlet.class.getName());
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
            LOGGER.severe("Failed to load inventory.txt: " + e.getMessage());
        }
        return items;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<Item> items = loadItemsFromFile();
        int totalStock = items.stream().mapToInt(Item::getStock).sum();
        double totalValue = items.stream().mapToDouble(item -> item.getPrice() * item.getStock()).sum();
        request.setAttribute("totalStock", totalStock);
        request.setAttribute("totalValue", totalValue);
        request.getRequestDispatcher("/analytics.jsp").forward(request, response);
    }
}