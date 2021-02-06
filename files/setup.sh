#!/bin/sh
apt-get -y update > /dev/null 2>&1
apt install -y apache2 > /dev/null 2>&1
cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body style="background-image: linear-gradient(red,orange,yellow,green,blue,indigo,violet);">
  <marquee><h1>Meow World</h1></marquee>
  </body>
</html>
EOM