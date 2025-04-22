function ExtensionStatus {
	sudo /Applications/Huntress.app/Contents/MacOS/Huntress extensionctl status
}
function CheckInstallStatus {
	if [[ $('ExtensionStatus' | grep "Extension Status") = "Extension Status: installed" ]]
	then
		echo "|| - Successfully installed Huntress extension."
	else
		echo "|| - Failed to install Huntress extension."
	fi
}

if [[ $('ExtensionStatus' | grep "Preauthorization Status") = "Preauthorization Status: notGranted" ]]
then
	echo "|| Authorizing Huntress extension..."

	sudo /Applications/Huntress.app/Contents/MacOS/Huntress extensionctl install --preauthorize > /dev/null

	if [[ $('ExtensionStatus' | grep "Preauthorization Status") = "Preauthorization Status: granted" ]]
	then
		echo "|| - Successfully authorized Huntress extension."

		'CheckInstallStatus'
	else
		echo "|| - Failed to authorize Huntress extension. Check if Huntress has Full Disk Access and try again."
	fi
else
	if [[ $('ExtensionStatus' | grep "Extension Status") = "Extension Status: notInstalled" ]]
	then
		echo "|| Installing Huntress extension..."

		sudo /Applications/Huntress.app/Contents/MacOS/Huntress extensionctl install

		'CheckInstallStatus'
	else
		echo "|| - Failed to install Huntress extension."
	fi
fi
