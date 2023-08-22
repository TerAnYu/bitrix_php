<VirtualHost 0.0.0.0:80>
	ServerName http://eltex-co.com
	ServerAlias eltex-co.com www.eltex-co.com
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/eltex-co.com
	<Directory /var/www/eltex-co.com/ >
#                php_admin_value mbstring.func_overload 2
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>


	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel info

	ErrorLog /var/log/apache2/eltex-co.com-error.log
	CustomLog /var/log/apache2/eltex-co.com-access.log combined
</VirtualHost>
