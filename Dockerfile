# Original credit: https://github.com/jpetazzo/dockvpn

# latest alpine image at 2022.07.01
FROM alpine:3.16.0

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

# Internally uses port 1194/udp, remap e.g. by using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/* && \
    touch $OPENVPN/vars

VOLUME ["/etc/openvpn"]

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
