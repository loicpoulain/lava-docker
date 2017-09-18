#!/bin/sh

telnet 172.17.0.1 300`expr $1 - 1` << EOF
relay1 $2
EOF

exit 0
