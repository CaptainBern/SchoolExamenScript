#!/bin/bash
 
# Default subnet
SUBNET=129 #129

# Changes the timeout (in seconds) of the pingFunction
TIME_OUT=1

# the default network address
NETWORK_ADDRESS="192.168."

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
# in case the ping was successful
# then it will return true, otherwise
# it will return false
function pingFunction() {
	# -w 5 = our default timeout is 5, but this can be changed
	# -c 1 = only send 1 ping packet
	ping -w $TIME_OUT -c 1 $NETWORK_ADDRESS$SUBNET.$1 &> /dev/null 
 
        # the exit-code of the ping-command will be stored inside '$?'
        # in case it's 0, the ping was successful.
        # for more info see: http://www.manpagez.com/man/8/ping/
        if [[ $? -eq 0 ]]
	then
		return 0
	else
		return 1
	fi
}

# This function is used to verify whether or not the given
# parameter is a valid byte
function isByte() {
	# check if the parameter is a byte
	# use regex to check if the input is a number
	# ^ = beginning of the string
	# [0-9] = character set, matching input from 0 to 9
	# + = one or more 
	# $ = end of the string, else 11a would match too 
	# (thanks regexr.com)
	# then just use integer comparison operators to check if its within the
	# bound of a byte
	if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -le "255" ] &> /dev/null && [ "$1" -ge "0" ] &> /dev/null
	then
		return 0
	else
		return 1
	fi
}
 
# This function will add the
# given host address to the list, only if it ranges between {0..255}
function addHostToList() {
	if isByte $1
	then
		HOST_LIST="$HOST_LIST $1"
	else
		echo "Skipping '$1' because it's an invalid host-address! (Should be between 0 & 255)"
        fi
}
 
# This function adds the given
# range of host-addresses to the HOST_LIST
function addHostRangeToList() {
	[[ $1 =~ ([0-9]+)-([0-9]+) ]] # Use regex to split the input

	left=${BASH_REMATCH[1]} # get the first number
	right=${BASH_REMATCH[2]} # get the second number

	if [ $2 ] 
	then
		left=$(( $left + 200 ))
		right=$(( $right + 200 ))
	fi

	for (( i=($left); i <= ($right); i++ ))
	do
		addHostToList $i
	done
}

# Sets the subnet to the given parameter
function setSubnet() {
	if isByte $1 
	then
		SUBNET=$1
	else
		echo "'$1' is an invalid subnet!"
		exit
	fi
}

# Returns the mac address of the given ip (in case it can be found)
function getMacAddress() {
	# source: http://forums.fedoraforum.org/showpost.php?p=1496180&postcount=2
	echo "$(arp -an "$NETWORK_ADDRESS$SUBNET.$1" | grep "$1" | awk '{print $4}')"	
}
 
# Puts 'up', 'sum', 'sorting' and 'mac' on the default: false
up=false
sum=false
sorting=false
mac=false
 
if [ -z "$1" ]
then
        echo "You did not enter a parameter. Please use '$0 -h' to show the usage."
	exit 1
 
else
	until [ -z $1 ]
	do
		case $1 in
			[a-z]* 		)   
				echo "Invalid character! Please use the helpfunction: -help"
				;;
 
			-h | -help 	)
				help
				;;
 
			--up 		)
				up=true
				;;
 
			--sum 		)
				sum=true
				;;
 
			--sort 		)
				sorting=true
				;;
 
                        *[0-9]-[0-9]* 	)
				addHostRangeToList $1
				;;
 
			-t 		)
				shift
				if isByte $1 
				then
					addHostToList $(( $1 + 200 ))
				else
					addHostRangeToList $1 true
				fi
				;;

			-sn 		)
				shift
				setSubnet $1
				;;

			-sn[0-9]* 	)
				snet=`echo "$1" | awk -F"n" '{ print $2 }'`
				setSubnet $snet
				;;

			-mac 		)
				mac=true
				;;

                        [0-9]* 		)
				addHostToList $1
				;;
			esac
		shift
	done
fi
 
# Start printing our stuff 

# the --sort flag was set so sort the list before pinging
if [ $sorting = true ]
then
	# sort the host list
	# 'sort' only works with lines, hence why we convert our array to lines
	# n = numeric 
	# u = unique (no dupes)
	HOST_LIST=$(echo ${HOST_LIST[@]} | tr ' ' '\n' | sort -nu | tr '\n' ' ')
fi

# loop through the HOST_LIST and ping each entry. Then put the host in the correct list
# depending on the ping result
for host in ${HOST_LIST[@]}
do
	if pingFunction $host 
	then
		UP_LIST="$UP_LIST $host"
		echo -n "$host is up."
		if [ $mac = true ]
		then
			echo " --- mac: $(getMacAddress $host)"
		else 
			echo
		fi
	else
		DOWN_LIST="$DOWN_LIST $host"
		if [ $up = false ]
		then
			echo "$host is down."
		fi

	fi
done

# Count the lists using wc
UP_COUNT=$(echo ${UP_LIST[@]} | wc -w)
DOWN_COUNT=$(echo ${DOWN_LIST[@]} | wc -w)
TOTAL_COUNT=$(echo ${HOST_LIST[@]} | wc -w)

# the --sum flag was enabled so print a summary of our UP & DOWN lists
if [ $sum = true ] 
then
	# Print the UP_LIST first, in case it's not empty
	if [ $UP_COUNT -gt 0 ]
	then
		echo "Up = $(echo ${UP_LIST[@]} | tr ' ' ', ')"
	fi

	# Print the DOWN_LIST, again in case it's not empty
	if [ $DOWN_COUNT -gt 0 ]
	then
		echo "Down = $(echo ${DOWN_LIST[@]} | tr ' ' ', ')"
	fi
fi

# Print the stats
echo "$UP_COUNT/$TOTAL_COUNT of the pinged computers are up"
echo "That is $(( $UP_COUNT * 100 / $TOTAL_COUNT ))% of all the computers"
