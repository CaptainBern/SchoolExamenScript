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
			echo "Invalid IP address, please use the helpfunction: -help"
	fi
}

#This function will see whether the input after "-t" is an integer or not.
#http://unix.stackexchange.com/questions/151654/checking-if-an-input-number-is-an-integer
function checkForInt() {
	if [ "$1" -eq "$1" ] 2>/dev/null 
		then 
			addIPToList "$(( $1 + 100 ))" # CHANGE TO 200, tesing atm. 
		else 
			addNumToIPRange $1  
	fi
}

function addIPToRange() {
	arg="$1"
	left="${arg/-*/}"
	right="${arg/*-/}"

	for (( i=($left); i <= ($right); i++))
		do
    		#addIPToList "$i"
			echo $i #experimental
		done
}

function addNumToIPRange () {
	arg="$1"
    left="$((${arg/-*/} + 100 ))" # change to 200
    right="$((${arg/*-/} + 100))"
    
    for (( i=($left); i <= ($right); i++))
        do
            #addIPToList "$i"
            echo $i
        done
}

# main loop/case stuff
if [ -z "$1" ]
then
	echo "You did not enter a parameter. Please use '$0 -h' to show the usage."

else 
	until [ -z $1 ]
	do
		case $1 in
			[a-z]* )   #check for letters?
				echo "Invalid character! Please use the helpfunction: -help"
				;;

			-h | -help )
				help
				;;

			--up )
				up="true"
				;;

			--sum )
				sum="true"
				;;
                        
			--sort )
				sorting="true"
				;;

			*[0-9]-[0-9]* ) 
				addIPToRange $1
				;;

			-t )
				shift; checkForInt $1	
				;;
	
			[0-9]* )
				addIPToList $1
				;;
			esac
		shift
	done
fi

for IP in $IP_LIST 
	do
		pingFunction $IP
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
