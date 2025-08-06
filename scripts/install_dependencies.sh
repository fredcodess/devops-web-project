#!/bin/bash
# Install httpd
sudo yum install -y httpd

# Install Java
sudo yum install -y java-1.8.0-amazon-corretto

TOMCAT_VERSION=9.0.93
wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -P /tmp
sudo mkdir -p /usr/share/tomcat
sudo tar xzf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /usr/share/tomcat --strip-components=1
sudo chown -R root:root /usr/share/tomcat
sudo chmod -R 755 /usr/share/tomcat

# Create systemd service for Tomcat
sudo bash -c 'cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
Environment="JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto"
ExecStart=/usr/share/tomcat/bin/startup.sh
ExecStop=/usr/share/tomcat/bin/shutdown.sh
User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and enable Tomcat
sudo systemctl daemon-reload
sudo systemctl enable tomcat

# Configure Apache HTTPD proxy
sudo bash -c 'cat << EOF > /etc/httpd/conf.d/tomcat_manager.conf
<VirtualHost *:80>
  ServerAdmin root@localhost
  ServerName app.nextwork.com
  DefaultType text/html
  ProxyRequests off
  ProxyPreserveHost On
  ProxyPass / http://localhost:8080/devops-web-project/
  ProxyPassReverse / http://localhost:8080/devops-web-project/
</VirtualHost>
EOF'

# Start httpd
sudo systemctl enable httpd
sudo systemctl start httpd