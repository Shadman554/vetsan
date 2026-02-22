from fastapi import APIRouter
from fastapi.responses import HTMLResponse

router = APIRouter()

PRIVACY_POLICY_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - VET DICT+</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body {
            height: 100%;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.8;
            color: #1e293b;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 16px;
            padding-bottom: 40px;
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            padding-bottom: 20px;
            animation: fadeIn 0.6s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 28px;
            border-radius: 20px;
            text-align: center;
            margin-bottom: 24px;
            box-shadow: 0 20px 60px rgba(102, 126, 234, 0.4);
            position: relative;
            overflow: hidden;
        }
        .header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: pulse 4s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 0.5; }
            50% { transform: scale(1.1); opacity: 0.8; }
        }
        .header-content { position: relative; z-index: 1; }
        .shield-icon {
            width: 64px;
            height: 64px;
            margin: 0 auto 16px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            backdrop-filter: blur(10px);
        }
        .header h1 { 
            font-size: 28px; 
            margin-bottom: 8px; 
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        .header .app-name { 
            font-size: 15px; 
            opacity: 0.9; 
            margin-bottom: 16px;
            font-weight: 500;
        }
        .header .dates {
            display: flex;
            justify-content: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .header .date-chip {
            background: rgba(255,255,255,0.25);
            backdrop-filter: blur(10px);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid rgba(255,255,255,0.3);
        }
        .section {
            background: white;
            border-radius: 16px;
            padding: 28px;
            margin-bottom: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            border: 1px solid rgba(0,0,0,0.05);
        }
        .section:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.12);
        }
        .section h2 {
            font-size: 20px;
            color: #1e293b;
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 3px solid #667eea;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section h2::before {
            content: '●';
            color: #667eea;
            font-size: 12px;
        }
        .section p { 
            margin-bottom: 14px; 
            color: #475569; 
            font-size: 15px;
            line-height: 1.8;
        }
        .section ul { 
            padding-left: 28px; 
            margin-bottom: 14px;
        }
        .section li { 
            margin-bottom: 10px;
            color: #475569;
            font-size: 15px;
            position: relative;
            padding-left: 8px;
        }
        .section li::marker {
            color: #667eea;
            font-weight: bold;
        }
        .section h3 { 
            font-size: 17px; 
            color: #334155; 
            margin: 20px 0 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .section h3::before {
            content: '▸';
            color: #764ba2;
            font-size: 14px;
        }
        .highlight-box {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
            border-left: 4px solid #0ea5e9;
            border-radius: 10px;
            padding: 16px;
            margin: 16px 0;
        }
        .contact-box {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            border: 2px solid #fbbf24;
            border-radius: 12px;
            padding: 20px;
            margin-top: 12px;
            box-shadow: 0 4px 15px rgba(251, 191, 36, 0.2);
        }
        .contact-box p {
            margin-bottom: 10px;
            color: #78350f;
            font-weight: 500;
        }
        .contact-box strong {
            color: #92400e;
            font-weight: 700;
        }
        .contact-box a { 
            color: #1d4ed8; 
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s ease;
        }
        .contact-box a:hover { 
            color: #2563eb;
            text-decoration: underline;
        }
        .footer {
            text-align: center;
            padding: 32px 24px;
            color: rgba(255,255,255,0.9);
            font-size: 14px;
            background: rgba(255,255,255,0.1);
            border-radius: 16px;
            backdrop-filter: blur(10px);
            margin-top: 24px;
            font-weight: 500;
        }
        .badge {
            display: inline-block;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-left: 8px;
        }
    </style>
</head>
<body>
<div class="container">

    <div class="header">
        <div class="header-content">
            <div class="shield-icon">🛡️</div>
            <h1>Privacy Policy</h1>
            <div class="app-name">VET DICT+ &mdash; com.shada.vetdictplus</div>
            <div class="dates">
                <span class="date-chip">Effective: February 22, 2025</span>
                <span class="date-chip">Last Updated: February 22, 2025</span>
            </div>
        </div>
    </div>

    <div class="section">
        <h2>1. Introduction</h2>
        <p>Welcome to VET DICT+ ("we", "us", or "our"). This Privacy Policy explains how we collect, use, and protect your information when you use the VET DICT+ mobile application ("App"). The App is an educational veterinary dictionary designed for veterinary students and professionals.</p>
        <p>By using the App, you agree to the collection and use of information in accordance with this policy.</p>
    </div>

    <div class="section">
        <h2>2. Information We Collect</h2>

        <h3>2.1 Account Information</h3>
        <p>When you create an account or sign in, we collect:</p>
        <ul>
            <li>Name</li>
            <li>Email address</li>
            <li>Password (stored securely in hashed form)</li>
        </ul>
        <p>If you sign in via Google Sign-In, we receive your name, email, and profile information from Google. We do not receive or store your Google password.</p>

        <h3>2.2 Locally Stored Data</h3>
        <p>The App stores the following data on your device:</p>
        <ul>
            <li>Favorites and browsing history</li>
            <li>Cached content for offline use</li>
            <li>App preferences (language, theme, font size)</li>
            <li>Authentication tokens (encrypted via platform secure storage)</li>
        </ul>

        <h3>2.3 Push Notification Data</h3>
        <p>We use OneSignal to deliver push notifications. OneSignal may collect:</p>
        <ul>
            <li>Device type and operating system</li>
            <li>A unique device identifier for notification delivery</li>
            <li>Notification interaction data</li>
        </ul>

        <h3>2.4 Information We Do NOT Collect</h3>
        <ul>
            <li>We do not collect location data</li>
            <li>We do not access your camera, contacts, or phone calls</li>
            <li>We do not collect financial or payment information</li>
            <li>We do not use advertising or ad tracking</li>
        </ul>
    </div>

    <div class="section">
        <h2>3. How We Use Your Information</h2>
        <p>We use the collected information to:</p>
        <ul>
            <li>Provide and maintain the App's features and functionality</li>
            <li>Authenticate your identity and manage your account</li>
            <li>Send push notifications about new content</li>
            <li>Cache content for offline access and improve performance</li>
            <li>Save your preferences (language, theme, font size, favorites, history)</li>
            <li>Improve the App</li>
        </ul>
    </div>

    <div class="section">
        <h2>4. Third-Party Services</h2>
        <p>The App uses the following third-party services:</p>
        <ul>
            <li><strong>Google Sign-In</strong> &mdash; for user authentication</li>
            <li><strong>Firebase (Google)</strong> &mdash; for backend infrastructure</li>
            <li><strong>OneSignal</strong> &mdash; for push notifications</li>
            <li><strong>Railway</strong> &mdash; for API hosting</li>
        </ul>
        <p>Each of these services has its own privacy policy. We encourage you to review them.</p>
    </div>

    <div class="section">
        <h2>5. Data Storage &amp; Security</h2>
        <ul>
            <li>Authentication tokens are stored using Flutter Secure Storage, which uses Android Keystore and iOS Keychain for encryption</li>
            <li>Locally cached data is encrypted by the platform's built-in encryption and is not accessible by other apps</li>
            <li>All server communications are encrypted via HTTPS</li>
            <li>Passwords are hashed and never stored in plain text</li>
        </ul>
    </div>

    <div class="section">
        <h2>6. Data Retention</h2>
        <ul>
            <li>Account data is retained as long as your account is active</li>
            <li>Locally cached data remains on your device until you clear the App's data or uninstall the App</li>
            <li>Push notification tokens are retained by OneSignal as long as the App is installed</li>
        </ul>
    </div>

    <div class="section">
        <h2>7. Your Rights</h2>
        <p>You have the right to:</p>
        <ul>
            <li>Access the personal information stored in your account</li>
            <li>Update your account information via the Profile page</li>
            <li>Delete your account and associated data by contacting us</li>
            <li>Opt out of push notifications via your device settings</li>
            <li>Delete locally stored data by clearing the App's storage in your device settings</li>
        </ul>
    </div>

    <div class="section">
        <h2>8. Children's Privacy</h2>
        <p>The App is an educational tool for veterinary students and professionals. We do not knowingly collect personal information from children under 13. If you believe a child under 13 has provided us with personal information, please contact us so we can delete it.</p>
    </div>

    <div class="section">
        <h2>9. Changes to This Policy</h2>
        <p>We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last Updated" date at the top of this policy. We recommend reviewing this policy periodically.</p>
    </div>

    <div class="section">
        <h2>10. Contact Us</h2>
        <p>If you have any questions or concerns about this Privacy Policy, please contact us:</p>
        <div class="contact-box">
            <p><strong>Email:</strong> <a href="mailto:shadmanothman59@gmail.com">shadmanothman59@gmail.com</a></p>
            <p><strong>Google Play:</strong> <a href="https://play.google.com/store/apps/details?id=com.shada.vetdictplus" target="_blank">VET DICT+ on Google Play</a></p>
            <p><strong>App Store:</strong> <a href="https://apps.apple.com/us/app/vet-dict/id6680200091" target="_blank">VET DICT+ on App Store</a></p>
        </div>
    </div>

    <div class="footer">
        &copy; 2025 VET DICT+. All rights reserved.
    </div>

</div>
</body>
</html>"""

@router.get("/", response_class=HTMLResponse)
async def get_privacy_policy():
    """Serve the privacy policy as an HTML page"""
    return HTMLResponse(content=PRIVACY_POLICY_HTML)
