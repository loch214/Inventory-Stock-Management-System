package com.ims185.servlet;

import com.ims185.model.User;
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

@WebServlet("/audittrail")
public class AuditTrailServlet extends HttpServlet {
    private List<String> loadAuditTrailFromFile() {
        List<String> logs = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "audittrail.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                logs.add(line);
            }
        } catch (IOException e) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
                writer.write(""); // Create empty file
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        return logs;
    }

    private void saveAuditTrailToFile(List<String> logs) {
        String filePath = getServletContext().getRealPath("/") + "audittrail.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String log : logs) {
                writer.write(log + "\n");
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
        List<String> logs = loadAuditTrailFromFile();
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/audittrail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null || !((User) session.getAttribute("loggedInUser")).getRole().equals("admin")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");
        String action = request.getParameter("action");
        String details = request.getParameter("details");
        if (action != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            String logEntry = sdf.format(new Date()) + "," + user.getUsername() + "," + action + "," + (details != null ? details : "");
            List<String> logs = loadAuditTrailFromFile();
            logs.add(logEntry);
            saveAuditTrailToFile(logs);
        }
        response.sendRedirect(request.getContextPath() + "/audittrail");
    }
}