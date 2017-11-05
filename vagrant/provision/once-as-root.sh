#!/usr/bin/env bash

#== Import script args ==

timezone=$(echo "$1")

#== Bash helpers ==

function info {
  echo " "
  echo "--> $1"
  echo " "
}

#== Provision script ==

info "Provision-script user: `whoami`"

info "Configure timezone"
timedatectl set-timezone ${timezone} --no-ask-password

info "Disable SELinux by default."
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux && \
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config && \
setenforce 0

info "Added IUS Repository"
cd ~
curl 'https://setup.ius.io/' -o setup-ius.sh
bash setup-ius.sh

info "Update OS software"
yum update -y

info "Install additional software"
yum -y install nginx wget
yum -y remove mariadb-libs
yum -y install mariadb101u mariadb101u-server mariadb101u-libs
yum -y install postfix
yum -y install php70u php70u-pdo php70u-mysqlnd php70u-opcache php70u-xml php70u-mcrypt php70u-gd php70u-devel php70u-mysql php70u-intl php70u-mbstring php70u-bcmath php70u-json php70u-iconv php70u-soap php70u-fpm-nginx php70u-cli


info "Adding services to autostart"
systemctl enable mariadb.service
systemctl enable nginx.service
systemctl enable php-fpm.service

info "Starting services"
systemctl start mariadb.service
systemctl start nginx.service
systemctl start php-fpm.service

info "Configure PHP-FPM"
sed -i 's/user = php-fpm/user = vagrant/g' /etc/php-fpm.d/www.conf
sed -i 's/group = php-fpm/group = vagrant/g' /etc/php-fpm.d/www.conf
sed -i 's/owner = php-fpm/owner = vagrant/g' /etc/php-fpm.d/www.conf
sed -i 's/.*listen\.owner.*/listen\.owner = vagrant/g' /etc/php-fpm.d/www.conf
sed -i 's/.*listen\.group.*/listen\.group = vagrant/g' /etc/php-fpm.d/www.conf
sed -i 's/.*listen\.mode.*/listen\.mode = 0660/g' /etc/php-fpm.d/www.conf
sed -i 's/listen = 127.*/listen = \/var\/run\/php-fpm\/php-fpm\.sock/g' /etc/php-fpm.d/www.conf
chmod 755 /var/lib/php/fpm/
chmod 1733 /var/lib/php/fpm/{opcache,session,wsdlcache}
echo "Done!"

info "Configure NGINX"
sed -i 's/user nginx/user vagrant/g' /etc/nginx/nginx.conf
echo "Done!"

info "Enabling site configuration"
ln -s /app/vagrant/nginx/app.conf /etc/nginx/conf.d/app.conf
echo "Done!"

info "Configure MySQL"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf
mysql -u root <<< "CREATE USER 'root'@'%' IDENTIFIED BY ''"
mysql -u root <<< "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'"
mysql -u root <<< "FLUSH PRIVILEGES"
echo "Done!"

info "Initailize databases for MySQL"
mysql -u root <<< "CREATE DATABASE sitedb"
mysql -u root <<< "CREATE DATABASE sitedb_test"
echo "Done!"

systemctl restart mariadb.service
systemctl restart nginx.service
systemctl restart php-fpm.service


info "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer