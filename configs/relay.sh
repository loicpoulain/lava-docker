#!/bin/sh

telnet localhost 300`expr $1 - 1` << EOF
relay1 $2
EOF

exit 0
