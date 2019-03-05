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
BITCOIN_CASH_ADDRESS=$(walkingliberty --currency bch address "$bch_wallet")
BITCOIN_ADDRESS=$(walkingliberty --currency btc address "$btc_wallet")

bch_balance=$(walkingliberty --currency bch balance "$bch_wallet") || true

if [ -n "$bch_balance" ]; then
    satoshi_to_bch=$(dc -e "8k $bch_balance 100000000 / p")
    fiat_per_coin=$(fiat_per_coin get bch 2> /dev/null | cut -d '(' -f 2 | cut -d , -f 1)
    fiat_bch=$(printf '$%.2f' "$(dc -e "8k $fiat_per_coin $satoshi_to_bch * p")")
fi

btc_balance=$(walkingliberty --currency btc balance "$btc_wallet") || true

if [ -n "$btc_balance" ]; then
    satoshi_to_btc=$(dc -e "8k $btc_balance 100000000 / p")
    fiat_per_coin=$(fiat_per_coin get btc 2> /dev/null | cut -d '(' -f 2 | cut -d , -f 1)
    fiat_btc=$(printf '$%.2f' "$(dc -e "8k $fiat_per_coin $satoshi_to_btc * p")")
fi


echo "Your Bitcoin Cash address is: $BITCOIN_CASH_ADDRESS"
[ -n "$fiat_bch" ] && echo "Balance: $fiat_bch USD"
echo "Your Bitcoin address is: $BITCOIN_ADDRESS"
[ -n "$fiat_btc" ] && echo "Balance: $fiat_btc USD"
echo "Your Bitmessage address is: $BITMESSAGE_ADDRESS"
echo "Your brainkey public 'username' is: $PUBLIC"
echo "(Can be used like: $EMAIL_ADDRESS with a password of $EMAIL_PASS)"
echo "# If you haven't registered for mega.nz, first register email, then try:"
echo "megareg --register -n $PUBLIC -e $EMAIL_ADDRESS -p $MEGA_PASS"
echo "# (Use that password, don't change it!)"
echo
echo "# If you want to see a QR code with your Bitcoin/Bitcoin Cash addresses:"
# shellcheck disable=SC2016
echo 'walkingliberty --currency bch address --qr $(brainkey password_hash $(cat ~/.brainvault/hash) bch_wallet)'
# shellcheck disable=SC2016
echo 'walkingliberty --currency btc address --qr $(brainkey password_hash $(cat ~/.brainvault/hash) btc_wallet)'
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
