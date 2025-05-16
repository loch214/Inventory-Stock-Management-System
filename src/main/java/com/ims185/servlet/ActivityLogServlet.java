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

@WebServlet("/activitylog")
public class ActivityLogServlet extends HttpServlet {
    private List<String> loadActivityLogFromFile() {
        List<String> logs = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "activitylog.txt";
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

    private void saveActivityLogToFile(List<String> logs) {
        String filePath = getServletContext().getRealPath("/") + "activitylog.txt";
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
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<String> logs = loadActivityLogFromFile();
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/activitylog.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("loggedInUser");
        String action = request.getParameter("action");
        if (action != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String logEntry = sdf.format(new Date()) + ": " + user.getUsername() + " " + action;
            List<String> logs = loadActivityLogFromFile();
            logs.add(logEntry);
            saveActivityLogToFile(logs);
        }
        response.sendRedirect(request.getContextPath() + "/activitylog");
    }
}