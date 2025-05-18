package com.ims185.servlet;

import com.ims185.util.FileStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Logger;

public class DeleteAccountServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(DeleteAccountServlet.class.getName());
    //private final FileStorage fileStorage = new FileStorage();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String userId = ((com.ims185.model.User) session.getAttribute("user")).getId().toString();
        FileStorage.deleteUser(userId);
        session.invalidate();
        LOGGER.info("Account deleted: " + userId);
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}
