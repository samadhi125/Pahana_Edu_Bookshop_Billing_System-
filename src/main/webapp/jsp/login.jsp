<%-- 
    Document   : login
    Created on : Aug 6, 2025, 11:11:55 PM
    Author     : ugdin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:if test="${not empty sessionScope.flashSuccess}">
  <script>showAlert("${fn:escapeXml(sessionScope.flashSuccess)}", "success");</script>
  <c:remove var="flashSuccess" scope="session"/>
</c:if>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - PahanaEduBookShop</title>
  <!-- Your CSS styles go here -->
  <style>
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
  }

  .login-container {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 400px;
    text-align: center;
  }

  .login-header {
    margin-bottom: 30px;
  }

  .login-header h1 {
    color: #333;
    font-size: 34px;
    font-weight: 700;
    margin-bottom: 8px;
    background: linear-gradient(135deg, #667eea, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: -0.5px;
  }

  .login-header p {
    color: #666;
    font-size: 14px;
  }

  .form-group {
    margin-bottom: 20px;
    text-align: left;
  }

  label {
    display: block;
    margin-bottom: 8px;
    color: #555;
    font-weight: 600;
    font-size: 18px;
  }

  input[type="text"],
  input[type="password"] {
    width: 100%;
    padding: 18px 20px;
    border: 2px solid #e1e5e9;
    border-radius: 10px;
    font-size: 20px;
    transition: all 0.3s ease;
    background-color: #f8f9fa;
  }

  input[type="text"]:focus,
  input[type="password"]:focus {
    outline: none;
    border-color: #667eea;
    background-color: #fff;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }

  button[type="submit"] {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    margin-top: 10px;
  }

  button[type="submit"]:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
  }

  button[type="submit"]:active {
    transform: translateY(0);
  }

  /* Responsive Design */
  @media (max-width: 480px) {
    .login-container {
      padding: 30px 20px;
      margin: 10px;
    }

    .login-header h1 {
      font-size: 24px;
    }

    input[type="text"],
    input[type="password"] {
      font-size: 16px; /* Prevents zoom on iOS */
    }
  }

  @media (max-width: 360px) {
    .login-container {
      padding: 25px 15px;
    }
    
    .login-header h1 {
      font-size: 22px;
    }
  }

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
  content: "✓";
  display: inline-block;
  margin-right: 10px;
  font-weight: bold;
  font-size: 18px;
}

.alert.error::before {
  content: "✗";
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


  .btn-loading::after {
    content: "";
    position: absolute;
    width: 20px;
    height: 20px;
    top: 50%;
    left: 50%;
    margin-left: -10px;
    margin-top: -10px;
    border: 2px solid #ffffff;
    border-radius: 50%;
    border-top-color: transparent;
    animation: spin 1s ease-in-out infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
</head>
<body>
  <div class="login-container">
    <div class="login-header">
      <h1>Pahana Edu Book Shop</h1>
      <p>Welcome back! Please sign in to your account</p>
    </div>
    
    <form method="post" action="${pageContext.request.contextPath}/login" id="loginForm">
      <div class="form-group">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required />
      </div>
      
      <div class="form-group">
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required />
      </div>
      
      <button type="submit" id="loginBtn">Login</button>
    </form>
  </div>

  <script>
    // Enhanced form submission with loading state
    document.getElementById('loginForm').addEventListener('submit', function() {
      const btn = document.getElementById('loginBtn');
      btn.classList.add('btn-loading');
      btn.disabled = true;
    });

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
  </script>

  <c:if test="${not empty requestScope.error}">
    <script>
      showAlert("${fn:escapeXml(requestScope.error)}", "error");
    </script>
  </c:if>
  
  <c:if test="${not empty requestScope.success}">
    <script>
      showAlert("${fn:escapeXml(requestScope.success)}", "success");
    </script>
  </c:if>
</body>
</html>