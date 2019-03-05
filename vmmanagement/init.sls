# This, for now, is indended as an extension to runqemu
# Will likely be very disorganized for some time.
# Dunno if we should include client here or not.

include:
  - .etc_config
  - .user
  - hedron.fiat_per_coin
  - hedron.settlers_of_cryptotan.package
  - hedron.tor
  - .pip
  - hedron.sporestack
  - hedron.keyplease
  - .vmmanagement
  - .sshd
  - .salt

# Disabling this for now.
# It does work.
#  - .hiddenservice
