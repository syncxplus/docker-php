# Default configuration

- **/etc/apache2**
  - apache2.conf
  - conf-available
  - conf-enabled
  - envvars
  - magic
  - mods-available
  - mods-enabled
  - ports.conf
  - sites-available
  - sites-enabled

- **/etc/apache2/sites-enabled**

*lrwxrwxrwx 1 root root 000-default.conf -> ../sites-available/000-default.conf*

```sh
000-default.conf
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
