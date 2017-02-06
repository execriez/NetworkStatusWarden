# NetworkStatusWarden
Run custom code when the primary network interface changes on MacOS.

##Description:

NetworkStatusWarden catches MacOS primary network interface changes, to allow you to run custom code when the network goes down, comes up, or changes.

It consists of the following components:

	NetworkStatusWarden             - The main binary that catches the network change events
	NetworkStatusWarden-NetworkDown - Called when the primary network goes down
	NetworkStatusWarden-NetworkUp   - Called when the primary network changes or comes up

The example NetworkStatusWarden-NetworkDown and NetworkStatusWarden-NetworkUp are bash scripts.

The example scripts simply use the "say" command to let you know when the network is up or down. You should customise these scripts to your own needs.


##How to install:

1. Download and unzip the software to a convenient location.
2. Double click the file "Install.command"
3. Reboot

If it fails to run, make sure that the executable bit is set on the script.

##How to uninstall:

1. Delete the following files and folders

		/usr/local/NetworkStatusWarden/
		/Library/LaunchDaemons/com.github.execriez.NetworkStatusWarden.Example.plist
	
2. Reboot

##History:

1.0.1 - 02 JUN 2016

* First public release.

1.0.2 - 04 JAN 2017

* Now keeps track of previous primary network interface to eliminate spurious NetworkUp calls.
 
* Renamed from NetworkStateWarden to NetworkStatusWarden.
