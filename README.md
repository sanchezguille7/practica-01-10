# Practica 01-10
Crearemos una arquitectura de **alta disponibilidad** que sea **escalable** y **redundante**, de modo que podamos balancear la carga entre todos los frontales web.
Estructura del repositorio:
```
├── README.md
├── conf
│   ├── load-balancer.conf
│   └── 000-default.conf
├── htaccess
│   └── .htaccess
├── php
│   └── index.php
└── scripts
    ├── .env
    ├── install_load_balancer.sh
    ├── install_lamp_frontend.sh
    ├── install_lamp_backend.sh
    ├── setup_letsencrypt_https.sh
    ├── deploy_backend.sh
    └── deploy_frontend.sh
```

El directorio  `scripts`  debe incluir los siguientes archivos:

-   `.env`: Este archivo contiene todas las variables de configuración que se utilizarán en los scripts de Bash.
    
-   `install_load_balancer.sh`: Automatización del proceso de instalación del servidor web Apache como balanceador de carga.
    
-   `install_lamp_frontend.sh`: Automatización del proceso de instalación de la pila LAMP en las máquinas de frontend.
    
-   `install_lamp_backend.sh`: Automatización del proceso de instalación de la pila LAMP en la máquina de backend.
    
-   `setup_letsencrypt_https.sh`: Automatización del proceso de solicitar un certificado **SSL/TLS** de **Let’s Encrypt** y configurarlo en el servidor web **Apache** que hace de balanceador de carga.
    
-   `deploy`: Automatización del proceso de instalación de la aplicación web propuesta.
## install_lamp_frontend
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`: Actualizar el sistema operativo y los paquetes instalados.
    
4.  `apt install apache2 -y`: Instala el servidor web **Apache**.
    
5.  `cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf`: Copia el archivo de configuración **000-default.conf** desde el directorio *../conf/* al directorio */etc/apache2/sites-available/*.
    
6.  `sudo apt install php libapache2-mod-php php-mysql -y`: Instala **PHP** y el módulo de **Apache** para **PHP**, así como el soporte de **MySQL** para **PHP**.
    
7.  `systemctl restart apache2`: Reinicia el servicio **Apache** para aplicar los cambios en la configuración.

## install_lamp_backend
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt-get update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt-get upgrade -y`: Realiza la actualización del sistema operativo y paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `apt-get install mysql-server -y`: Instala el servidor **MySQL**.
    
6.  `sed -i "s/127.0.0.1/$MYSQL_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf`: Modifica el archivo de configuración de **MySQL** para usar la dirección IP especificada en lugar de 127.0.0.1.
    
7.  `sudo mysql -u root <<< "DROP USER IF EXISTS '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL';"`: Elimina el usuario de la base de datos si ya existe.
    
8.  `sudo mysql -u root <<< "CREATE USER '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';"`: Crea un nuevo usuario de base de datos.
    
9.  `sudo mysql -u root <<< "GRANT ALL PRIVILEGES ON \`$WORDPRESS_DB_NAME`.* TO '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL';"`: Concede todos los privilegios al nuevo usuario sobre la base de datos especificada.
    
10.  `sudo mysql -u root <<< "FLUSH PRIVILEGES;"`: Recarga los privilegios de **MySQL** para aplicar los cambios.
    
11.  `systemctl restart mysql`: Reinicia el servicio **MySQL** para que los cambios en la configuración y privilegios tengan efecto.

## install_load_balancer
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`: Actualizar el sistema operativo y los paquetes instalados.
    
4.  `apt install apache2 -y`: Instala el servidor web **Apache**.

5.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
6.  `cp /home/ubuntu/practica-01-10/conf/load-balancer.conf /etc/apache2/sites-available`: Copia el archivo de configuración **load-balancer.conf** desde un directorio específico a */etc/apache2/sites-available/.*
    
7.  -   `s/\$IP_HTTP_SERVER1/$IP_HTTP_SERVER1/`: Reemplaza la variable `$IP_HTTP_SERVER1` con el valor actual de la variable en el archivo **load-balancer.conf.**
    
-   `s/\$IP_HTTP_SERVER2/$IP_HTTP_SERVER2/`: Reemplaza la variable `$IP_HTTP_SERVER2` con el valor actual de la variable en el archivo **load-balancer.conf.**
    
7.  `a2enmod proxy`: Habilita el módulo **proxy** de **Apache**.
    
8.  `a2enmod proxy_http`: Habilita el módulo **proxy_http** de **Apache**.
    
9.  `a2enmod proxy_balancer`: Habilita el módulo **proxy_balancer** de **Apache**.
    
10.  `a2enmod lbmethod_byrequests`: Habilita el módulo **lbmethod_byrequests** de **Apache**.
    
11.  `systemctl restart apache2`: Reinicia el servicio **Apache** para aplicar los cambios en la configuración.
    
12.  `a2ensite load-balancer.conf`: Habilita el sitio configurado en el archivo **load-balancer.conf**.
    
13.  `a2dissite 000-default.conf`: Deshabilita el sitio predeterminado.
    
14.  `apache2ctl -S`: Muestra información sobre la configuración actual de **Apache**.
    
15.  `systemctl restart apache2`: Reinicia el servicio **Apache** para aplicar los cambios después de habilitar y deshabilitar sitios.

## deploy_backend
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`: Actualizar el sistema operativo y los paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `systemctl restart mysql`: Reinicia el servicio **MySQL** para aplicar los cambios.
    
