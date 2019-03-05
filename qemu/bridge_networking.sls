include:
  - .bridge_networking_bridge # Setup systemd-networkd files
  - hedron.base.networking # Launch systemd-networkd
  - hedron.radvd

# This used to be at the top of the stack. Now doing more of a layer-3 setup...
#  - hedron.base.networking_legacy_disable # Kill current dhcp and what not.
