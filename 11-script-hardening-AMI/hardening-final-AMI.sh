#!/bin/bash

# Se copia el archivo '.google_authenticator' al home de los usuarios 'sysadmin' y 'sysadmin2'
# Este archivo se genera luego de escanear el QR con la aplicacion Google Authenticator
# y validar un OTP en la maquina.

# De esta manera logramos tener (al menos 2 formas de autenticarnos) evitando el
# proceso manual.

mv /.google_authenticator /home/sysadmin/.google_authenticator;
cd /home/sysadmin;
chown sysadmin:sysadmin .google_authenticator;
chmod 400 .google_authenticator;

# Creacion de usuario 'sysadmin2' sin contrasena para no dejarla en texto
# claro en este archivo. Al reiniciarse el servidor, el usuario 'sysadmin'
# puede asignarsela.
useradd -m -d /home/sysadmin2 -s /bin/bash sysadmin2

# Se agrega a grupo 'sudo' con control total.
usermod -aG sudo sysadmin2

# Se repite el proceso del archivo '.google_authenticator' para usuario 'sysadmin2'

mv /.google_authenticator3 /home/sysadmin2/.google_authenticator;
cd /home/sysadmin2;
chown sysadmin2:sysadmin2 .google_authenticator;
chmod 400 .google_authenticator;

# Se copian las claves publicas de SSH que vamos a necesitar para loggearnos
# al server, ya sea como 'sysadmin' o 'sysadmin2'.

mkdir -p /home/sysadmin/.ssh;
mv /authorized_keys_sysadmin /home/sysadmin/.ssh/authorized_keys;
chown sysadmin:sysadmin -R /home/sysadmin
chmod 700 /home/sysadmin/.ssh
chmod 400 /home/sysadmin/.ssh/authorized_keys;

mkdir -p /home/sysadmin2/.ssh;
mv /authorized_keys_sysadmin2 /home/sysadmin2/.ssh/authorized_keys;
chown sysadmin2:sysadmin2 -R /home/sysadmin2
chmod 700 /home/sysadmin2/.ssh
chmod 400 /home/sysadmin2/.ssh/authorized_keys;

# Se cambia la configuracion por defecto de SSH

mv /sshd_config /etc/ssh/sshd_config;
mv /sshd /etc/pam.d/sshd

systemctl restart ssh;

# Se copian los modulos recomendados por Lynis para deshabilitar

mv /*.conf /etc/modprobe.d/

# Se setean los banners

mv /issue* /etc/

# Se copian archivos de configuracion de AIDE

mv /aide /etc/default/
mv /aide.conf /etc/aide/

# Se inicializa la base de datos
aide --init --config /etc/aide/aide.conf

# Se copia la base de datos generada a la base de datos principal.
cp -p /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Se copian archivos de configuracion de fail2ban

mv /paths-debian.conf /etc/fail2ban/paths-debian.conf
mv /jail.local /etc/fail2ban/jail.local

systemctl restart fail2ban

# Se copia este archivo que contiene las politicas de password
# recomendadas por Lynis.

mv /login.defs /etc/

# Eliminar archivos

rm /instalar-paquetes-AMI.sh
rm /eliminar-paquetes.sh
rm /nftables-AMI.sh
