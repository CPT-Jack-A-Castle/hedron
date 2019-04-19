#!/bin/sh

set -e

usage() {
    echo "Usage: $0 currency, networking mode, hostname, optional arguments"
    echo "$0: <btc|bch|bsv> <normal|hidden> <SomeReferenceName> [optional arguments]"
    exit 1
}

CURRENCY=$1
MODE=$2
HOSTNAME=$3

# Argument validation.
case "$CURRENCY" in
    btc)
        ;;
    bch)
        ;;
    bsv)
        ;;
    *)
        usage
        ;;
esac

case "$MODE" in
    normal)
        ;;
    hidden)
        ;;
    *)
        usage
        ;;
esac

[ -z "$HOSTNAME" ] && usage
#

shift 3

keyplease generate "$HOSTNAME"

PUBLIC_KEY_FILE=$(keyplease public "$HOSTNAME")
PRIVATE_KEY_FILE=$(keyplease private "$HOSTNAME")

WALLET=$(brainkey password_hash "$(cat ~/.brainvault/hash)" "$CURRENCY"_wallet)

if [ "$MODE" = 'normal' ]; then
    # We launch these with preboxed operating systems and SSH keys for speed.
    # shellcheck disable=SC2048,SC2086
    sporestackv2 launch "$HOSTNAME" --operating_system debian-9 --ssh_key_file "$PUBLIC_KEY_FILE" --currency "$CURRENCY" --walkingliberty_wallet "$WALLET" $*
    IP4=$(sporestackv2 get_attribute "$HOSTNAME" network_interfaces | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
    IP6=$(sporestackv2 get_attribute "$HOSTNAME" sshhostname)
    echo
    echo 'Server should be ready within a few minutes.'
    echo
    echo 'Connect with:'
    echo "ssh -i $PRIVATE_KEY_FILE root@$IP4"
    echo 'Or:'
    echo "ssh -i $PRIVATE_KEY_FILE root@$IP6"

else

    # Tor/hidden servers only support iPXE, which is slower, especially over Tor.
    # shellcheck disable=SC2048,SC2086
    ipxe-stretch "$PUBLIC_KEY_FILE" | sporestackv2 launch "$HOSTNAME" --api_endpoint http://spore64i5sofqlfz5gq2ju4msgzojjwifls7rok2cti624zyq3fcelad.onion --ipxescript_stdin True --currency "$CURRENCY" --walkingliberty_wallet "$WALLET" --disk 5 --ipv4 tor --ipv6 tor $*
    ONION=$(sporestackv2 get_attribute "$HOSTNAME" sshhostname)
    echo
    echo 'Server should be ready in a while, maybe 20 minutes or more.'
    echo 'If you want to watch its progress:'
    echo "sporestackv2 serialconsole $HOSTNAME"
    echo '(Press ctrl+\ to exit)'
    echo
    echo "When it's done:"
    echo "ssh -i $PRIVATE_KEY_FILE root@$ONION"

fi

echo
echo 'Consider installing your "main" SSH key (~/.ssh/id_rsa.pub) or otherwise be sure'
echo 'to backup with brainvault-persistence as keyplease keys are not deterministic.'
echo 'keyplease keys are intended to help protect your identity by using a different'
echo 'key per host at build time. This way, SporeStack, nor Digital Ocean, Vultr,'
echo 'etc, see your actual "primary" key.'
echo
echo "The hostname you provided, $HOSTNAME, is for internal reference only and not sent"
echo 'to SporeStack. You must use a unique hostname for every server. If you want to'
echo 'reuse a hostname from a dead server, delete ~/.keyplease/HOSTNAME, ~/.keyplease/HOSTNAME.pub,'
echo 'and ~/.sporestackv2/HOSTNAME.json'
echo
