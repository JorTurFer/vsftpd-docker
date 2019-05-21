#!/bin/sh

#CREATE THE USER AND THE HOME FOLDER
addgroup -g $FTP_UID -S $FTP_USER
if [[ "$FTP_HOME" != "default" ]]; then
  adduser -u $FTP_UID -D -G $FTP_USER -h $FTP_HOME -s /bin/false  $FTP_USER
  chown $FTP_USER:$FTP_USER $FTP_HOME -R
else
  adduser -u $FTP_UID -D -G $FTP_USER -h /home/$FTP_USER -s /bin/false  $FTP_USER
  chown $FTP_USER:$FTP_USER /home/$FTP_USER/ -R
fi

#UPDATE PASSWORD
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

cp /etc/vsftpd/vsftpd.conf_or /etc/vsftpd/vsftpd.conf

if [[ "$PASV_ENABLE" == "YES" ]]; then
  echo "PASV is enabled"
  echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_max_port=$PASV_MAX" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_min_port=$PASV_MIN" >> /etc/vsftpd/vsftpd.conf
  echo "pasv_address=$PASV_ADDRESS" >> /etc/vsftpd/vsftpd.conf
else
  echo "pasv_enable=NO" >> /etc/vsftpd/vsftpd.conf
fi

if [[ "$ONLY_UPLOAD" == "YES" ]]; then
  echo "This FTP server only accepts upload."
  echo "download_enable=NO" >> /etc/vsftpd/vsftpd.conf
  echo "ftpd_banner=Welcome to FTP Server. Note: this FTP server only accepts upload." >> /etc/vsftpd/vsftpd.conf
elif [[ "$ONLY_DOWNLOAD" == "YES" ]]; then
  echo "This FTP server only accepts download."
  echo "ftpd_banner=Welcome to FTP Server. Note: this FTP server only accepts download." >> /etc/vsftpd/vsftpd.conf
  sed -i 's/write_enable=YES/write_enable=NO/g' /etc/vsftpd/vsftpd.conf
else
  echo "ftpd_banner=Welcome to FTP Server" >> /etc/vsftpd/vsftpd.conf
fi

echo "local_umask=$UMASK" >> /etc/vsftpd/vsftpd.conf

# If TLS flag is set and no certificate exists, generate it
if [ ! -e /etc/ssl/private/vsftpd.pem ] && [ ! -z "$TLS_CN" ] && [ ! -z "$TLS_ORG" ] && [ ! -z "$TLS_C" ]
then
    echo "Generating self-signed certificate"
    mkdir -p /etc/ssl/private
    if [[ "$TLS_USE_DSAPRAM" == "true" ]]; then
        openssl dhparam -dsaparam -out /etc/ssl/private/vsftpd-dhparams.pem 2048
    else
        openssl dhparam -out /etc/ssl/private/vsftpd-dhparams.pem 2048
    fi
	openssl req -subj "/CN=${TLS_CN}/O=${TLS_ORG}/C=${TLS_C}" -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
    # openssl req -subj "/CN=${TLS_CN}/O=${TLS_ORG}/C=${TLS_C}" -days 1826 \
        # -x509 -nodes -newkey rsa:2048 -sha256 -keyout \
        # /etc/ssl/private/vsftpd.pem \
        # -out /etc/ssl/private/vsftpd.pem
    chmod 600 /etc/ssl/private/*.pem
fi

echo "Run container"
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf