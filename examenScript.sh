#!/bin/bash
 
# Default subnet
SUBNET=0 #129

# Changes the timeout (in seconds) of the pingFunction
TIME_OUT=5

# the default network address
NETWORK_ADDRESS="192.168.$SUBNET."
 
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
	ping -w $TIME_OUT -c 1 $NETWORK_ADDRESS$1 &> /dev/null 
 
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
	if [ "$1" -eq "$1" ] && [ "$1" -le "255" ] && [ "$1" -ge "0" ] &> /dev/null
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
function addRangeToHostList() {
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
	left="$((${arg/-*/} + 200 ))" # change to 200
	right="$((${arg/*-/} + 200))"
 
	for (( i=($left); i <= ($right); i++))
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
	echo "$(arp -an "$1" | grep "$1" | awk '{print $4}')"	
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
			[a-z]* )   
				echo "Invalid character! Please use the helpfunction: -help"
				;;
 
			-h | -help )
				help
				;;
 
			--up )
				up=true
				;;
 
			--sum )
				sum=true
				;;
 
			--sort )
				sorting=true
				;;
 
                        *[0-9]-[0-9]* )
				addRangeToHostList $1
				;;
 
			-t )
				shift
				if isByte $1
				then
					addHostList $(( $1 + 200 ))
				else
					addNumToIPRange $1
				fi
				;;

			-sn )
				shift
				setSubnet $1
				;;

			-sn[0-9]* )
				# TODO: finish
				;;

			-mac )
				mac=true
				;;

                        [0-9]* )
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
	HOST_LIST=($(echo "${HOST_LIST[@]}" | tr ' ' '\n' | sort -nu | tr '\n' ' '))
fi

# loop through the HOST_LIST and ping each entry. Then put the host in the correct list
# depending on the ping result
for host in ${HOST_LIST[@]}
do
	if pingFunction $host ;
	then
		UP_LIST="$UP_LIST $host"
	else
		DOWN_LIST="$DOWN_LIST $host"
	fi
done

# loop over the UP_LIST
# in case the --mac flag was enabled, try to retrieve the mac
# and print this too
for host in ${UP_LIST[@]}
do
	echo -n "$host is up"
	if [ $mac = true ]
	then
		echo " --- mac: $(getMacAddress $NETWORK_ADDRESS$host)"
	fi
	echo 
done

# the --up flag isn't set so we can also display the hosts that are down
if [ $up = false ]  
then
	for host in ${DOWN_LIST[@]}
	do
		echo "$host is down"
	done
fi
 
# the --sum flag was enabled so print a summary of our UP & DOWN lists
if [ $sum = true ] 
then
	# Print the UP_LIST first, in case it's not empty
	if [ ${#UP_LIST[@]} -gt 0 ]
	then
		echo "Up = $(echo ${UP_LIST[@]} | tr ' ' ', ')"
	fi

	# Print the DOWN_LIST, again in case it's not empty
	if [ ${#DOWN_LIST[@]} -gt 0 ]
	then
		echo "Down = $(echo ${DOWN_LIST[@]} | tr ' ' ', ')"
	fi
fi
