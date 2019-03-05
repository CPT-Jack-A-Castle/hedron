#!/bin/sh

# Provides a skeletion for the new brainvault user.

set -e

BRAINVAULT="$1"
BRAINVAULT_HASH="$2"
EMAIL_DOMAIN="$3"

abort() {
    echo "ABORTING: $1" >&2
    exit 1
}

# Sanity checks
# Maybe just better to look for an empty directory?
test -d ~/.ssh && abort "$HOME/.ssh already exists"
test -f ~/.bashrc && abort "$HOME/.bashrc already exists"
# Now made by brainvault.sh. Yuck, this is all kinda hacky.
# test -d ~/.brainvault && abort "$HOME/.brainvault already exists"

# Might be created by brainvault.sh
mkdir ~/.brainvault 2> /dev/null || true
# For use with bvlock
echo "$BRAINVAULT" > ~/.brainvault/raw
# Write out the hash so we don't have to compute it every time, and so we have it as a reference
echo "$BRAINVAULT_HASH" > ~/.brainvault/hash
echo "$EMAIL_DOMAIN" > ~/.brainvault/email_domain

mkdir ~/.brainvault/logins
cd ~/.brainvault/logins
touch "$EMAIL_DOMAIN" mega.nz
cd ~/

mkdir ~/.ssh
brainvault-ssh "$BRAINVAULT_HASH" public > ~/.ssh/id_rsa.pub
brainvault-ssh "$BRAINVAULT_HASH" private > ~/.ssh/id_rsa

mkdir ~/.sandbox
cd ~/.sandbox

mkdir -p bitmessage/.config/PyBitmessage
chmod -R 770 bitmessage

# Use local tor client. This is slower but with the qemu FIN-WAIT bug, helps slow us from getting there.
echo '[bitmessagesettings]
settingsversion = 10
port = 8444
timeformat = %%c
blackwhitelist = black
startonlogon = False
minimizetotray = False
showtraynotifications = True
startintray = False
socksproxytype = SOCKS5
sockshostname = localhost
socksport = 9050
socksauthentication = False
sockslisten = False
socksusername =
sockspassword =
keysencrypted = false
messagesencrypted = false
defaultnoncetrialsperbyte = 1000
defaultpayloadlengthextrabytes = 1000
minimizeonclose = false
maxacceptablenoncetrialsperbyte = 20000000000
maxacceptablepayloadlengthextrabytes = 20000000000
userlocale = system
useidenticons = True
# FIXME
identiconsuffix = BZeNrLFvM9AA
replybelow = False
maxdownloadrate = 0
maxuploadrate = 0
maxoutboundconnections = 8
ttl = 839550
stopresendingafterxdays =
stopresendingafterxmonths =
namecoinrpctype = namecoind
namecoinrpchost = localhost
namecoinrpcuser =
namecoinrpcpassword =
namecoinrpcport = 8336
sendoutgoingconnections = True
onionhostname =
onionport = 8444
onionbindip = 127.0.0.1
smtpdeliver =
hidetrayconnectionnotifications = False
trayonclose = False
willinglysendtomobile = False
opencl = None

' > bitmessage/.config/PyBitmessage/keys.dat

# This writes out the key, itself.
bitmessage_address_generator "$(brainkey password_hash "$BRAINVAULT_HASH" bitmessage)" >> bitmessage/.config/PyBitmessage/keys.dat

# Just grabbing the address
grep -o '\[BM-.*\]' bitmessage/.config/PyBitmessage/keys.dat | tr -d '[]' | head -n 1 > ~/.brainvault/bitmessage_address

# Change the "label" to something more interesting to the user. Hopefully this won't creep them out.
sed -i "s/bitmessage_address_generator/$(brainkey public "$BRAINVAULT_HASH")/" bitmessage/.config/PyBitmessage/keys.dat

# .bashrc
echo 'alias wifi="ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -X root@10.0.2.1 wicd-gtk"' > ~/.bashrc
