#!/bin/bash

yum update -y
yum install -y httpd
echo "<h1>This is test</h1>" > /var/www/html/index.html
systemctl start httpd
