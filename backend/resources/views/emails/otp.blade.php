<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verification Code</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background-color: #4CAF50;
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        .content {
            padding: 40px 30px;
            text-align: center;
        }
        .otp-code {
            font-size: 36px;
            font-weight: bold;
            color: #4CAF50;
            letter-spacing: 8px;
            margin: 30px 0;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 8px;
            display: inline-block;
        }
        .message {
            color: #666;
            line-height: 1.6;
            margin: 20px 0;
        }
        .warning {
            color: #f44336;
            font-size: 14px;
            margin-top: 20px;
        }
        .footer {
            background-color: #f9f9f9;
            padding: 20px;
            text-align: center;
            color: #999;
            font-size: 12px;
            border-top: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Mobile App</h1>
        </div>
        <div class="content">
            @if($customerName)
            <p class="message">Hello <strong>{{ $customerName }}</strong>,</p>
            @else
            <p class="message">Hello,</p>
            @endif
            
            <p class="message">Thank you for registering! Please use the verification code below to complete your registration:</p>
            
            <div class="otp-code">{{ $otp }}</div>
            
            <p class="message">This code will expire in <strong>10 minutes</strong>.</p>
            
            <p class="warning">⚠️ Never share this code with anyone. Our team will never ask for this code.</p>
        </div>
        <div class="footer">
            <p>If you didn't request this code, please ignore this email.</p>
            <p>&copy; {{ date('Y') }} Mobile App. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
