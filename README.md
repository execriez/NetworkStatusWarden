# NetworkStatusWarden
![Logo](images/NetworkStatusWarden.jpg "Logo")

Run custom code when the primary network interface changes on MacOS.

## Description:

NetworkStatusWarden catches MacOS primary network interface changes, to allow you to run custom code when the network goes down, comes up, or changes.

It consists of the following components:

	NetworkStatusWarden             - The main binary that catches the network change events
	NetworkStatusWarden-NetworkDown - Called when the primary network goes down
	NetworkStatusWarden-NetworkUp   - Called when the primary network changes or comes up

The example NetworkStatusWarden-NetworkDown and NetworkStatusWarden-NetworkUp are bash scripts.

The example scripts simply use the "say" command to let you know when the network is up or down. You should customise these scripts to your own needs.


## How to install:

Download the NetworkStatusWarden zip archive from <https://github.com/execriez/NetworkStatusWarden>, then unzip the archive on a Mac workstation.

Ideally, to install - you should double-click the following installer package which can be found in the "SupportFiles" directory.

	NetworkStatusWarden.pkg
	
If the installer package isn't available, you can run the command-line installer which can be found in the "util" directory:

	sudo Install

The installer will install the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.networkstatuswarden.plist
	/usr/NetworkStatusWarden/

There's no need to reboot.

After installation, your computer will speak whenever the primary network status changes.

You can alter the example shell scripts to alter this behavior, these can be found in the following location:

	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkUp

If the installer fails you should check the logs.

## Logs:

Logs are written to the following file:

	/Library/Logs/com.github.execriez.networkstatuswarden.log

## How to uninstall:

To uninstall you should double-click the following uninstaller package which can be found in the "SupportFiles" directory.

	NetworkStatusWarden-Uninstaller.pkg
	
If the uninstaller package isn't available, you can uninstall from a shell by typing the following:

	sudo /usr/local/NetworkStatusWarden/util/Uninstall

The uninstaller will uninstall the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.networkstatuswarden.plist
	/usr/NetworkStatusWarden/

There's no need to reboot.

After the uninstall everything goes back to normal, and primary network status changes will not be tracked.

## History:

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
