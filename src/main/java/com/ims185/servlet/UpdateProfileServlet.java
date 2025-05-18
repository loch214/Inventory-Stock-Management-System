package com.ims185.servlet;

import com.ims185.model.User;
import com.ims185.util.FileStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.UUID;
import java.util.logging.Logger;

@WebServlet("/update_profile")
@MultipartConfig
public class UpdateProfileServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(UpdateProfileServlet.class.getName());
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("loggedInUser");
        if (currentUser == null) {
            LOGGER.warning("No loggedInUser attribute found. Redirecting to login.jsp");
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.getRequestDispatcher("/update_profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("loggedInUser");
        if (currentUser == null) {
            LOGGER.warning("No loggedInUser attribute found. Redirecting to login.jsp");
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        String contactNo = req.getParameter("contactNo");
        Part profilePic = req.getPart("profilePic");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty() ||
                email == null || email.trim().isEmpty() || contactNo == null || contactNo.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/update_profile?error=All fields are required");
            return;
        }

        String profilePicPath = currentUser.getProfilePicPath();
        if (profilePic != null && profilePic.getSize() > 0) {
            profilePicPath = saveProfilePic(req, profilePic);
        }

        User updatedUser = new User(
                currentUser.getId().toString(),
                username,
                password,
                profilePicPath,
                currentUser.getIsAdmin(),
                currentUser.getCreatedAt(),
                email,
                contactNo
        );

        FileStorage.updateUser(updatedUser);
        req.getSession().setAttribute("loggedInUser", updatedUser);
        LOGGER.info("Updated profile for user: " + username);
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private String saveProfilePic(HttpServletRequest req, Part profilePic) throws IOException {
        String fileName = profilePic.getSubmittedFileName();
        String newFileName = UUID.randomUUID() + "_" + fileName;
        String uploadPath = req.getServletContext().getRealPath("/") + UPLOAD_DIR;
        java.io.File uploadDir = new java.io.File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        String savePath = uploadPath + "/" + newFileName;
        profilePic.write(savePath);
        return newFileName;
    }
}