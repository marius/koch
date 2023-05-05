server {
    listen 80;
    listen [::]:80;
    server_name _;
    root /var/www/example.com;
}
