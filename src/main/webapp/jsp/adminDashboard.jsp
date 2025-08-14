<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect("jsp/login.jsp");
        return;
    }
%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Pahana Edu Book Shop</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
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
        }

        /* Header */
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 2rem;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1400px;
            margin: 0 auto;
        }

        .logo {
            font-size: 24px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .welcome-text {
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 500;
        }

        .logout-btn {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .logout-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }

        /* Navigation Bar */
        .navigation {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 76px;
            z-index: 99;
        }

        .nav-content {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            padding: 0 2rem;
        }

        .nav-item {
            flex: 1;
            text-align: center;
            padding: 1.2rem;
            cursor: pointer;
            transition: all 0.3s ease;
            border-bottom: 3px solid transparent;
            color: #666;
            font-weight: 500;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-decoration: none;
        }

        .nav-item:hover {
            background: rgba(102, 126, 234, 0.1);
            color: #667eea;
        }

        .nav-item.active {
            background: rgba(102, 126, 234, 0.1);
            border-bottom-color: #667eea;
            color: #667eea;
            font-weight: 600;
        }

        /* Content Area */
        .content-container {
            max-width: 1400px;
            margin: 2rem auto;
            padding: 0 2rem;
        }

        .content-frame {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            overflow: hidden;
            min-height: 600px;
        }

        .content-frame iframe {
            width: 100%;
            height: 600px;
            border: none;
            border-radius: 20px;
        }

        /* Alert Styling */
 /* Custom Alert Styling */
 .alert {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 16px 24px;
  border-radius: 12px;
  margin-bottom: 20px;
  font-size: 16px;
  font-weight: 500;
  min-width: 300px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  transform: translateX(400px);
  opacity: 0;
  transition: all 0.4s ease;
  background: white; /* Always pure white */
}

.alert.show {
  transform: translateX(0);
  opacity: 1;
}

.alert.success {
  color: #155724; /* Green text for success */
  border: 2px solid #28a745;
  border-left: 5px solid #28a745;
}

.alert.error {
  color: #dc3545; /* Red text for error */
  border: 2px solid #dc3545;
  border-left: 5px solid #dc3545;
}

.alert::before {
  content: "";
  display: inline-block;
  margin-right: 10px;
  font-weight: bold;
  font-size: 18px;
}

.alert.error::before {
  content: "";
}

.alert .close-btn {
  float: right;
  background: none;
  border: none;
  font-size: 20px;
  font-weight: bold;
  cursor: pointer;
  color: inherit;
  opacity: 0.7;
  margin-left: 10px;
}

.alert .close-btn:hover {
  opacity: 1;
}

        /* Mobile Navigation */
        .mobile-nav-toggle {
            display: none;
            background: none;
            border: none;
            color: white;
            font-size: 24px;
            cursor: pointer;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .header-content {
                flex-wrap: wrap;
            }

            .mobile-nav-toggle {
                display: block;
            }

            .nav-content {
                flex-direction: column;
                max-height: 0;
                overflow: hidden;
                transition: max-height 0.3s ease;
                padding: 0 2rem;
            }

            .nav-content.open {
                max-height: 400px;
                padding: 0 2rem 1rem;
            }

            .nav-item {
                border-bottom: 1px solid rgba(0, 0, 0, 0.1);
                border-right: none;
                justify-content: flex-start;
            }

            .content-container {
                padding: 0 1rem;
            }

            .user-info {
                flex-direction: column;
                gap: 10px;
                width: 100%;
                margin-top: 1rem;
            }

            .content-frame iframe {
                height: 500px;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="header-content">
            <div class="logo">
                <i class="fas fa-book-open"></i>
                Pahana Edu Book Shop
            </div>
            <button class="mobile-nav-toggle" onclick="toggleMobileNav()">
                <i class="fas fa-bars"></i>
            </button>
            <div class="user-info">
                <div class="welcome-text">
                    <i class="fas fa-user-shield"></i>
                    Welcome, <%= loggedUser.getUsername() %>
                </div>
                <form action="<%=request.getContextPath()%>/logout" method="post" style="display: inline;">
                    <button type="submit" class="logout-btn">
                        <i class="fas fa-sign-out-alt"></i>
                        Logout
                    </button>
                </form>
            </div>
        </div>
    </header>

    <!-- Navigation Bar -->
    <nav class="navigation">
        <div class="nav-content" id="navContent">
            <a href="<%=request.getContextPath()%>/jsp/billing.jsp" class="nav-item active" onclick="setActive(this)">
                <i class="fas fa-file-invoice"></i>
                Invoice Management
            </a>
            <a href="<%=request.getContextPath()%>/jsp/customerForm.jsp" class="nav-item" onclick="setActive(this)">
                <i class="fas fa-users"></i>
                Customer Management
            </a>
            <a href="<%=request.getContextPath()%>/jsp/itemForm.jsp" class="nav-item" onclick="setActive(this)">
                <i class="fa-regular fa-chart-bar"></i>
                Item Management
            </a>
            <a href="<%=request.getContextPath()%>/jsp/billing-history.jsp" class="nav-item" onclick="setActive(this)">
                <i class="fas fa-chart-line"></i>
                Billing History
            </a>
             <a href="<%=request.getContextPath()%>/jsp/reportMenu.jsp" class="nav-item" onclick="setActive(this)">
                <i class="fas fa-chart-line"></i>
                Reports
            </a>
              
        </div>
    </nav>

    <!-- Content Container -->
    <div class="content-container">
        <div class="content-frame">
            <iframe id="contentFrame" src="<%=request.getContextPath()%>/jsp/billing.jsp"></iframe>
        </div>
    </div>

    <script>
        // Set active navigation item
        function setActive(element) {
            // Remove active class from all nav items
            document.querySelectorAll('.nav-item').forEach(item => {
                item.classList.remove('active');
            });
            
            // Add active class to clicked item
            element.classList.add('active');
            
            // Load content in iframe
            const href = element.getAttribute('href');
            document.getElementById('contentFrame').src = href;
            
            // Close mobile navigation
            if (window.innerWidth <= 768) {
                document.getElementById('navContent').classList.remove('open');
            }
            
            // Prevent default link behavior
            return false;
        }

        // Update navigation links to use setActive
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                setActive(this);
            });
        });

        // Mobile navigation toggle
        function toggleMobileNav() {
            const navContent = document.getElementById('navContent');
            navContent.classList.toggle('open');
        }

        // Custom alert function
        function showAlert(message, type) {
    console.log('showAlert message:', message); // <-- debug: see what arrives

    const alertDiv = document.createElement('div');
    alertDiv.className = `alert ${type}`;

    // message span (use textContent so nothing gets stripped)
    const msgSpan = document.createElement('span');
    msgSpan.textContent = message ?? '';

    // close button
    const btn = document.createElement('button');
    btn.className = 'close-btn';
    btn.type = 'button';
    btn.textContent = '×';
    btn.onclick = () => alertDiv.remove();

    alertDiv.appendChild(msgSpan);
    alertDiv.appendChild(btn);
    document.body.appendChild(alertDiv);

    setTimeout(() => alertDiv.classList.add('show'), 50);
    setTimeout(() => { alertDiv.classList.remove('show'); setTimeout(() => alertDiv.remove(), 300); }, 5000);
  }

        // Close mobile nav when clicking outside
        document.addEventListener('click', function(event) {
            const navContent = document.getElementById('navContent');
            const mobileToggle = document.querySelector('.mobile-nav-toggle');
            
            if (!navContent.contains(event.target) && !mobileToggle.contains(event.target)) {
                navContent.classList.remove('open');
            }
        });
    </script>
    <c:if test="${not empty sessionScope.flashSuccess}">
<script>
    showAlert("${fn:escapeXml(sessionScope.flashSuccess)}", "success");
</script>
  <c:remove var="flashSuccess" scope="session"/>
</c:if>
</body>
</html>