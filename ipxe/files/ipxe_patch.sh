#!/bin/sh

set -e

patch --ignore-whitespace -p1 << 'EoF'
diff --git a/src/config/console.h b/src/config/console.h
index 9f770d09..62a8c792 100644
--- a/src/config/console.h
+++ b/src/config/console.h
@@ -34,7 +34,7 @@ FILE_LICENCE ( GPL2_OR_LATER_OR_UBDL );
  *
  */

-//#define      CONSOLE_SERIAL          /* Serial port console */
+#define        CONSOLE_SERIAL          /* Serial port console */
 //#define      CONSOLE_FRAMEBUFFER     /* Graphical framebuffer console */
 //#define      CONSOLE_SYSLOG          /* Syslog console */
 //#define      CONSOLE_SYSLOGS         /* Encrypted syslog console */
diff --git a/src/config/general.h b/src/config/general.h
index 3c14a2cd..755ca323 100644
--- a/src/config/general.h
+++ b/src/config/general.h
@@ -35,10 +35,10 @@ FILE_LICENCE ( GPL2_OR_LATER_OR_UBDL );
  */

 #define        NET_PROTO_IPV4          /* IPv4 protocol */
-#undef NET_PROTO_IPV6          /* IPv6 protocol */
+#define        NET_PROTO_IPV6          /* IPv6 protocol */
 #undef NET_PROTO_FCOE          /* Fibre Channel over Ethernet protocol */
-#define        NET_PROTO_STP           /* Spanning Tree protocol */
-#define        NET_PROTO_LACP          /* Link Aggregation control protocol */
+#undef NET_PROTO_STP           /* Spanning Tree protocol */
+#undef NET_PROTO_LACP          /* Link Aggregation control protocol */

 /*
  * PXE support
@@ -54,7 +54,7 @@ FILE_LICENCE ( GPL2_OR_LATER_OR_UBDL );

 #define        DOWNLOAD_PROTO_TFTP     /* Trivial File Transfer Protocol */
 #define        DOWNLOAD_PROTO_HTTP     /* Hypertext Transfer Protocol */
-#undef DOWNLOAD_PROTO_HTTPS    /* Secure Hypertext Transfer Protocol */
+#define        DOWNLOAD_PROTO_HTTPS    /* Secure Hypertext Transfer Protocol */
 #undef DOWNLOAD_PROTO_FTP      /* File Transfer Protocol */
 #undef DOWNLOAD_PROTO_SLAM     /* Scalable Local Area Multicast */
 #undef DOWNLOAD_PROTO_NFS      /* Network File System Protocol */
@@ -75,8 +75,8 @@ FILE_LICENCE ( GPL2_OR_LATER_OR_UBDL );
  * HTTP extensions
  *
  */
-#define HTTP_AUTH_BASIC                /* Basic authentication */
-#define HTTP_AUTH_DIGEST       /* Digest authentication */
+//#define HTTP_AUTH_BASIC              /* Basic authentication */
+//#define HTTP_AUTH_DIGEST     /* Digest authentication */
 //#define HTTP_AUTH_NTLM       /* NTLM authentication */
 //#define HTTP_ENC_PEERDIST    /* PeerDist content encoding */
 //#define HTTP_HACK_GCE                /* Google Compute Engine hacks */
EoF

touch .patched
