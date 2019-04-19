#!/bin/sh

set -e

BRAINVAULT_HASH=$(cat ~/.brainvault/hash)
EMAIL_DOMAIN=$(cat ~/.brainvault/email_domain)

PUBLIC=$(brainkey public "$BRAINVAULT_HASH")
EMAIL_PASS=$(brainkey password "$BRAINVAULT_HASH" "$EMAIL_DOMAIN")
EMAIL_ADDRESS="$PUBLIC@$EMAIL_DOMAIN"
MEGA_PASS=$(brainkey password "$BRAINVAULT_HASH" mega.nz)
BITMESSAGE_ADDRESS=$(cat ~/.brainvault/bitmessage_address)
bch_wallet=$(brainkey password_hash "$BRAINVAULT_HASH" bch_wallet)
btc_wallet=$(brainkey password_hash "$BRAINVAULT_HASH" btc_wallet)
bsv_wallet=$(brainkey password_hash "$BRAINVAULT_HASH" bsv_wallet)
BITCOIN_CASH_ADDRESS=$(walkingliberty --currency bch address "$bch_wallet")
BITCOIN_ADDRESS=$(walkingliberty --currency btc address "$btc_wallet")
BITCOIN_SV_ADDRESS=$(walkingliberty --currency bsv address "$bsv_wallet")

bch_balance=$(walkingliberty --currency bch balance "$bch_wallet" --unit bch) || true
btc_balance=$(walkingliberty --currency btc balance "$btc_wallet" --unit btc) || true
bsv_balance=$(walkingliberty --currency bsv balance "$bsv_wallet" --unit bsv) || true

fiat_bch=$(walkingliberty --currency bch balance "$bch_wallet" --unit usd) || true
fiat_btc=$(walkingliberty --currency btc balance "$btc_wallet" --unit usd) || true
fiat_bsv=$(walkingliberty --currency bsv balance "$bsv_wallet" --unit usd) || true


echo "Your Bitcoin Cash address is: $BITCOIN_CASH_ADDRESS"
[ -n "$bch_balance" ] && echo "Balance: $bch_balance"
[ -n "$fiat_bch" ] && echo "($fiat_bch USD)"
echo "Your Bitcoin address is: $BITCOIN_ADDRESS"
[ -n "$btc_balance" ] && echo "Balance: $btc_balance"
[ -n "$fiat_btc" ] && echo "($fiat_btc USD)"
echo "Your Bitcoin SV address is: $BITCOIN_SV_ADDRESS"
[ -n "$bsv_balance" ] && echo "Balance: $bsv_balance"
[ -n "$fiat_bsv" ] && echo "($fiat_bsv USD)"

echo "Your Bitmessage address is: $BITMESSAGE_ADDRESS"
echo "Your brainkey public 'username' is: $PUBLIC"
echo "(Can be used like: $EMAIL_ADDRESS with a password of $EMAIL_PASS)"
echo "# If you haven't registered for mega.nz, first register email, then try:"
echo "megareg --register -n $PUBLIC -e $EMAIL_ADDRESS -p $MEGA_PASS"
echo "# (Use that password, don't change it!)"
echo
echo "# If you want to see a QR code with your Bitcoin/Bitcoin Cash/SV addresses:"
# shellcheck disable=SC2016
echo 'walkingliberty --currency bch address --qr $(brainkey password_hash $(cat ~/.brainvault/hash) bch_wallet)'
# shellcheck disable=SC2016
echo 'walkingliberty --currency btc address --qr $(brainkey password_hash $(cat ~/.brainvault/hash) btc_wallet)'
# shellcheck disable=SC2016
echo 'walkingliberty --currency bsv address --qr $(brainkey password_hash $(cat ~/.brainvault/hash) bsv_wallet)'
echo
echo "# If you want to double mix Bitcoin into your wallet (will give you a QR code to send to)"
echo "doublemixer mix --currency bitcoin --output_address $BITCOIN_ADDRESS"
echo
echo "# Launching a Debian Stretch server with SporeStack, paying with Bitcoin Cash:"
echo "sporestack_helper bch normal AnyOldHostname --days 1"
echo "# Launching a Debian Stretch hidden server with SporeStack, paying with Bitcoin:"
echo "sporestack_helper btc hidden AnotherHostname --days 1"
echo
echo "You are using the dwm window manager. To launch a new terminal, alt+shift+enter"
echo "To learn how to use dwm: man dwm"
echo
echo 'If you want to register your email account, click in the password field in your browser,'
echo 'press alt+p, type brainkey_login and press enter, then select elude.in and press enter.'
echo 'You can also generate new passwords by typing a different domain, say "yandex.com".'
echo 'It will be a suggested option the next time you run brainkey_login.'
echo
echo 'Be sure to check out /usr/local/share/doc/vagabond.md if you have not already.'
echo
echo "Don't forget to set root@vagabondworkstation's password with passwd before you reboot,"
echo "if this is a first time install and you haven't already."
echo
echo 'To see this again, run brainvault-banner'
echo
