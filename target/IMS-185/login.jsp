<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IMS-185 Login</title>
    <style>
        body {
            font-family: 'Roboto', sans-serif; /* Match dashboard font */
            margin: 0;
            padding: 0;
            background-color: #333333; /* Light gray background */
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-container {
            width: 80%;
            max-width: 900px;
            background-color: #fff; /* White container */
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
            display: flex;
            overflow: hidden; /* Ensure content doesn't overflow */
        }

        .left-side {
            width: 50%;
            background-color: #222; /* Dark gray left side to match sidebar */
            color: #fff;
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: flex-start;
            position: relative;
        }

        .left-side h1 {
            font-size: 3em;
            margin-bottom: 20px;
            color: #e50914; /* Red accent to match dashboard */
        }

        .stock-animation {
            width: 100%;
            height: 200px;
            position: relative;
            overflow: hidden;
            background: linear-gradient(to top, #444, #222); /* Gradient to match dark theme */
            margin-top: 20px;
        }

        /*Stock Chart Animation */
        .stock-line {
            position: absolute;
            width: 100%;
            height: 2px;
            background-color: #e50914; /* Red line to match theme */
            top: 50%;
            left: 0;
            animation: stockMove 5s infinite ease-in-out;
        }

        @keyframes stockMove {
            0% { transform: translateY(0); }
            25% { transform: translateY(-50px); }
            50% { transform: translateY(30px); }
            75% { transform: translateY(-20px); }
            100% { transform: translateY(0); }
        }

        .stock-points div {
            position: absolute;
            width: 8px;
            height: 8px;
            background-color: #fff;
            border-radius: 50%;
            animation: stockPointMove 5s infinite ease-in-out;
        }

        .stock-points div:nth-child(1) { left: 20%; animation-delay: 0s; }
        .stock-points div:nth-child(2) { left: 40%; animation-delay: 0.5s; }
        .stock-points div:nth-child(3) { left: 60%; animation-delay: 1s; }
        .stock-points div:nth-child(4) { left: 80%; animation-delay: 1.5s; }

        @keyframes stockPointMove {
            0% { transform: translateY(0); }
            25% { transform: translateY(-40px); }
            50% { transform: translateY(20px); }
            75% { transform: translateY(-10px); }
            100% { transform: translateY(0); }
        }

        .right-side {
            width: 50%;
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .right-side h2 {
            font-size: 2em;
            margin-bottom: 20px;
            color: #555; /* Darker gray for heading */
        }

        .form-group {
            width: 100%;
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #777; /* Medium gray for labels */
        }

        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc; /* Light gray border */
            border-radius: 5px;
            font-size: 1em;
            background-color: #f9f9f9; /* Match dashboard input background */
        }

        .login-button {
            background-color: #e50914; /* Red button to match dashboard */
            color: #fff;
            padding: 12px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1.1em;
            transition: background-color 0.3s ease;
        }

        .login-button:hover {
            background-color: #c40812; /* Darker red on hover */
        }

        .error {
            color: #e50914; /* Red for error to match theme */
            text-align: center;
            margin-bottom: 20px;
        }

        .signup-link {
            margin-top: 20px;
            color: #e50914; /* Red for link to match theme */
            text-decoration: none;
        }

        .signup-link:hover {
            text-decoration: underline;
        }

        .separator {
            position: absolute;
            left: 50%;
            top: 20%;
            bottom: 20%;
            width: 4px;
            background-color: #ccc; /* Light gray separator */
        }

        .ims-185 {
            position: absolute;
            top: 20px;
            left: 20px;
            font-size: 2em;
            font-weight: bold;
            color: #e50914; /* Red to match dashboard */
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .login-container {
                flex-direction: column;
                width: 95%;
            }

            .left-side, .right-side {
                width: 100%;
                padding: 20px;
            }

            .separator {
                display: none;
            }

            .left-side h1 {
                font-size: 2.5em;
            }
        }
    </style>
</head>
<body>
<div class="login-container">
    <div class="left-side">
        <div class="ims-185">IMS-185</div>
        <h1>Welcome Back!</h1>
        <div class="stock-animation">
            <div class="stock-line"></div>
            <div class="stock-points">
                <div></div>
                <div></div>
                <div></div>
                <div></div>
            </div>
        </div>
    </div>
    <div class="separator"></div>
    <div class="right-side">
        <h2>Login</h2>
        <% if (request.getAttribute("error") != null) { %>
        <p class="error"><%= request.getAttribute("error") %></p>
        <% } %>
        <form action="<%= request.getContextPath() %>/login" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" placeholder="Enter your username" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter your password" required>
            </div>
            <button type="submit" class="login-button">Login</button>
        </form>
        <a href="<%= request.getContextPath() %>/signup" class="signup-link">Are you a new user? Sign up</a>
    </div>
</div>
</body>
</html>