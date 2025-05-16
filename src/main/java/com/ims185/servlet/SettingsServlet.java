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
import java.util.HashMap;
import java.util.Map;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {
    private Map<String, String> loadSettingsFromFile() {
        Map<String, String> settings = new HashMap<>();
        String filePath = getServletContext().getRealPath("/") + "settings.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("=", 2);
                if (parts.length == 2) settings.put(parts[0], parts[1]);
            }
        } catch (IOException e) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
                writer.write("threshold=10\n"); // Default value
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        return settings;
    }

    private void saveSettingsToFile(Map<String, String> settings) {
        String filePath = getServletContext().getRealPath("/") + "settings.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (Map.Entry<String, String> entry : settings.entrySet()) {
                writer.write(entry.getKey() + "=" + entry.getValue() + "\n");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null || !((User) session.getAttribute("loggedInUser")).getRole().equals("admin")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Map<String, String> settings = loadSettingsFromFile();
        request.setAttribute("threshold", settings.getOrDefault("threshold", "10"));
        request.getRequestDispatcher("/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null || !((User) session.getAttribute("loggedInUser")).getRole().equals("admin")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Map<String, String> settings = loadSettingsFromFile();
        String threshold = request.getParameter("threshold");
        if (threshold != null) settings.put("threshold", threshold);
        saveSettingsToFile(settings);
        response.sendRedirect(request.getContextPath() + "/settings");
    }
}