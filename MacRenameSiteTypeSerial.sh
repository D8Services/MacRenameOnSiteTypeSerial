#!/bin/bash


	###############################################################
	#	Copyright (c) 2019, D8 Services Ltd.  All rights reserved.  
	#											
	#	
	#	THIS SOFTWARE IS PROVIDED BY D8 SERVICES LTD. "AS IS" AND ANY
	#	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	#	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	#	DISCLAIMED. IN NO EVENT SHALL D8 SERVICES LTD. BE LIABLE FOR ANY
	#	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	#	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	#	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	#	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	#	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	#	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#
	#
	###############################################################
	#
	
# Mac Rename based on Site Name from Jamf PRO Server, Type of Computer and Last 7 Digits of the Serial Number.
# If an older MacOS serial is detected the script will still work.
# You must have an api user entered in the script and passed as a parameter from the Jamf PRO Policy. See the 
# following URL for details.
# https://github.com/jamf/Encrypted-Script-Parameters
#
# Naming Convention
#  Site  type  7 Digits of Serial
#	XX	  X	     XXXXXXX
#	AU    M      abcdefg

#Only Run as Root
thisUser=`whoami`
if [[ $thisUser != "root" ]];then
	echo "Can only run as root"
	exit 1
fi

# Work out the encrypted strings
function DecryptString() {
	# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

ComputerType="M"
jamfUser=$(DecryptString "${4}" "d278225b2cf07d19" "30aa6c4b854a14f00414c644")
jamfPass=$(DecryptString "${5}" "bf7939b07dde0603" "affa996ddcd29a39d366852b")

JamfURL=`defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url`
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
#LengthSerial=${#serialNumber}

# Workout the last 7 digits
IDNumber=${serialNumber:(-7)}

if [[ -z ${jamfUser} ]]||[[ -z ${jamfPass} ]]||[[ -z ${JamfURL} ]]||[[ -z ${IDNumber} ]];then
	echo "One or more parameters are missing, exiting."
	exit 2
fi

SiteName=$(curl -sku "${jamfUser}":"${jamfPass}" -H "accept: text/xml" ${JamfURL}JSSResource/computers/serialnumber/$serialNumber | xmllint --xpath '/computer/general/site/name/text()' -)

if [[ $SiteName == "None" ]];then
	echo "Mac is not in a Site. Setting Country Code to Generic."
	CNCode="XX"
elif [[ ${#SiteName} -gt 2 ]];then
	echo "SiteName is too long. Setting Country Code to Generic."
	CNCode="XX"
else
	SiteName=$(echo ${SiteName} | awk '{ print toupper($0) }')
	CNCode="${SiteName}"
fi
MacName="${CNCode}${ComputerType}${IDNumber}"

echo "MacName will be $MacName"
echo "INFO: Resetting Computer Name to ${MacName}"
scutil --set ComputerName "${MacName}"
scutil --set LocalHostName "${MacName}"
scutil --set HostName "${MacName}"
jamf recon
