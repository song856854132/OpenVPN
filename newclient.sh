#! /bin/bash
# Script to automate creating new OpenVPN clients
#
# H Cooper - 05/02/11
# Y Frolov - 08/06/16 - bundle config added (unified format)
# Usage: newclient.sh <common-name>

echo "Script to generate unified config for Windows App"
echo "sage: newclient.sh <common-name>"

# Set vars
OPENVPN_DIR=/etc/openvpn
OPENVPN_RSA_DIR=/etc/openvpn/easy-rsa
OPENVPN_KEYS=$OPENVPN_RSA_DIR/keys
BUNDLE_DIR=/etc/openvpn/bundles

# Either read the CN from ! or prompt for it
if [ -z "!" ]
    then echo -n "Enter new client common name (CN): "
    read -e CN
else
    CN=$1
fi

# Ensure CN isn't blank
if [ -z "$CN" ]
    then echo "You must provide a CN."
    exit
fi

# Check the CN doesn't already exist
if [ -f $OPENVPN_KEYS/$CN.crt ]
    then echo "Error: certificate with the CN $CN alread exists!"
    echo "    $OPENVPN_KEYS/$CN.crt"
    exit
fi

# Establish the default variables
export EASY_RSA="/etc/openvpn/easy-rsa"
export OPENSSL="openssl"
export PKCS11TOOL="pkcs11-tool"
export GREP="grep"
export KEY_CONFIG=`$EASY_RSA/whichopensslcnf $EASY_RSA`
export KEY_DIR="$EASY_RSA/keys"
export PKCS11_MODULE_PATH="dummy"
export PKCS11_PIN="dummy"
export KEY_SIZE=2048
export CA_EXPIRE=3650
export KEY_EXPIRE=1825
export KEY_COUNTRY="US"
export KEY_PROVINCE="CA"
export KEY_CITY="SanFrancisco"
export KEY_ORG="Fort-Funston"
export KEY_EMAIL="my@vpn.net"
export KEY_OU="MyVPN"
export KEY_NAME="EasyRSA"

# Copied from build-key script (to ensure it works!)
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --batch $CN

# Add all certs to unified client config file

# Default config for client
cp $OPENVPN_DIR/client.ovpn $BUNDLE_DIR/$CN.ovpn

# CA
echo "<ca>"  >> $BUNDLE_DIR/$CN.ovpn
cat $OPENVPN_KEYS/ca.crt >> $BUNDLE_DIR/$CN.ovpn
echo "</ca>" >> $BUNDLE_DIR/$CN.ovpn

# Client cert
echo "<cert>" >> $BUNDLE_DIR/$CN.ovpn
cat $OPENVPN_KEYS/$CN.crt >> $BUNDLE_DIR/$CN.ovpn
echo "</cert>" >> $BUNDLE_DIR/$CN.ovpn

# Client key
echo "<key>" >> $BUNDLE_DIR/$CN.ovpn
cat $OPENVPN_KEYS/$CN.key >> $BUNDLE_DIR/$CN.ovpn
echo "</key>" >> $BUNDLE_DIR/$CN.ovpn

if openvpn --version | grep 2.3; then
    # ta tls auth OpenVPN 2.3.x
    echo "key-direction 1" >> $BUNDLE_DIR/$CN.ovpn
    echo "<tls-auth>"  >> $BUNDLE_DIR/$CN.ovpn
    cat $OPENVPN_KEYS/ta.key >> $BUNDLE_DIR/$CN.ovpn
    echo "</tls-auth>" >> $BUNDLE_DIR/$CN.ovpn
else
    # ta tls crypt OpenVPN 2.4.x
    echo "<tls-crypt>"  >> $BUNDLE_DIR/$CN.ovpn
    cat $OPENVPN_KEYS/ta.key >> $BUNDLE_DIR/$CN.ovpn
    echo "</tls-crypt>" >> $BUNDLE_DIR/$CN.ovpn
fi

# DH key
echo "<dh>" >> $BUNDLE_DIR/$CN.ovpn
cat $OPENVPN_KEYS/dh.pem >> $BUNDLE_DIR/$CN.ovpn
echo "</dh>" >> $BUNDLE_DIR/$CN.ovpn

#echo ""
echo "COMPLETE! Copy the new unified config from here: /etc/openvpn/bundles/$CN.ovpn"
