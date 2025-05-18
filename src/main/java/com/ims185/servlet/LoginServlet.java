package com.ims185.servlet;

import com.ims185.model.User;
import com.ims185.util.ActivityLogger;
import com.ims185.util.FileStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

//@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Debug: Log request details
        System.out.println("LoginServlet: Processing POST request");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println("LoginServlet: Username=" + username + ", Password=" + password);

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            System.out.println("LoginServlet: Validation failed - Username or password is empty");
            request.setAttribute("error", "Username or password cannot be empty");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        List<User> users = FileStorage.loadUsers();
        System.out.println("LoginServlet: Loaded " + users.size() + " users");

        User loggedInUser = users.stream()
                .filter(user -> user.getUsername().equals(username) && user.getPassword().equals(password))
                .findFirst()
                .orElse(null);        if (loggedInUser != null) {
            System.out.println("LoginServlet: Authentication successful for user: " + loggedInUser.getUsername());
            HttpSession session = request.getSession(true); // Ensure a new session is created if none exists
            session.setAttribute("loggedInUser", loggedInUser);
            session.setMaxInactiveInterval(30 * 60); // Set session timeout to 30 minutes
            System.out.println("LoginServlet: Session ID=" + session.getId() + ", loggedInUser set");
            
            // Log successful login
            ActivityLogger.logLogin(request, true, username);
            
            response.sendRedirect(request.getContextPath() + "/dashboard");
            System.out.println("LoginServlet: Redirecting to dashboard");
        } else {
            System.out.println("LoginServlet: Authentication failed - Invalid credentials");
            
            // Log failed login attempt
            ActivityLogger.logLogin(request, false, username);
            
            request.setAttribute("error", "Invalid username or password");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("LoginServlet: Processing GET request - Forwarding to login.jsp");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}