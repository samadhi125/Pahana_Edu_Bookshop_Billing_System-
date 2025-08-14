/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

/**
 *
 * @author ugdin
 */
import models.User;
import services.AuthService;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet("/login")
public class AuthController extends HttpServlet {
    private AuthService authService = new AuthService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            User user = authService.authenticate(username, password);

            if (user != null) {
                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("user", user);

                // Set cookie
                Cookie loginCookie = new Cookie("username", user.getUsername());
                loginCookie.setMaxAge(60 * 60); // 1 hour
                response.addCookie(loginCookie);

                // Redirect by role
                if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                    session.setAttribute("flashSuccess", "Wellcome to Admin Dashboard");
                    response.sendRedirect("jsp/adminDashboard.jsp");
                } else if ("CASHIER".equalsIgnoreCase(user.getRole())) {
                    session.setAttribute("flashSuccess", "Wellcome to Cashier Dashboard");
                    response.sendRedirect("jsp/cashierDashboard.jsp");
                }
            } else {
                request.setAttribute("error", "Invalid credentials");
                request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error");
            request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
        }
    }
}