6.  `mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"`: Elimina la base de datos de **WordPress** si ya existe.
    
7.  `mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"`: Crea una nueva base de datos de **WordPress**.
    
8.  `mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"`: Elimina el usuario de la base de datos de **WordPress** si ya existe.
    
9.  `mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"`: Crea un nuevo usuario de base de datos de **WordPress** con la contraseña especificada.
    
10.  `mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"`: Concede todos los privilegios al nuevo usuario sobre la base de datos de **WordPress**.
    
11.  `mysql -u root <<< "FLUSH PRIVILEGES"`: Recarga los privilegios de **MySQL** para aplicar los cambios.

## deploy_frontend
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
3.  `apt upgrade -y`:  Actualizar el sistema operativo y los paquetes instalados.
    
4.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
5.  `rm -rf /tmp/wp-cli.phar`: Elimina el archivo **wp-cli.phar** en el directorio temporal */tmp*.
    
6.  `wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp`: Descarga el archivo **wp-cli.phar** desde **GitHub** al directorio */tmp*.
    
7.  `chmod +x wp-cli.phar`: Otorga permisos de ejecución al archivo **wp-cli.phar**.
    
8.  `mv /tmp/wp-cli.phar /usr/local/bin/wp`: Mueve el archivo **wp-cli.phar** al directorio */usr/local/bin/* con el nombre **'wp'**, haciéndolo ejecutable globalmente.
    
9.  `rm -rf /var/www/html/*`: Elimina el contenido del directorio */var/www/html/*.
    
10.  `wp core download --locale=es_ES --path=/var/www/html --allow-root`: Descarga el núcleo de **WordPress** en español al directorio */var/www/html/*.
    
11.  `wp config create ...`: Crea el archivo de configuración de **WordPress** con la información proporcionada.
    
12.  `wp core install ...`: Instala **WordPress** con la configuración y credenciales proporcionadas.
    
13.  `cp ../htaccess/.htaccess /var/www/html/`: Copia el archivo **.htaccess** desde el directorio *../htaccess/* al directorio */var/www/html/*.
    
14.  `rm -rf /var/www/html/wp-config.php`: Elimina el archivo **wp-config.php** existente en */var/www/html/*.
    
15.  `wp plugin install ...`: Instala y activa el plugin **"wps-hide-login"**.
    
16.  `wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root`: Establece la estructura de las **URL** de **WordPress**.
    
17.  `wp rewrite flush`: Actualiza las reglas de reescritura de **URL**.
    
18.  `chown -R www-data:www-data /var/www/html/`: Asigna el **ownership** del directorio */var/www/html/* al usuario y grupo **www-data.**

## setup_letsencrypt_https.sh
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
3.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
4.  `snap install core`: Instala el paquete core de **Snap**.
    
5.  `snap refresh core`: Actualiza el paquete core de **Snap** a la última versión disponible.
    
6.  `apt remove certbot`: Desinstala el paquete **certbot**.
    
7.  `snap install --classic certbot`: Instala **certbot** como un paquete **Snap** en modo clásico.
    
8.  `ln -fs /snap/bin/certbot /usr/bin/certbot`: Crea un enlace simbólico para que el ejecutable **certbot** en */snap/bin/* esté disponible en */usr/bin/.*
    
9.  `certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive`: Utiliza **certbot** para obtener y configurar certificados **SSL/TLS** para el dominio especificado utilizando el método de autenticación de **Apache**. Las opciones proporcionan el correo electrónico del propietario del certificado y aceptan los términos del servicio sin efectuar emails.
    
10.  `echo "Certificado SSL/TLS configurado con éxito para el dominio $CERTIFICATE_DOMAIN."`: Muestra un mensaje indicando que el certificado **SSL/TLS** se configuró con éxito para el dominio especificado.

## .env
Configuramos las variables

    WORDPRESS_DB_NAME=wordpress
    WORDPRESS_DB_USER=wp_user
    WORDPRESS_DB_PASSWORD=wp_pass
    WORDPRESS_DB_HOST=172.31.91.133
    IP_CLIENTE_MYSQL=172.31.91.123
    
    CERTIFICATE_EMAIL=guilleemail@demo.es
    CERTIFICATE_DOMAIN=practicagsm0109.hopto.org
    
    
    WORDPRESS_TITTLE="Sitio Web de IAW"
    WORDPRESS_ADMIN_USER=admin
    WORDPRESS_ADMIN_PASS=admin
    WORDPRESS_ADMIN_EMAIL=demo@demo.es
    
    MYSQL_PRIVATE_IP=172.31.91.133
    
    IP_HTTP_SERVER1=172.31.94.123
    IP_HTTP_SERVER2=172.31.80.68
