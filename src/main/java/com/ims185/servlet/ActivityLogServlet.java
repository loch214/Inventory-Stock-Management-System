package com.ims185.servlet;

import com.ims185.model.ActivityLog;
import com.ims185.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.ims185.config.FilePaths;

import java.io.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/activitylog")
public class ActivityLogServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ActivityLogServlet.class.getName());
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    private List<ActivityLog> loadActivityLogsFromFile() {
        List<ActivityLog> logs = new ArrayList<>();
        Path logFile = Paths.get(FilePaths.getAuditTrailFile());
        
        try (BufferedReader reader = new BufferedReader(new FileReader(logFile.toFile()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                
                try {
                    String[] parts = splitCSVLine(line);
                    if (parts.length >= 5) {
                        ActivityLog log = new ActivityLog();
                        log.setId(parts[0]);
                        log.setUsername(parts[1]);
                        log.setAction(parts[2]);
                        log.setDetails(parts[3].replace("\\,", ","));
                        log.setTimestamp(LocalDateTime.parse(parts[4]));
                        logs.add(log);
                    }
                } catch (Exception e) {
                    LOGGER.warning("Error parsing log line: " + line + " - " + e.getMessage());
                }
            }
        } catch (IOException e) {
            // If file doesn't exist, create some sample logs
            try {
                if (!logFile.toFile().exists()) {
                    logFile.toFile().getParentFile().mkdirs();
                    logFile.toFile().createNewFile();
                    
                    // Add sample logs
                    createSampleLogs(logFile.toFile());
                }
            } catch (IOException ex) {
                LOGGER.severe("Error creating log file: " + ex.getMessage());
            }
        }
        
        return logs;
    }

    private void createSampleLogs(File logFile) {
        ActivityLog sample1 = new ActivityLog("admin", "added", "Item Laptop XPS 15");
        ActivityLog sample2 = new ActivityLog("user1", "updated", "inventory stock for Monitor Dell P2419H");
        ActivityLog sample3 = new ActivityLog("SYSTEM", "performed", "daily backup");
        
        try (PrintWriter writer = new PrintWriter(new FileWriter(logFile))) {
            saveLogEntry(writer, sample1);
            saveLogEntry(writer, sample2);
            saveLogEntry(writer, sample3);
            LOGGER.info("Created sample activity logs");
        } catch (IOException e) {
            LOGGER.severe("Error writing sample logs: " + e.getMessage());
        }
    }
    
    private void saveLogEntry(PrintWriter writer, ActivityLog log) {
        writer.println(log.getId() + "," +
                     log.getUsername() + "," +
                     log.getAction() + "," +
                     log.getDetails().replace(",", "\\,") + "," +
                     log.getTimestamp());
    }
    
    public static void logActivity(HttpServletRequest request, String action, String details) {
        User user = (User) request.getSession().getAttribute("loggedInUser");
        if (user == null) return;
        
        ActivityLog log = new ActivityLog(user.getUsername(), action, details);
        saveActivityLog(request, log);
    }
    
    public static void logSystemActivity(HttpServletRequest request, String action, String details) {
        ActivityLog log = new ActivityLog("SYSTEM", action, details);
        saveActivityLog(request, log);
    }
    
    private static void saveActivityLog(HttpServletRequest request, ActivityLog log) {
        Path logFile = Paths.get(FilePaths.getAuditTrailFile());
        
        try {
            // Ensure directory exists
            if (!logFile.toFile().getParentFile().exists()) {
                logFile.toFile().getParentFile().mkdirs();
            }
            
            try (PrintWriter writer = new PrintWriter(new FileWriter(logFile.toFile(), true))) {
                writer.println(log.getId() + "," +
                             log.getUsername() + "," +
                             log.getAction() + "," +
                             log.getDetails().replace(",", "\\,") + "," +
                             log.getTimestamp());
                
                LOGGER.info("Activity logged: " + log);
            }
        } catch (IOException e) {
            LOGGER.severe("Error logging activity: " + e.getMessage());
        }
    }
    
    // Helper method to split CSV line handling escaped commas
    private String[] splitCSVLine(String line) {
        List<String> result = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean escaped = false;
        
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == ',' && !escaped) {
                result.add(current.toString());
                current = new StringBuilder();
            } else if (c == '\\' && i < line.length() - 1 && line.charAt(i + 1) == ',') {
                escaped = true;
            } else {
                if (escaped) escaped = false;
                current.append(c);
            }
        }
        result.add(current.toString());
        
        return result.toArray(new String[0]);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        
        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Load activity logs
        List<ActivityLog> logs = loadActivityLogsFromFile();
        
        // Filter logs for non-admin users
        if (!loggedInUser.getRole().equals("admin")) {
            List<ActivityLog> filteredLogs = new ArrayList<>();
            for (ActivityLog log : logs) {
                if (log.getUsername().equals(loggedInUser.getUsername())) {
                    filteredLogs.add(log);
                }
            }
            logs = filteredLogs;
        }
        
        // Sort logs by timestamp (newest first)
        Collections.sort(logs, Comparator.comparing(ActivityLog::getTimestamp).reversed());
        
        request.setAttribute("activityLogs", logs);
        request.getRequestDispatcher("/activitylog.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        String details = request.getParameter("details");
        
        if (action != null && details != null) {
            logActivity(request, action, details);
        }
        
        response.sendRedirect(request.getContextPath() + "/activitylog");
    }
}