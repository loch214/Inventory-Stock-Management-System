package com.ims185.servlet;

import com.ims185.model.User;
import com.ims185.util.ActivityLogger;
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

@WebServlet("/user_management")
public class UserManagementServlet extends HttpServlet {
    private List<User> loadUsersFromFile() {
        List<User> users = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "users.txt";
        System.out.println("Loading users from: " + filePath); // Debug
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 3) {
                    User user = new User();
                    user.setUsername(parts[0]);
                    user.setPassword(parts[1]); // Note: Hash passwords in production
                    user.setRole(parts[2]);
                    users.add(user);
                }
            }
        } catch (IOException e) {
            System.out.println("File not found or error: " + e.getMessage()); // Debug
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
                writer.write(""); // Create empty file
            } catch (IOException ex) {
                System.out.println("Failed to create file: " + ex.getMessage());
            }
        }
        return users;
    }

    private void saveUsersToFile(List<User> users) {
        String filePath = getServletContext().getRealPath("/") + "users.txt";
        System.out.println("Saving to: " + filePath); // Debug
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (User user : users) {
                writer.write(user.getUsername() + "," + user.getPassword() + "," + user.getRole() + "\n");
            }
            System.out.println("Saved " + users.size() + " users.");
        } catch (IOException e) {
            System.out.println("Save error: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Object loggedInUser = session.getAttribute("loggedInUser");
        if (loggedInUser == null || !((User) loggedInUser).getRole().equals("admin")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<User> users = loadUsersFromFile();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/user_management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Object loggedInUser = session.getAttribute("loggedInUser");
        if (loggedInUser == null || !((User) loggedInUser).getRole().equals("admin")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<User> users = loadUsersFromFile();
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            if (username != null && password != null && role != null &&
                    users.stream().noneMatch(u -> u.getUsername().equals(username))) {
                User newUser = new User();
                newUser.setUsername(username);
                newUser.setPassword(password); // Note: Hash in production
                newUser.setRole(role);
                users.add(newUser);
                saveUsersToFile(users);
                ActivityLogger.logUserActivity(request, "created", "user account for " + username + " with role " + role);
            }
        } else if ("update".equals(action)) {
            String username = request.getParameter("username");
            String newPassword = request.getParameter("newPassword");
            String newRole = request.getParameter("newRole");
            User userToUpdate = users.stream().filter(u -> u.getUsername().equals(username)).findFirst().orElse(null);
            if (userToUpdate != null) {
                if (newPassword != null && !newPassword.isEmpty()) {
                    userToUpdate.setPassword(newPassword); // Note: Hash in production
                }
                if (newRole != null) {
                    userToUpdate.setRole(newRole);
                }
                saveUsersToFile(users);
                ActivityLogger.logUserActivity(request, "updated", "user account for " + username);
            }
        } else if ("promote".equals(action) || "demote".equals(action)) {
            String username = request.getParameter("username");
            User userToModify = users.stream().filter(u -> u.getUsername().equals(username)).findFirst().orElse(null);
            if (userToModify != null) {
                userToModify.setRole("admin".equals(action) ? "admin" : "user");
                saveUsersToFile(users);
                String actionDesc = "promote".equals(action) ? "promoted" : "demoted";
                ActivityLogger.logUserActivity(request, actionDesc, "user " + username + " to role " + userToModify.getRole());
            }
        }

        response.sendRedirect(request.getContextPath() + "/user_management");
    }
}