package com.ims185.servlet;

import com.ims185.model.User;
import com.ims185.util.ActivityLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Logger;

public class LogoutServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LogoutServlet.class.getName());    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Log the logout action before invalidating the session
        User loggedInUser = (User) req.getSession().getAttribute("loggedInUser");
        if (loggedInUser != null) {
            LOGGER.info("User " + loggedInUser.getUsername() + " logged out");
            ActivityLogger.logLogout(req);
        }
        
        // Invalidate the session
        req.getSession().invalidate();
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}
