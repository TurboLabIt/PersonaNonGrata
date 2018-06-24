#!/bin/bash
clear

## Script name
SCRIPT_NAME=personanongrata

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo "      $SCRIPT_NAME - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")
SCRIPT_HASH=`md5sum ${SCRIPT_FULLPATH} | awk '{ print $1 }'`

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

## Config files
CONFIGFILE_NAME=$SCRIPT_NAME.conf
CONFIGFILE_FULLPATH_DEFAULT=${SCRIPT_DIR}$SCRIPT_NAME.default.conf
CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME
CONFIGFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_NAME

## Title printing function
function printTitle
{
    echo ""
    echo "$1"
    printf '%0.s-' $(seq 1 ${#1})
    echo ""
}

## root check
if ! [ $(id -u) = 0 ]; then

		echo ""
		echo "vvvvvvvvvvvvvvvvvvvv"
		echo "Catastrophic error!!"
		echo "^^^^^^^^^^^^^^^^^^^^"
		echo "This script must run as root!"

		printTitle "How to fix it?"
		echo "Execute the script like this:"
		echo "sudo $SCRIPT_NAME"

		printTitle "The End"
		echo $(date)
		echo "$FRAME"
		exit
fi


printTitle "Read config (if any)"
for CONFIGFILE_FULLPATH in "$CONFIGFILE_FULLPATH_DEFAULT" "$CONFIGFILE_MYSQL_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_DIR" "$CONFIGFILE_PROFILE_FULLPATH_ETC" "$CONFIGFILE_PROFILE_FULLPATH_DIR"
do
	if [ -f "$CONFIGFILE_FULLPATH" ]; then
		source "$CONFIGFILE_FULLPATH"
	fi
done

printTitle "Updating..."
git pull -C "$SCRIPT_DIR"


printTitle "Cycling on IPs.."
IP_BLACKLIST_FULLPATH=${SCRIPT_DIR}/ip_blacklist.d/personanongrata_ip_blocklist.txt

while read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
	
	FIRSTCHAR="${line:0:1}"
	
	if [ "$FIRSTCHAR" == "#" ]; then
		
		echo ufw delete deny from $line to any
		echo ufw insert 1 deny from $line to any
	
	fi
	
	
done < "$IP_BLACKLIST_FULLPATH"

printTitle "It's done!"
echo "Your system in now shielded from unwanted clients"
echo "Please add yours non-gratas to https://github.com/TurboLabIt/${SCRIPT_NAME}"
echo $(date)
echo "$FRAME"
