FROM alpine

ENV FTP_USER=ftpuser \
    FTP_PASS=supersecret \
    FTP_HOME=default \
    FTP_UID=1000 \
    ONLY_UPLOAD=NO \
    ONLY_DOWNLOAD=NO \
    PASV_ENABLE=NO \
    PASV_ADDRESS=yourserveradress.com \
    PASV_MIN=21100 \
    PASV_MIN=21100 \
    UMASK=022

COPY configs/entrypoint.sh /usr/sbin/

RUN apk update && apk upgrade &&  apk --update --no-cache add vsftpd openssl
RUN mkdir /ftp
RUN chmod 777 -R /ftp

RUN echo "local_enable=YES" >> /etc/vsftpd/vsftpd.conf \
  && echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf \
  && echo "anon_root=/ftp" >> /etc/vsftpd/vsftpd.conf \
  && echo "local_root=/ftp" >> /etc/vsftpd/vsftpd.conf \
  && echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf \
  && echo "background=NO" >> /etc/vsftpd/vsftpd.conf \
  && echo "dirmessage_enable=YES" >> /etc/vsftpd/vsftpd.conf \
  && echo "max_clients=10" >> /etc/vsftpd/vsftpd.conf \
  && echo "max_per_ip=5" >> /etc/vsftpd/vsftpd.conf \
  && echo "write_enable=YES" >> /etc/vsftpd/vsftpd.conf \
  && echo "passwd_chroot_enable=yes" >> /etc/vsftpd/vsftpd.conf \
  && echo "listen_ipv6=NO" >> /etc/vsftpd/vsftpd.conf \
  && echo "seccomp_sandbox=NO" >> /etc/vsftpd/vsftpd.conf \
  && echo "anonymous_enable=YES" /etc/vsftpd/vsftpd.conf \
  && echo "force_local_data_ssl=NO" >> /etc/vsftpd/vsftpd.conf \
  && echo "force_local_logins_ssl=NO" >> /etc/vsftpd/vsftpd.conf \
  && echo "allow_anon_ssl=YES" >> /etc/vsftpd/vsftpd.conf \
  && echo "ssl_enable=YES" >> /etc/vsftpd/vsftpd.conf \
  && echo "rsa_cert_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd/vsftpd.conf \
  && echo "rsa_private_key_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd/vsftpd.conf \
  && cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf_or \
  && chmod +x /usr/sbin/entrypoint.sh

CMD /usr/sbin/entrypoint.sh
