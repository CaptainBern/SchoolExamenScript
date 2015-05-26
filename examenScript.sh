#!/bin/bash

HOST_REACHABLE=0
HOST_UNREACHABLE=1
INVALID_IP=2

IP_PREFIX="192.168.0."

function help() {
	clear
    echo "NAME"
    echo "  Pinger - A tool used to ping a range of IP's"
    echo ""
    echo "SYNOPSIS"
    echo "  $0 [OPTION]... [bla]"
    echo ""
    echo "DESCRIPTION"
    echo "  Pinger was made to verify the status of 1 or more IP adresses in"
    echo "  a local area network."
    echo ""
    echo "OPTIONS"
    echo "  -h,"
    echo ""
    echo "AUTHOR"
    echo "  Witten by Verscheure Bengt and Miers Maarten."
	exit
}

# Ping-function
# will ping given ip and print a message depending
# on the ping-result
function pingFunction() {
	if [ "$1" -eq "$1" ] &> /dev/null
	then
		ping -c 1 $IP_PREFIX$1 &> /dev/null

		# the exit-code of the ping-command will be stored inside '$?'
		# in case it's 0, the ping was successful. 
		# for more info see: http://www.manpagez.com/man/8/ping/
		if [[ "$?" == 0 ]]; 
		then
			echo "$HOST_REACHABLE"
		else 
			echo "$HOST_UNREACHABLE"
		fi
	else
		echo "$INVALID_IP"
	fi
}

function addIPToList() {
	IP_LIST="$IP_LIST $1"
}

# main loop/case stuff
if [ -z "$1" ]
then
	echo "You did not enter a parameter. Please use '$0 -h' to show the usage."

else 
	until [ -z $1 ]
	do
		case $1 in
			-h | -help )
				help
				;;	
			* )
				addIPToList $1
				;;
			esac
		shift
	done
fi

for ip in $IP_LIST 
do
	pingFunction $ip
done
