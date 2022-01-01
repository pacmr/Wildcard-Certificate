#!/usr/bin/env bash
#
# Usage: signed_wildcard_cert.sh
#
# Creates a CA cert and then generates an SSL wildcard certificate 
# signed by that CA for the given hostname.
#


#########################################
### Put inhere your personal information 
#########################################
Country=NL
State=WL
City=SomeCity
Organization=MyHome

# The name of your domain
NAME=athome.lan
#########################


CLR="`tput clear`"

give_return()
{
   echo
   echo -ne 'Give <RETURN> to proceed ' ; read answer
}

echo $CLR

# set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#########################################
### CA Root private key create
#########################################
CA_KEY=$DIR/root_CA.key

if ! [ -f $CA_KEY ] ; then

    echo "###############################################"
    echo "# !!! Remember next secret private pass phrase" 
    echo "###############################################"

    give_return

    openssl genrsa -des3 -out $CA_KEY 2048

fi

#########################################
### CA Root pem certificaat maken
#########################################
CA_PEM=$DIR/root_CA.pem
if ! [ -f $CA_PEM ] ; then

    HOST_EXT=$DIR/$NAME.ext
    echo >$HOST_EXT
    echo >>$HOST_EXT basicConstraints=CA:true
    echo >>$HOST_EXT [req]
    echo >>$HOST_EXT distinguished_name = req_distinguished_name
    echo >>$HOST_EXT prompt = no
    echo >>$HOST_EXT [req_distinguished_name]
    echo >>$HOST_EXT C = $Country
    echo >>$HOST_EXT ST = $State
    echo >>$HOST_EXT L = $City
    echo >>$HOST_EXT O = $Organization
    echo >>$HOST_EXT OU = $NAME
    echo >>$HOST_EXT CN = $NAME

    echo "###############################################"
    echo "# Paste secret private pass phrase" 
    echo "###############################################"

    give_return

    openssl req -new -key $CA_KEY -out $CA_PEM -config $HOST_EXT

    rm $HOST_EXT

fi
#########################################
### CA Root public certificaat create
#########################################
CA_CERT=$DIR/root_CA.crt

if ! [ -f $CA_CERT ] ; then

    HOST_ca_EXT=$DIR/$NAME.ca.ext
    echo >$HOST_ca_EXT
    echo >>$HOST_ca_EXT basicConstraints=CA:true

    echo "###############################################"
    echo "# Paste secret private pass phrase" 
    echo "###############################################"

    give_return

    openssl x509 -req -days 7300 -in $CA_PEM -signkey $CA_KEY -extfile $HOST_ca_EXT -out $CA_CERT

    rm $HOST_ca_EXT
fi

#########################################
### CA Root convert to der format create
#########################################
CA_der_CERT=$DIR/root_CA_der.crt

if ! [ -f $CA_der_CERT ] ; then

    openssl x509 -inform PEM -outform DER -in $CA_CERT -out $CA_der_CERT 

fi

#########################################
### Certificate private key create
#########################################
HOST_KEY=$DIR/server.key

# Every time you run this script a new server.key is created 
# This has to happen every year. (ea browser chrome) 
rm $HOST_KEY

[ -f $HOST_KEY ] || openssl genrsa -out $HOST_KEY 2048

#########################################
### Certificate public certificaat create
#########################################
HOST_CERT=$DIR/server.crt

# Every time you run this script a new server.key is created 
# This has to happen every year. (ea browser chrome) 
rm $HOST_CERT

if ! [ -f $HOST_CERT ] ; then
    HOST_CSR_EXT=$DIR/$NAME.csr.ext
    echo >$HOST_CSR_EXT
    echo >>$HOST_CSR_EXT [req]
    echo >>$HOST_CSR_EXT distinguished_name = req_distinguished_name
    echo >>$HOST_CSR_EXT prompt = no
    echo >>$HOST_CSR_EXT [req_distinguished_name]
    echo >>$HOST_CSR_EXT C = $Country
    echo >>$HOST_CSR_EXT ST = $State
    echo >>$HOST_CSR_EXT L = $City
    echo >>$HOST_CSR_EXT O = $Organization
    echo >>$HOST_CSR_EXT OU = *.$NAME
    echo >>$HOST_CSR_EXT CN = *.$NAME

    HOST_CSR=$DIR/$NAME.csr.pem
    [ -f $HOST_CSR ] || openssl req -new -key $HOST_KEY -out $HOST_CSR -config $HOST_CSR_EXT

    rm $HOST_CSR_EXT

    HOST_EXT=$DIR/$NAME.ext
    echo >$HOST_EXT
    echo >>$HOST_EXT authorityKeyIdentifier=keyid,issuer
    echo >>$HOST_EXT basicConstraints=CA:false
    echo >>$HOST_EXT keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    echo >>$HOST_EXT subjectAltName = @alt_names
    echo >>$HOST_EXT
    echo >>$HOST_EXT [alt_names]
    echo >>$HOST_EXT DNS.1 = *.$NAME

    echo "###############################################"
    echo "# Paste secret private pass phrase" 
    echo "###############################################"

    give_return

    openssl x509 -req -in $HOST_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $HOST_CERT -days 398 -sha256 -extfile $HOST_EXT

    rm $HOST_EXT
    rm $HOST_CSR
    rm $DIR/*.srl
fi

#########################################
### Certificate pfx certificaat create
#########################################
HOST_PFX=$DIR/server.pfx

# Every time you run this script a new server.pfx is created
# This has to happen every year. (ea browser chrome)
rm $HOST_PFX

if ! [ -f $HOST_PFX ] ; then
    openssl pkcs12 -export -out $HOST_PFX -inkey $HOST_KEY -in $HOST_CERT
fi

give_return
echo $CLR

echo "#################################################################"
echo "# "
echo "# - root_CA.key "
echo "# The root_CA.key file is your CA root private key."
echo "# Keep this one save and the password to create it."
echo "# "
echo "# - root_CA_der.crt "
echo "# The root_CA_der.crt file is your CA root certificate."
echo "# It is valid for 20 years, so generated ones. :-)"
echo "# Import this certificaat on Android (9), Iphone, Windows and Linux."
echo "#  "
echo "# - server.key and server.crt "
echo "# These are to be generated every year. "
echo "# Copy them to your ssl dir in your webserver. "
echo "# This certificate is an wildcard certificate: *.$name "
echo "#  "
echo "# - server.pfx "
echo "# This is an combination of server.key and server.crt "
echo "# Some applications need this, ie jellyfin "
echo "# This is to be generated every year. "
echo "# This certificate is an wildcard certificate: *.$name "
echo "#  "
echo "#################################################################"

give_return

ls -l

exit


# Check how the certificate is formatted
# For DER
# openssl x509 -in <cert.crt> -text -inform der
#
# For PEM
# openssl x509 -in <cert.crt> -text -inform pem
