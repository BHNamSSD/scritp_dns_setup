#check permission
if [ "$(id -u)" -ne 0 ]; then
	echo "You must rung this file with permission root!"
	exit 1
fi	

#echo "done"

#update
echo "Updating..."
apt update

#echo "Install apache2"
#apt install apache2

#restart apache2

a2enmod ssl
systemctl restart apache2

a2enmod rewrite
systemctl restart apache2


CONF="/etc/apache2/apache2.conf"
echo "Writing to apache2.conf"
echo "<Directory /var/www/html>\n\tAllowOverride ALL\n</Directory>" >> $CONF


#create diretory ssl
SSL_APACHE="/etc/apache2/ssl"
mkdir -p $SSL_APACHE

#test
#SSL_APACHE="/home/kali2/ssl"
#mkdir -p $SSL_APACHE





#enter name file.key and file.crt
read -p "Enter name file.key: " KEY 

read -p "Enter name file.crt: " CRT


#create rsa with openssl out file.key, file.crt
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $SSL_APACHE/$KEY.key -out $SSL_APACHE/$CRT.crt
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $SSL_APACHE/$KEY.key -out $SSL_APACHE/$CRT.crt

#echo $KEY
#echo $CRT


#xoa file
DEFAULT="/etc/apache2/sites-available/000-default.conf"
#path: /etc/apache2/sites-available

#inval
NEWKEY="$SSL_APACHE/$KEY.key" 
NEWCRT="$SSL_APACHE/$KEY.crt"


echo "Creating complete..."
echo $NEWKEY
echo $NEWCRT

echo "Delete file: 000-default.conf"
rm -r $DEFAULT

if ! [ -f $DEFAULT ]; then
	echo "Deleted complete!"
else
	echo "Deleted fail!"
fi

ls -ld $(dirname "$DEFAULT")

#crate file default new


cat > $DEFAULT <<EOF
<VirtualHost *:80>
	RewriteEngine on
	RewriteCond %{HTTPS} !=on
	RewriteRule ^/?(.*) https://%{SERVER_NAME}/\$1 [R=301,L]
</VirtualHost>

<VirtualHost *:443>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

	SSLEngine on
	SSLCertificateFile $NEWCRT
	SSLCertificateKeyFile $NEWKEY
</VirtualHost>
EOF

if [ -f $DEFAULT ]; then
	echo "Created file complete!"
else
	echo "Created fail!"

fi

systemctl restart apache2

echo "Done!"








