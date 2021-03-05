# OpenVPN-setup
!!!Not success yet!!!

OpenVPN Features:
- With built-in EASY_RSA, 
- Setup new server with one command in a couple of minutes;
- Creates client config in unified format;

Pre-progress: First ,mkdir at /etc/openvpn;
	      Second, move all directory an file into it, especially pkitool and associated ca files. 

Build: ./openvpnsetup.sh 

Before enabling IPv6 support ensure that your machine have IPv6 address.
Note: iptables rule allow port 22 tcp (ssh) by default, if you have sshd on another port modify script before execution.

After script is complete you can create client config files in unified format with /etc/openvpn/newclient.sh script.
Usage: ./newclient.sh <clientname>
Config file will be saved to /etc/openvpn/bundles/clientname.ovpn and it ready to use (even on mobile device).





