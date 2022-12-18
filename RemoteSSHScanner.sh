#!/bin/bash

#this function shall install all required tools for script execution and automated functions

function Setup(){
	cd ~/Desktop
	sudo apt update
	sudo apt-get install geoip-bin
	sudo apt-get install nmap
	sudo apt-get install sshpass
	sudo apt-get install whois
	sudo apt-get install moreutils
	if [ -d nipe ]
	then echo "Nipe Exists"
	else git clone https://github.com/htrgouvea/nipe && cd nipe && sudo cpan install Try::Tiny Config::Simple JSON && sudo perl nipe.pl install 
	fi
}
Setup
echo

#This function anonimizes the local host and checks whether the connection has become anonymous

function Anonimity(){
	cd ~/Desktop && cd nipe && sudo perl nipe.pl start && sudo perl nipe.pl restart
	EIP=$(curl -s ifconfig.io)
	if [ -z $(geoiplookup $EIP | grep IL) ]
	then echo "Anonymous" 
	else echo "NOT Anonymous" 
	fi
}
Anonimity
echo

#This function presents the country used for connection

function AnonIPCountry(){
	for CC in $(geoiplookup $EIP | awk '{print $4}' | cut -d "," -f1 )
	do echo $CC
	done
}
AnonIPCountry
echo

#This function asks the user for the remote host details

function RHDetails(){
	echo "Specify Remote Host IP:" 
	read IP
	echo "Specify Remote Host User:"	
	read USER 
	echo "Specify Remote Host User's Password:"
	read PASS
}

#This function terminates the script if the test recognizes the connection isn't anonymous

function NonAnonTermination(){
	if [ $CC == "IL" ]
	then exit
	else RHDetails
	fi
}
NonAnonTermination
echo

#This function scans the remote host pre-SSH connection

function RHScans(){
	cd ~/Desktop
	nmap -sV $IP > RemoteHostScans.txt
	echo >> RemoteHostScans.txt
	whois $IP >> RemoteHostScans.txt
	cat RemoteHostScans.txt
}
RHScans
echo

#The function connects via SSH and starts automations for information gathering and scans

function SSHAuto(){
	echo "Specify Target IP:"
	read tIP
	N=$(curl ifconfig.io)
	sshpass -p $PASS ssh $USER@$IP -o StrictHostKeyChecking=no "
	uptime > RemoteHostDetails.txt;
	echo >> RemoteHostDetails.txt;
	date >> RemoteHostDetails.txt;
	echo >> RemoteHostDetails.txt;
	hostname -I >> RemoteHostDetails.txt;
	echo >> RemoteHostDetails.txt;
	curl ifconfig.io >> RemoteHostDetails.txt;
	echo >> RemoteHostDetails.txt;
	whois $tIP | grep -i country >> RemoteHostDetails.txt
	nmap $tIP > AutoScans.txt;
	echo >> AutoScans.txt;
	whois $tIP >> AutoScans.txt;
	"
}
SSHAuto
echo

#This function displays the information gathered by the SSHAuto function

function SSHResults(){
	cd ~/Desktop
	sshpass -p $PASS ssh $USER@$IP -o StrictHostKeyChecking=no "cat RemoteHostDetails.txt" | sponge > RemoteHostDetails.txt
	sshpass -p $PASS ssh $USER@$IP -o StrictHostKeyChecking=no "cat AutoScans.txt" | sponge > AutoScans.txt
}
SSHResults
echo

#This function gets and displays local host details

function LocalDetails(){
	cd ~/Desktop
	date > LocalDetails.txt
	echo >> LocalDetails.txt
	hostname -I >> LocalDetails.txt
	echo >> LocalDetails.txt
	curl ifconfig.io >> LocalDetails.txt
}
LocalDetails
echo 

echo "The info gathered by this script is located on your desktop and the report shall be displayed now:"
function Report(){
	cd ~/Desktop
	echo "Local Host Details(Date, int.IP, ext.IP):" > Report.txt
	echo >> Report.txt
	cat LocalDetails.txt >> Report.txt
	echo >> Report.txt
	echo "Remote Host Details(Uptime, Date, int.IP, ext.IP, Country):" >> Report.txt
	echo >> Report.txt
	cat RemoteHostDetails.txt >> Report.txt
	echo >> Report.txt
	echo "The Remote Host was scanned for your convenience, Here are the details(nmap&whois):" >> Report.txt
	echo >> Report.txt
	cat RemoteHostScans.txt >> Report.txt
	echo >> Report.txt
	echo "Master, The Target has been scanned here is the Intel gathered(nmap&whois):" >> Report.txt
	echo >> Report.txt
	cat AutoScans.txt >> Report.txt
	cat Report.txt
}
Report
