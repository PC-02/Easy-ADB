#!/bin/bash

function getIP(){

	printf "\n\n"
	echo "Make you have permission from the network adminstrator to perform this."
	printf "Enter the device name or device IP: "
	read DEVICE_ID
	printf "\n"

	if [[ "$DEVICE_ID" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]
	then
		echo "Using IP provided"
		echo $DEVICE_ID
	else
  		echo "Scanning network to obtain device IP..."
		DEVICE_IP=$(nmap -sn -Pn 192.168.0.0/24 | grep $DEVICE_ID |  awk 'NF>1{print $NF}' |  tr -d '()')

		if [[ -z "$DEVICE_IP" ]]
		then
			echo "IP not found."
			exit 0
		else
			echo "IP found!"
			echo $DEVICE_IP
		fi
	fi

}

if [[ -f "/android-sdk/platform-tools/adb" ]]
then
	echo "Installing ADB..."
	sudo apt-get install adb
else
	printf "ADB Installed.\n\n"
fi

if [[ $1 = *-h ]] || [[ $1 = *--help ]]
then
	echo "Enabling debugging on your phone: "
	echo "1) Go to Settings"
	echo "2) Under Settings, scroll down and select About Phone"
	echo "3) Under Software Information, Find the Build Number and tap it 7 times"
	echo "4) After getting a pop up, Go back to settings and scroll to the bottom"
	echo "5) Select Developer Options and search for USB debugging, then enable it"
	echo "6) Plug the phone into the computer (You may use its charging cable for this)"

	printf "\n"
	exit 0
fi

ADB_RES=$(adb devices | grep -w device)

if [[ -z ${ADB_RES} ]]
then
	echo "No devices connected"
	WIRED_CONN=0
else
	WIRED_CONN=$(echo "${ADB_RES}" | wc -l)

	if [[ $WIRED_CONN != 1 ]]
	then
		echo "The connected devices are:"
		echo "${ADB_RES}"
	else
		echo "The connected device is:"
		echo "${ADB_RES}"
	fi
fi

printf "\n\n"

echo "What would you like to do?"

echo "1) Enable wireless ADB connection"
printf "\nSelect a number: "
read OPTION


if [[ "$OPTION" =~ ^(1|2|3)$ ]]
then
	if [[ $OPTION = 1 ]]
	then
		echo "Has this device been connected wirelessly recently? (Y/N)"
		read TEMP

		if [[ "$TEMP" =~ ^(n|N|NO|no|No|nO)$ ]]		# If user selects No
		then
			if [[ $WIRED_CONN = 0 ]]
                        then
                                echo "Connect a device and restart the process"
                                exit 0
                        fi

			adb tcpip 5555
			IP="$(getIP)"

		elif [[ "$TEMP" =~ ^(y|Y|yes|YES|Yes|yEs|yeS|YEs|yES)$ ]]	# If user selects Yes
		then
			IP="$(getIP)"
		else
			echo "Invalid option."
		fi

		echo "Your IP is ${IP}!"

	fi
else
	echo "$OPTION is an invalid option"
	exit 0
fi
