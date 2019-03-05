#!/bin/sh

set -e

# Assumes we are in the notbit source directory.

# Handle IPC authentication by filesystem permissions and nothing else.
# This is so the "notbit" group can work.

patch -p1 << 'EoF'
diff --git a/src/ntb-ipc.c b/src/ntb-ipc.c
index ec314e9..4e91c71 100644
--- a/src/ntb-ipc.c
+++ b/src/ntb-ipc.c
@@ -888,21 +888,6 @@ static bool
 check_credentials(struct ntb_ipc *ipc,
                   int sock)
 {
-        uid_t uid;
-
-        if (!get_peer_uid(sock, &uid)) {
-                ntb_log("Error getting credentials for IPC connection: %s",
-                        strerror(errno));
-                return false;
-        }
-
-
-        if (uid != 0 && uid != ipc->uid) {
-                ntb_log("Rejecting IPC connection from unauthorized user %i",
-                        uid);
-                return false;
-        }
-
         return true;
 }
EoF

./autogen.sh --prefix=/usr/local
make
make install
