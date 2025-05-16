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

@WebServlet("/returns")
public class ReturnsServlet extends HttpServlet {
    private List<String[]> loadReturnsFromFile() {
        List<String[]> returns = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "returns.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 5) returns.add(parts);
            }
        } catch (IOException e) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
                writer.write(""); // Create empty file
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        return returns;
    }

    private void saveReturnsToFile(List<String[]> returns) {
        String filePath = getServletContext().getRealPath("/") + "returns.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String[] ret : returns) {
                writer.write(String.join(",", ret) + "\n");
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
        request.getRequestDispatcher("/returns.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<String[]> returns = loadReturnsFromFile();
        String returnId = request.getParameter("returnId");
        String orderId = request.getParameter("orderId") != null ? request.getParameter("orderId") : "1";
        String itemId = request.getParameter("itemId") != null ? request.getParameter("itemId") : "item1";
        String quantity = request.getParameter("quantity") != null ? request.getParameter("quantity") : "1";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String date = sdf.format(new Date());
        if (returnId != null) {
            String[] newReturn = {returnId, orderId, itemId, quantity, date};
            returns.add(newReturn);
            saveReturnsToFile(returns);
        }
        response.sendRedirect(request.getContextPath() + "/returns");
    }
}