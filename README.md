# MacRenameOnSiteTypeSerial
Rename a MacOS Device based on the Site a computer is assigned to within Jamf, type of Mac and 7 digits of the Serial number 

Mac Rename based on Site Name from Jamf PRO Server, Type of Computer and Last 7 Digits of the Serial Number.
If an older MacOS serial is detected the script will still work.

You MUST have an api user credentials in the script and passed as a parameter from the Jamf PRO Policy. See the 
following URL for details.
https://github.com/jamf/Encrypted-Script-Parameters

Naming Convention design
  Site  type  7 Digits of Serial
	XX    X	     XXXXXXX
	AU    M      abcdefg
	
If any of the variables Jamf PRO URL, Serial Number, Site Name, or API Username/Password do not exist then the script will error and exit.
