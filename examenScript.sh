#!/bin/bash

IP_PREFIX="192.168.0."

function help() {
	echo "Lol kk"
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
			echo "$IP_PREFIX$1 is up"
		else 
			echo "$IP_PREFIX$1 is unreachable"
		fi
	else
		echo "$IP_PREFIX$1 is not a valid ip-address!"
	fi
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
				pingFunction $1
				;;
			esac
		shift
	done
fi
