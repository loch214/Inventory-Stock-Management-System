<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - IMS-185</title>
    <style>
        body {
            font-family: 'Roboto', sans-serif; /* Match login/dashboard font */
            margin: 0;
            padding: 0;
            background-color: #f0f0f0; /* Light gray background */
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .signup-container {
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
            background-color: #222; /* Dark gray left side to match login */
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
            color: #e50914; /* Red accent to match login */
        }

        .stock-animation {
            width: 100%;
            height: 200px;
            position: relative;
            overflow: hidden;
            background: linear-gradient(to top, #444, #222); /* Gradient to match dark theme */
            margin-top: 20px;
        }

        /* New Stock Chart Animation */
        .stock-line {
            position: absolute;
            height: 2px;
            background-color: #e50914; /* Red line to match theme */
            top: 50%;
            animation: stockSlide 4s infinite linear;
        }

        @keyframes stockSlide {
            0% { width: 0; left: 0; }
            50% { width: 100%; left: 0; }
            51% { width: 100%; left: 0; }
            100% { width: 0; left: 100%; }
        }

        .stock-points div {
            position: absolute;
            width: 8px;
            height: 8px;
            background-color: #fff;
            border-radius: 50%;
            animation: stockPulse 4s infinite ease-in-out;
        }

        .stock-points div:nth-child(1) { left: 20%; }
        .stock-points div:nth-child(2) { left: 40%; }
        .stock-points div:nth-child(3) { left: 60%; }
        .stock-points div:nth-child(4) { left: 80%; }

        @keyframes stockPulse {
            0% { transform: scale(1); }
            25% { transform: scale(1.5); }
            50% { transform: scale(1); }
            75% { transform: scale(1.2); }
            100% { transform: scale(1); }
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
            background-color: #f9f9f9; /* Match login/dashboard input background */
        }

        .signup-button {
            background-color: #e50914; /* Red button to match login */
            color: #fff;
            padding: 12px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1.1em;
            transition: background-color 0.3s ease;
        }

        .signup-button:hover {
            background-color: #c40812; /* Darker red on hover */
        }

        .error {
            color: #e50914; /* Red for error to match theme */
            text-align: center;
            margin-bottom: 20px;
        }

        .login-link {
            margin-top: 20px;
            color: #e50914; /* Red for link to match theme */
            text-decoration: none;
        }

        .login-link:hover {
            text-decoration: underline;
        }

        .separator {
            position: absolute;
            left: 50%;
            top: 20%;
            bottom: 20%;
            width: 1px;
            background-color: #ccc; /* Light gray separator */
        }

        .ims-185 {
            position: absolute;
            top: 20px;
            left: 20px;
            font-size: 2em;
            font-weight: bold;
            color: #e50914; /* Red to match login */
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .signup-container {
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
<div class="signup-container">
    <div class="left-side">
        <div class="ims-185">IMS-185</div>
        <h1>Join Us!</h1>
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
        <h2>Sign Up</h2>
        <% if (request.getAttribute("error") != null) { %>
        <p class="error"><%= request.getAttribute("error") %></p>
        <% } %>
        <form action="<%= request.getContextPath() %>/signup" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" placeholder="Enter your username" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter your password" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Enter your email" required>
            </div>
            <div class="form-group">
                <label for="phone">Phone</label>
                <input type="text" id="phone" name="phone" placeholder="Enter your phone number" required>
            </div>
            <div class="form-group">
                <label for="profilePic">Profile Picture</label>
                <input type="file" id="profilePic" name="profilePic" accept="image/*">
            </div>
            <button type="submit" class="signup-button">Sign Up</button>
        </form>
        <a href="<%= request.getContextPath() %>/login" class="login-link">Already have an account? Login</a>
    </div>
</div>
</body>
</html>