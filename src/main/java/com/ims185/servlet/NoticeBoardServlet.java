package com.ims185.servlet;

import com.ims185.model.Notice;
import com.ims185.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/notice_board")
public class NoticeBoardServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(NoticeBoardServlet.class.getName());
    private String getNoticesFilePath() {
        return getServletContext().getRealPath("/WEB-INF/data/notices.txt");
    }    private List<Notice> loadNotices() {
        List<Notice> notices = new ArrayList<>();
        String noticesFilePath = getNoticesFilePath();
        File file = new File(noticesFilePath);
        if (!file.exists()) {
            // Create directory structure if it doesn't exist
            File parentDir = file.getParentFile();
            if (!parentDir.exists()) {
                parentDir.mkdirs();
            }
            try {
                file.createNewFile();
            } catch (IOException e) {
                LOGGER.severe("Failed to create notices.txt: " + e.getMessage());
            }
        }
        try (BufferedReader reader = new BufferedReader(new FileReader(noticesFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",", -1);
                if (parts.length == 4) {
                    Notice notice = new Notice();
                    notice.setId(parts[0]);
                    notice.setTitle(parts[1]);
                    notice.setContent(parts[2]);
                    notice.setAuthor(parts[3]);
                    notices.add(notice);
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error reading notices.txt: " + e.getMessage());
        }
        // Reverse the list to show newest notices at the top
        Collections.reverse(notices);
        return notices;
    }    private void saveNotices(List<Notice> notices) {
        String noticesFilePath = getNoticesFilePath();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(noticesFilePath))) {
            // Write in reverse order to maintain newest-first on next load
            for (int i = notices.size() - 1; i >= 0; i--) {
                Notice notice = notices.get(i);
                writer.write(notice.getId() + "," +
                        notice.getTitle() + "," +
                        notice.getContent() + "," +
                        notice.getAuthor() + "\n");
            }
            LOGGER.info("Saved " + notices.size() + " notices.");
        } catch (IOException e) {
            LOGGER.severe("Error saving notices.txt: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Notice> notices = loadNotices();
        request.setAttribute("notices", notices);
        User loggedInUser = (User) request.getSession().getAttribute("loggedInUser");
        request.setAttribute("isAdmin", loggedInUser != null && loggedInUser.getIsAdmin());
        request.getRequestDispatcher("/notice_board.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loggedInUser = (User) request.getSession().getAttribute("loggedInUser");
        if (loggedInUser == null || !loggedInUser.getIsAdmin()) {
            response.sendRedirect(request.getContextPath() + "/notice_board");
            return;
        }

        String action = request.getParameter("action");
        List<Notice> notices = loadNotices();

        if ("create".equals(action)) {
            Notice notice = new Notice(
                    request.getParameter("title"),
                    request.getParameter("content"),
                    loggedInUser.getUsername()
            );
            notices.add(0, notice); // Add new notice at the beginning
        } else if ("update".equals(action)) {
            String id = request.getParameter("id");
            Notice notice = notices.stream().filter(n -> n.getId().equals(id)).findFirst().orElse(null);
            if (notice != null) {
                notice.setTitle(request.getParameter("title"));
                notice.setContent(request.getParameter("content"));
                notice.setAuthor(loggedInUser.getUsername());
            }
        } else if ("delete".equals(action)) {
            String id = request.getParameter("id");
            notices.removeIf(n -> n.getId().equals(id));
        }

        saveNotices(notices);
        response.sendRedirect(request.getContextPath() + "/notice_board");
    }
}