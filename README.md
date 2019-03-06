Use this in your own salt repository. Clone this as your_salt_base/salt/hedron

Include via top.sls or includes, like:

```
include:
  - hedron.tor
```

Based entirely around Debian Stretch.

Has helpers for spawning with salt. `cd` under your salt directory, then `salt/hedron/salt_utilities/files/saltspawn.sh hostname --days 1`, for example.

See example Pillar folder and the stub grains folder as things to copy into your base salt folder.

Boiler plate examples to follow.
