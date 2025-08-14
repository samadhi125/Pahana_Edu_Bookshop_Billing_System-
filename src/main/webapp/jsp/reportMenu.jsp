<%-- 
    Document   : reportMenu
    Created on : Aug 13, 2025, 10:03:21 PM
    Author     : ugdin
--%>


<%-- admin/reports/reportMenu.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }
  String base = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reports - Admin</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        h1 {
            color: #333;
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 2rem;
            text-align: center;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        h1::before {
            content: "📊";
            font-size: 2rem;
        }

        .tree-container {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(5px);
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .tree {
            list-style: none;
            position: relative;
        }

        .tree ul {
            list-style: none;
            margin-left: 2rem;
            position: relative;
        }

        .tree li {
            position: relative;
            margin: 0.5rem 0;
        }

        .tree li::before {
            content: '';
            position: absolute;
            top: 1rem;
            left: -2rem;
            width: 1.5rem;
            height: 2px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 1px;
        }

        .tree li::after {
            content: '';
            position: absolute;
            top: -0.5rem;
            left: -2rem;
            width: 2px;
            height: 100%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 1px;
        }

        .tree li:last-child::after {
            height: 1.5rem;
        }

        .tree > li::after,
        .tree > li::before {
            display: none;
        }

        .tree-node {
            display: flex;
            align-items: center;
            padding: 1rem 1.5rem;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border: 2px solid transparent;
            transition: all 0.3s ease;
            text-decoration: none;
            color: #555;
            font-weight: 600;
            font-size: 1rem;
            position: relative;
            overflow: hidden;
        }

        .tree-node::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            transform: scaleY(0);
            transition: transform 0.3s ease;
        }

        .tree-node:hover {
            transform: translateX(8px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
            border-color: rgba(102, 126, 234, 0.2);
            background: rgba(255, 255, 255, 1);
        }

        .tree-node:hover::before {
            transform: scaleY(1);
        }

        .tree-node-icon {
            margin-right: 12px;
            font-size: 1.2rem;
            width: 24px;
            text-align: center;
        }

        .tree-node-text {
            flex: 1;
        }

        .tree-node-arrow {
            margin-left: auto;
            font-size: 0.8rem;
            opacity: 0;
            transform: translateX(-10px);
            transition: all 0.3s ease;
        }

        .tree-node:hover .tree-node-arrow {
            opacity: 1;
            transform: translateX(0);
        }

        .category-node {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            border: 2px solid rgba(102, 126, 234, 0.2);
            font-size: 1.1rem;
            padding: 1.2rem 1.5rem;
            margin-bottom: 1rem;
            cursor: default;
            pointer-events: none;
        }

        .category-node .tree-node-icon {
            font-size: 1.4rem;
        }

        .breadcrumb {
            background: rgba(102, 126, 234, 0.05);
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            color: #667eea;
            border: 1px solid rgba(102, 126, 234, 0.1);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }

            .container {
                padding: 1.5rem;
                border-radius: 15px;
            }

            h1 {
                font-size: 2rem;
                margin-bottom: 1.5rem;
            }

            .tree-container {
                padding: 1.5rem;
            }

            .tree ul {
                margin-left: 1.5rem;
            }

            .tree li::before {
                left: -1.5rem;
                width: 1rem;
            }

            .tree li::after {
                left: -1.5rem;
            }

            .tree-node {
                padding: 0.875rem 1rem;
                font-size: 0.95rem;
            }

            .category-node {
                padding: 1rem;
                font-size: 1rem;
            }
        }

        @media (max-width: 480px) {
            .container {
                padding: 1rem;
            }

            h1 {
                font-size: 1.75rem;
                flex-direction: column;
                gap: 10px;
            }

            .tree-container {
                padding: 1rem;
            }

            .tree-node {
                padding: 0.75rem;
                font-size: 0.9rem;
            }

            .tree-node:hover {
                transform: translateX(4px);
            }
        }

        /* Loading animation for visual appeal */
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .tree li {
            animation: slideIn 0.5s ease forwards;
        }

        .tree li:nth-child(1) { animation-delay: 0.1s; }
        .tree li:nth-child(2) { animation-delay: 0.2s; }
        .tree li:nth-child(3) { animation-delay: 0.3s; }
        .tree li:nth-child(4) { animation-delay: 0.4s; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Reports Dashboard</h1>
        

        <div class="tree-container">
            <ul class="tree">
                <li>
                    <div class="tree-node category-node">
                        <span class="tree-node-icon">📈</span>
                        <span class="tree-node-text">Sales Reports</span>
                    </div>
                    <ul>
                        <li>
                            <a href="<%=base%>/jsp/sales-daily.jsp" class="tree-node">
                                <span class="tree-node-icon">📅</span>
                                <span class="tree-node-text">Daily Sales Report</span>
                                <span class="tree-node-arrow">→</span>
                            </a>
                        </li>
                        <li>
                            <a href="<%=base%>/jsp/sales-monthly.jsp" class="tree-node">
                                <span class="tree-node-icon">🗓️</span>
                                <span class="tree-node-text">Monthly Sales Report</span>
                                <span class="tree-node-arrow">→</span>
                            </a>
                        </li>
                    </ul>
                </li>
                <li>
                    <div class="tree-node category-node">
                        <span class="tree-node-icon">👥</span>
                        <span class="tree-node-text">Customer Reports</span>
                    </div>
                    <ul>
                        <li>
                            <a href="<%=base%>/jsp/customer-consumption.jsp" class="tree-node">
                                <span class="tree-node-icon">🔋</span>
                                <span class="tree-node-text">Customer Consumption Report</span>
                                <span class="tree-node-arrow">→</span>
                            </a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</body>
</html>