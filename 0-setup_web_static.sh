#!/usr/bin/env bash
# Bash script that sets up your web servers for the deployment of web_static
apt-get update
apt-get install -y nginx
mkdir -p /data/web_static/releases/test/ /data/web_static/shared/ /var/www/html /var/www/error
chmod -R 755 /var/www
echo 'Hello World!' > /var/www/html/index.html
echo -e "Ceci n\x27est pas une page" > /var/www/error/404.html

# Create a symbolic link
[ -d /data/web_static/current ] && rm -rf /data/web_static/current
ln -sf /data/web_static/releases/test/ /data/web_static/current
ln -sf '/etc/nginx/sites-available/default' '/etc/nginx/sites-enabled/default'

# Server configuration
CONFIG="server {
	listen 80 default_server;
	listen [::]:80 default_server;
	server_name _;
	index index.html index.htm;
	error_page 404 /404.html;
	add_header X-Served-By \$hostname;
	location / {
		root /var/www/html/;
		try_files \$uri \$uri/ =404;
	}
	location /hbnb_static/ {
		alias /data/web_static/current/;
		try_files \$uri \$uri/ =404;
	}
	if (\$request_filename ~ redirect_me) {
		rewrite ^ https://st-pardon.github.io/portfolio-landing-page permanent;
	}
	location = /404.html {
		root /var/www/error/;
		internal;
	}
}"

# HTML file
HTML_FILE="<!DOCTYPE html>
<html lang='en-US'>
	<head>
		<meta charset=\"utf-8\">
		<meta name=\"description\" content=\"AirBnB Clone\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
		<title>AirBnB Clone</title>
	</head>
	<body>
		<header>
			<h1>AirBnB</h1>
		</header>
		<h2>Welcome to AirBnB!</h2>
	<body>
</html>
"

echo -e "$HTML_FILE" > /data/web_static/releases/test/index.html
bash -c "echo -e '$CONFIG' > /etc/nginx/sites-available/default"
ln -sf '/etc/nginx/sites-available/default' '/etc/nginx/sites-enabled/default'
chown -R ubuntu:ubuntu /data/

# start or restart server
if [ "$(pgrep -c nginx)" -le 0 ]; then
	service nginx start
else
	service nginx restart
fi
