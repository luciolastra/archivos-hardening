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

# Se cambia la configuracion por defecto de SSH.

mv /sshd_config /etc/ssh/sshd_config;
mv /sshd /etc/pam.d/sshd

systemctl restart ssh;

# Deshabilita core dumps.

mv /limits.conf /etc/security/limits.conf
mv /sysctl.conf /etc/sysctl.conf

sysctl -p /etc/sysctl.conf

# Se copian los modulos recomendados por Lynis para deshabilitar.

mv /*.conf /etc/modprobe.d/

# Se setean los banners.

mv /issue* /etc/

# Se copian archivos de configuracion de AIDE.

mv /aide /etc/default/
mv /aide.conf /etc/aide/

# Se inicializa la base de datos y se copia a la principal al final del
# archivo preseed.

# Se copian archivos de configuracion de fail2ban.

echo "sshd_backend = systemd" >> /etc/fail2ban/paths-debian.conf
mv /jail.local /etc/fail2ban/jail.local

systemctl restart fail2ban

# Se copia este archivo que contiene las politicas de password
# recomendadas por Lynis.

mv /login.defs /etc/login.defs

# Se setea el password de GRUB.

mv /40_custom /etc/grub.d/40_custom
chmod 755 /etc/grub.d/40_custom

# Configura las audit rules.

mv /audit.rules /etc/audit/rules.d/
systemctl restart auditd
systemctl enable auditd

# 'adduser' en Debian y Ubuntu 22.04 crean directorios home de usuarios con
# permisos 755. Para cambiarlo de forma que sea segura editamos el valor de 'DIR_MODE'.

sed -i "s/#DIR_MODE=0700/DIR_MODE=0700/" /etc/adduser.conf

# Politicas de contrasenas. Largo minimo 14 caracteres.

sed -i "s/# minlen = 8/minlen = 14/" /etc/security/pwquality.conf

# 3 digitos, 3 caracteres en mayuscula, 3 caracteres en minuscula, 3  caracteres
# de otro tipo.

sed -i "s/# minclass = 0/minclass = 3/" /etc/security/pwquality.conf

# Deshabilitar IPv6.

touch /etc/sysctl.d/60-custom.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/60-custom.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/60-custom.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.d/60-custom.conf

sysctl -p
systemctl restart procps

# Configuracion de upgrades desatendidos.

mv /50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades

# Eliminar archivos.

rm /instalar-paquetes-AMI.sh
rm /eliminar-paquetes.sh
rm /nftables-AMI.sh
