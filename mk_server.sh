#!/bin/sh

SRVNAME="vpn.kaminskiy.me"
#IPADDR="vpntest.lan"
#Uncomment only if vpn server is behind a static IP
#IPADDR=$(. /lib/functions/network.sh; network_get_ipaddr ip wan; echo $ip)

COUNTRY="RU"
ORG="Kaminskiy VPN"
#Change above to your org and country code

VALIDDAYS="3650"
LIFETIME="730"

ipsec pki --gen --type rsa --size 4096 --outform der > ~/pki/private/ca-key.der
chmod 600 ~/pki/private/ca-key.der

ipsec pki --self --ca --lifetime $VALIDDAYS --in ~/pki/private/ca-key.der --type rsa --dn "C=$COUNTRY, O=$ORG, CN=$ORG Root CA" --outform der > ~/pki/cacerts/ca-cert.der
openssl x509 -inform DER -in ~/pki/cacerts/ca-cert.der -out ~/pki/cacerts/ca-cert.pem -outform PEM

ipsec pki --print --in ~/pki/cacerts/ca-cert.der

ipsec pki --gen --type rsa --size 4096 --outform der > ~/pki/private/server-key.der
chmod 600 ~/pki/private/server-key.der

ipsec pki --pub --in ~/pki/private/server-key.der --type rsa | ipsec pki --issue --lifetime $LIFETIME --cacert ~/pki/cacerts/ca-cert.der --cakey ~/pki/private/ca-key.der --dn "C=$COUNTRY, O=$ORG, CN=$SRVNAME" --san=$SRVNAME --flag serverAuth --flag ikeIntermediate --outform der > ~/pki/certs/server-cert.der
ipsec pki --print --in ~/pki/certs/server-cert.der
