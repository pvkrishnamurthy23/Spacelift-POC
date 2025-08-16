#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ${project_name}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            max-width: 500px;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        p {
            color: #666;
            line-height: 1.6;
        }
        .server-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Welcome to ${project_name}</h1>
        <p>Your EC2 instance is running successfully!</p>
        <p>This page is served by Apache HTTP Server on Amazon Linux 2.</p>
        <div class="server-info">
            <strong>Server Information:</strong><br>
            Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)<br>
            Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)<br>
            Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)<br>
            Launch Time: $(date)
        </div>
    </div>
</body>
</html>
EOF

# Set proper permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Install additional tools
yum install -y curl wget unzip

# Create a health check endpoint
cat > /var/www/html/health.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Health Check</title>
</head>
<body>
    <h1>OK</h1>
    <p>Server is healthy</p>
    <p>Timestamp: $(date)</p>
</body>
</html>
EOF

# Configure Apache to serve health check
echo "Alias /health /var/www/html/health.html" >> /etc/httpd/conf/httpd.conf

# Restart Apache
systemctl restart httpd

# Log the instance startup
echo "Instance started at $(date)" >> /var/log/instance-startup.log 