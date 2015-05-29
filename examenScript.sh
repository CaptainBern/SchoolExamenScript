#!/bin/bash

HOST_REACHABLE=0
HOST_UNREACHABLE=1
INVALID_IP=2

IP_PREFIX="192.168.0."

# Ping-function
# will ping given ip and print a message depending
# on the ping-result
function pingFunction() {
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
}

function addIPToList() {
	if [ "$1" -eq "$1" ] &> /dev/null
	then
            IP_LIST="$IP_LIST $1"
	
	else
		# if the exit-code is 2, then the IP adress will be marked invalid.
		echo "$IP_PREFIX$1 is an invalid IP address"
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

#PLACE ON TOP PLIZ
function help() {
    clear
    echo "NAME"
    echo "  Pinger - A tool used to ping a range of IP's."
    echo ""
    echo "SYNOPSIS"
    echo "  $0 [OPTION] [IP_1] [IP_2] ... [IP_N]"
    echo ""
    echo "DESCRIPTION"
    echo "  Pinger was made to verify the status of 1 or more IP addresses in"
    echo "  a local area network."
    echo "  e.g: $0 87 97 132"
    echo ""
    echo "OPTIONS"
    echo "  -h, -help"
    echo "      help will show the user basic information about the script"
    echo ""
    echo "  -t"
    echo "      this adds 200 to each number, e.g: -t 17 will test IP 217"
    echo ""
    echo "  --up"
    echo "      shows you all the IP's that are up and running"
    echo ""
    echo "  --sum"
    echo "      shows you a summary table of all the failed and successful pings"
    echo ""
    echo "  --sort"
    echo "      pings unique IP's in descending order"
    echo ""
    echo "  -sn [subnet], -sn[subnet]"
    echo '      "-sn 128" will test the subnetwork: 128 and not 192.168."129".0/24 '
    echo ""
    echo "  -mac"
    echo "      every successful ping will receive the corresponding MAC-address"
    echo ""
    echo "AUTHOR"
    echo "  Witten by Verscheure Bengt and Miers Maarten."
    exit
}
