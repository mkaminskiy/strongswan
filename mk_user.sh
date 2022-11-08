#!/bin/sh

COUNTRY="RU"
ORG="Kaminskiy VPN"

LIFETIME="730"

echo "Enter userid (no spaces or special characters):"
read USERID

[ -z "$USERID" ] && {
	echo Empty user ID. Cancelling.
	exit 0
}

#echo "Enter fullname:"
#read NAME

#[ -z "$NAME" ] && {
#	echo Empty full name. Cancelling.
#	exit 0
#}

mkdir -p ~/pki/p12 2> /dev/null

ipsec pki --gen --type rsa --size 2048 --outform der > ~/pki/private/$USERID.der
chmod 600 ~/pki/private/$USERID.der

ipsec pki --pub --in ~/pki/private/$USERID.der --type rsa | ipsec pki --issue --lifetime $LIFETIME --cacert ~/pki/cacerts/ca-cert.der --cakey ~/pki/private/ca-key.der --dn "C=$COUNTRY, O=$ORG, CN=$USERID" --san "$USERID" --outform der > ~/pki/certs/$USERID.der
openssl rsa -inform DER -in ~/pki/private/$USERID.der -out ~/pki/private/$USERID.pem -outform PEM

openssl x509 -inform DER -in ~/pki/certs/$USERID.der -out ~/pki/certs/$USERID.pem -outform PEM
openssl pkcs12 -export -inkey ~/pki/private/$USERID.pem -in ~/pki/certs/$USERID.pem -name "$NAME's VPN Certificate" -certfile ~/pki/cacerts/ca-cert.pem -caname "$ORG Root CA" -out ~/pki/p12/$USERID.p12
