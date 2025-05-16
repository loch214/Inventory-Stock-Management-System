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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@WebServlet("/orders")
public class OrderServlet extends HttpServlet {
    private List<String[]> loadOrdersFromFile() {
        List<String[]> orders = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "orders.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 5) orders.add(parts);
            }
        } catch (IOException e) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
                writer.write(""); // Create empty file
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        return orders;
    }

    private void saveOrdersToFile(List<String[]> orders) {
        String filePath = getServletContext().getRealPath("/") + "orders.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String[] order : orders) {
                writer.write(String.join(",", order) + "\n");
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
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<String[]> orders = loadOrdersFromFile();
        String orderId = request.getParameter("orderId");
        String itemId = request.getParameter("itemId");
        String quantity = request.getParameter("quantity") != null ? request.getParameter("quantity") : "1";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String date = sdf.format(new Date());
        if (orderId != null && itemId != null) {
            String[] newOrder = {String.valueOf(orders.size() + 1), "cust1", itemId, quantity, date}; // Placeholder customerId
            orders.add(newOrder);
            saveOrdersToFile(orders);
        }
        response.sendRedirect(request.getContextPath() + "/orders");
    }
}