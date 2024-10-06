#!/bin/bash

# Se copia el archivo '.google_authenticator' al home del usuario 'sysadmin'
# Este archivo se genera luego de escanear el QR con la aplicacion Google Authenticator
# y validar un OTP en la maquina.

# De esta manera logramos tener (al menos 2 formas de autenticarnos) evitando el
# proceso manual.

mv /.google_authenticator /home/sysadmin/.google_authenticator;
cd /home/sysadmin;
chown sysadmin:sysadmin .google_authenticator;
chmod 400 .google_authenticator;

# Creacion de usuario 'helpdesk1' sin contrasena para no dejarla en texto
# claro en este archivo. Al reiniciarse el servidor, el usuario 'sysadmin'
# puede asignarsela.
useradd -m -d /home/helpdesk1 -s /bin/bash helpdesk1

# Se repite el proceso del archivo '.google_authenticator' para usuario 'helpdesk1'

mv /.google_authenticator2 /home/helpdesk1/.google_authenticator;
cd /home/helpdesk1;
chown helpdesk1:helpdesk1 .google_authenticator;
chmod 400 .google_authenticator;

# Se extiende el archivo 'sudoers' con limitaciones para los usuarios de
# help desk como 'helpdesk1'.
#
# Esta es la manera adecuada de hacerlo de forma automatica. Si fuera manual
# se recomienda enfaticamente usar 'visudo' y no editarlo por ejemplo con 'sed'

mv /limitaciones-usuarios-helpdesk /etc/sudoers.d/limitaciones-usuarios-helpdesk

# Se copian las claves publicas de SSH que vamos a necesitar para loggearnos
# al server, ya sea como 'sysadmin' o como 'helpdesk1'

mkdir -p /home/sysadmin/.ssh;
mv /authorized_keys_sysadmin /home/sysadmin/.ssh/authorized_keys;
chown sysadmin:sysadmin -R /home/sysadmin
chmod 700 /home/sysadmin/.ssh
chmod 400 /home/sysadmin/.ssh/authorized_keys;

mkdir -p /home/helpdesk1/.ssh;
mv /authorized_keys_helpdesk1 /home/helpdesk1/.ssh/authorized_keys;
chown helpdesk1:helpdesk1 -R /home/helpdesk1
chmod 700 /home/helpdesk1/.ssh
chmod 400 /home/helpdesk1/.ssh/authorized_keys;

# Se cambia la configuracion por defecto de SSH

# Puerto 17484 en vez de 22. Evita muchas entradas en los logs por bots que
# escanean el puerto por defecto.

sed -i "s/#Port 22/Port 17484/" /etc/ssh/sshd_config

# Se deshabilita el login del usuario root (que ademas no tiene permitido el login:
# ver archivo 'preseed.cfg' parte 'B.4.5. Account setup')

sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config

# Permite que se pueda ingresar el codigo de verificacion

sed -i "s/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/" /etc/ssh/sshd_config

# Se definen los metodos de autenticacion: con key y codigo de verificacion.

echo "AuthenticationMethods publickey,keyboard-interactive" >> /etc/ssh/sshd_config

# Insertar 'auth required pam_google_authenticator.so' en la quinta linea del archivo /etc/pam.d/sshd

sed -i '5i auth required pam_google_authenticator.so' /etc/pam.d/sshd

# Finalmente reiniciamos el servicio

systemctl restart ssh;

# Invocar al firewall a traves de 'nftables'
cd ../nftables
./nftables.sh
