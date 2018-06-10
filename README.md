# NetworkStatusWarden
![Logo](images/NetworkStatusWarden.jpg "Logo")

Run custom code during network up and down events on MacOS.

## Description:

NetworkStatusWarden catches MacOS network events to allow you to run custom code when the primary network service goes down or comes up - and when any network interface goes down or comes up.

It consists of the following components:

	NetworkStatusWarden               - The main binary that catches the network change events
	NetworkStatusWarden-InterfaceDown - Called when any network interface goes down
	NetworkStatusWarden-InterfaceUp   - Called when any network interface comes up
	NetworkStatusWarden-NetworkDown   - Called when the primary network service goes down
	NetworkStatusWarden-NetworkUp     - Called when the primary network service comes up (or changes)

The example NetworkStatusWarden-InterfaceDown, NetworkStatusWarden-InterfaceUp, NetworkStatusWarden-NetworkDown and NetworkStatusWarden-NetworkUp are bash scripts.

The example scripts simply use the "say" command to let you know when the network is up or down. You should customise these scripts to your own needs.


## How to install:

Download the installer package here: [NetworkStatusWarden.pkg](https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden.pkg "NetworkStatusWarden.pkg") 

The installer will install the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.networkstatuswarden.plist
	/usr/NetworkStatusWarden/

There's no need to reboot.

After installation, your computer will speak during network up and down events.

You can alter the example shell scripts to alter this behavior, these can be found in the following location:

	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceUp
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkUp

If the installer fails you should check the logs.

## Logs:

Logs are written to the following file:

	/Library/Logs/com.github.execriez.networkstatuswarden.log

## How to uninstall:

Download the uninstaller package here: [NetworkStatusWarden-Uninstaller.pkg](https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden-Uninstaller.pkg "NetworkStatusWarden-Uninstaller.pkg") 

The uninstaller will uninstall the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.networkstatuswarden.plist
	/usr/NetworkStatusWarden/

There's no need to reboot.

After the uninstall everything goes back to normal, and network state changes will not be tracked.

## History:

1.0.5 - 10 JUN 2018

* Previously the code was only interested in primary service up and down events. This version includes code to catch network interface up and down events too.

1.0.4 - 01 JUN 2017

* Recompiled to be backward compatible with MacOS 10.7 and later

1.0.3 - 23 MAY 2017

* Updated the installer to be more in line with my other projects

* Example scripts now write to a log file

1.0.2 - 04 JAN 2017

* Now keeps track of previous primary network interface to eliminate spurious NetworkUp calls.
 
* Renamed from NetworkStateWarden to NetworkStatusWarden.

1.0.1 - 02 JUN 2016

* First public release.
