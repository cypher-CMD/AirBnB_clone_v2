#  Configures a web server for deployment of web_static.

# Nginx configuration file
$config = "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    add_header X-Served-By ${hostname};
    root   /var/www/html;
    index  index.html index.htm;
    location /hbnb_static {
        alias /data/web_static/current;
        index index.html index.htm;
    }
    location /redirect_me {
        return 301 http://st-pardon.github.io/portfolio-landing-page/;
    }
    error_page 404 /404.html;
    location /404 {
      root /var/www/html;
      internal;
    }
}"

package { 'nginx':
  ensure   => 'present',
  provider => 'apt'
} ->

file { '/data':
  ensure  => 'directory'
} ->

file { '/data/web_static':
  ensure => 'directory'
} ->

file { '/data/web_static/releases':
  ensure => 'directory'
} ->

file { '/data/web_static/releases/test':
  ensure => 'directory'
} ->

file { '/data/web_static/shared':
  ensure => 'directory'
} ->

file { '/data/web_static/releases/test/index.html':
  ensure  => 'present',
  content => "<!DOCTYPE html>
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
\n"
} ->

file { '/data/web_static/current':
  ensure => 'link',
  target => '/data/web_static/releases/test'
} ->

exec { 'chown -R ubuntu:ubuntu /data/':
  path => '/usr/bin/:/usr/local/bin/:/bin/'
}

file { '/var/www':
  ensure => 'directory'
} ->

file { '/var/www/html':
  ensure => 'directory'
} ->

file { '/var/www/html/index.html':
  ensure  => 'present',
  content => "Hello world!\n"
} ->

file { '/var/www/html/404.html':
  ensure  => 'present',
  content => "Ceci n'est pas une page\n"
} ->

file { '/etc/nginx/sites-available/default':
  ensure  => 'present',
  content => $config
} ->

exec { 'nginx restart':
  path => '/etc/init.d/'
}