#!/bin/bash
 
# 'global' variables
HOST_REACHABLE=0
HOST_UNREACHABLE=1
INVALID_IP=2
 
# the default network address
NETWORK_ADDRESS="192.168.0."
 
# Prints the help in a man-page format
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
    exit 1
}
 
# Ping-function
# will ping given ip and echo
# the ping result.
# in case it's $HOST_REACHABLE then the
# target has responded to the ping
# in case it's $HOST_UNREACHABLE then
# the ping failed.
function pingFunction() {
        ping -c 1 $NETWORK_ADDRESS$1 &> /dev/null
 
        # the exit-code of the ping-command will be stored inside '$?'
        # in case it's 0, the ping was successful.
        # for more info see: http://www.manpagez.com/man/8/ping/
        if [[ "$?" == 0 ]]
                then
                        echo "$HOST_REACHABLE"
                else
                        echo "$HOST_UNREACHABLE"
        fi
}
 
# This function will add the
# given host address to the list
function addHostToList() {
        if [ "$1" -eq "$1" ] &> /dev/null
                then
                        HOST_LIST="$HOST_LIST $1"
                else
                        echo "$INVALID_IP"
        fi
}
 
#This function will see whether the input after "-t" is an integer or not.
#http://unix.stackexchange.com/questions/151654/checking-if-an-input-number-is-an-integer
function checkForInt() {
        if [ "$1" -eq "$1" ] 2>/dev/null
       		then
        	        addHostToList "$(( $1 + 100 ))" # CHANGE TO 200, tesing atm.
            	else
                	addNumToIPRange $1
        fi
}
 
# This function adds the given
# range of host-addresses to the HOST_LIST
function addIPToRange() {
        arg="$1"
        left="${arg/-*/}"
        right="${arg/*-/}"
 
        for (( i=($left); i <= ($right); i++))
                do
                addHostToList "$i"
                done
}
 
function addNumToIPRange () {
        arg="$1"
    left="$((${arg/-*/} + 100 ))" # change to 200
    right="$((${arg/*-/} + 100))"
 
    for (( i=($left); i <= ($right); i++))
        do
            #addHostToList "$i"
            echo $i
        done
}
 
# main loop/case stuff
up=false
sum=false
sorting=false
 
if [ -z "$1" ]
then
        echo "You did not enter a parameter. Please use '$0 -h' to show the usage."
	exit 1
 
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
                                $up=true
                                ;;
 
                        --sum )
                                $sum=true
                                ;;
 
                        --sort )
                                $sorting=true
                                ;;
 
                        *[0-9]-[0-9]* )
                                addIPToRange $1
                                ;;
 
                        -t )
                                shift;
                                checkForInt $1
                                ;;
 
                        [0-9]* )
                                addHostToList $1
                                ;;
                        esac
                shift
        done
fi
 
if [ "$sorting" = true ]; 
	then
		echo "sorting!"
        # TODO: sort the host-addresses
fi

# loop through the HOST_LIST
for host in "${HOST_LIST[@]}"
do
	result=$(pingFunction $host)

	if [ "$result" -eq "$HOST_REACHABLE" ]
	then
		UP_LIST="$UP_LIST $host"
	else
		DOWN_LIST="$DOWN_LIST $host"
	fi
done

# loop over the UP_LIST
for host in "${UP_LIST[@]}"
do
	echo "$host is up"
done

# the --up flag isn't set so we can also display the hosts that are down
if [ "$up" = false ] 
	then
		for host in "${DOWN_LIST[@]}"
		do
			echo "$host is down"
		done
fi
 
if [ "$sum" = true ]
	then
		echo "summing!"
        # TODO: print summary
fi
