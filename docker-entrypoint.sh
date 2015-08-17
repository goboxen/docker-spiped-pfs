#!/bin/bash
set -e
KEYFILE=/spiped/key
usage() {
	echo "Usage: {e | d} <target socket>"
}
showerr() {
	echo "[!]" $1
	exit 1
}

[ $# -ne 2 ] && usage && showerr "Incorrect operand count"
[[ $1 != "e" && $1 != "d" ]] && usage && showerr "Accepted modes are only (e)ncrypt and (d)ecrypt"
[ ! -f $KEYFILE ] && showerr "Key file does not exist"
chown spiped-user $KEYFILE
[ ! -r $KEYFILE ] && showerr "Key file is not readable"
echo "Starting spiped..."
exec gosu spiped-user spiped -$1 -s '[0.0.0.0]:8022' -t $2 -k $KEYFILE -gF

