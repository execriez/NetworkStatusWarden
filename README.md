# NetworkStatusWarden
![Logo](images/NetworkStatusWarden.jpg "Logo")

Run custom code during network up and down events on MacOS.

## Description:

NetworkStatusWarden catches MacOS network events to allow you to run custom code when the primary network service goes down or comes up - and when any network interface goes down or comes up.

NetworkStatusWarden consists of the following components:

	NetworkStatusWarden               - The main binary that catches the network change events
	NetworkStatusWarden-InterfaceDown - Called when any network interface goes down
	NetworkStatusWarden-InterfaceUp   - Called when any network interface comes up
	NetworkStatusWarden-NetworkDown   - Called when the primary network service goes down
	NetworkStatusWarden-NetworkUp     - Called when the primary network service comes up (or changes)
 
NetworkStatusWarden-InterfaceDown, NetworkStatusWarden-InterfaceUp, NetworkStatusWarden-NetworkDown and NetworkStatusWarden-NetworkUp are bash scripts.

The example scripts simply write to a log file in /tmp. You should customise the scripts to your own needs.


## How to install:

Open the Terminal app, and download the latest [NetworkStatusWarden.pkg](https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden.pkg) installer to your desktop by typing the following command. 

	curl -k --silent --retry 3 --retry-max-time 6 --fail https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden.pkg --output ~/Desktop/NetworkStatusWarden.pkg

To install, double-click the downloaded package.

The installer will install the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.networkstatuswarden.plist
	/usr/NetworkStatusWarden/
	/usr/NetworkStatusWarden/bin/
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceUp
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkUp

There's no need to reboot.

After installation, your computer will write to the log file /tmp/NetworkStatusWarden.log whenever the network comes up or goes down. 

If the installer fails you should check the installation logs.

## Modifying the example scripts:

After installation, four simple example scripts can be found in the following location:

	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceUp
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkUp

These scripts simply write to the log file /tmp/NetworkStatusWarden.log whenever the network comes up or goes down. Modify the scripts to your own needs.

**NetworkStatusWarden-InterfaceDown**

	#!/bin/bash
	#
	# Called by NetworkStatusWarden as root like this:
	#   NetworkStatusWarden-InterfaceDown "InterfaceName"
	# i.e.
	#   NetworkStatusWarden-InterfaceDown "en0"
	
	# --------
	
	# Do Something Here
	
	# Get interface name
	sv_InterfaceName="${1}"
	
	# Do Something
	echo "$(date '+%d %b %Y %H:%M:%S %Z') InterfaceDown - network interface '${sv_InterfaceName}' down" >> /tmp/NetworkStatusWarden.log

**NetworkStatusWarden-InterfaceUp**

	#!/bin/bash
	#
	# Called by NetworkStatusWarden as root like this:
	#   NetworkStatusWarden-InterfaceUp "InterfaceName"
	# i.e.
	#   NetworkStatusWarden-InterfaceUp "en0"
	
	# --------
	
	# Do Something Here
	
	# Get interface name
	sv_InterfaceName="${1}"
	
	# Do Something
	echo "$(date '+%d %b %Y %H:%M:%S %Z') InterfaceUp - network interface '${sv_InterfaceName}' up" >> /tmp/NetworkStatusWarden.log

**NetworkStatusWarden-NetworkDown**

	#!/bin/bash
	#
	# Called by NetworkStatusWarden as root like this:
	#   NetworkStatusWarden-NetworkDown "ServiceName" "InterfaceName"
	# i.e.
	#   NetworkStatusWarden-NetworkDown "9804EAB2-718C-42A7-891D-79B73F91CA4B" "en0"
	
	# --------
	
	# Do Something Here
	
	# Get service name
	sv_ServiceName="${1}"
	
	# Get interface name
	sv_InterfaceName="${2}"
	
	# Do Something
	echo "$(date '+%d %b %Y %H:%M:%S %Z') NetworkDown - Primary network service '${sv_ServiceName}' down on '${sv_InterfaceName}'" >> /tmp/NetworkStatusWarden.log

**NetworkStatusWarden-NetworkUp**

	#!/bin/bash
	#
	# Called by NetworkStatusWarden as root like this:
	#   NetworkStatusWarden-NetworkUp "ServiceName" "InterfaceName"
	# i.e.
	#   NetworkStatusWarden-NetworkUp "9804EAB2-718C-42A7-891D-79B73F91CA4B" "en0"
	
	# --------
	
	# Do Something Here
	
	# Get service name
	sv_ServiceName="${1}"
	
	# Get interface name
	sv_InterfaceName="${2}"
	
	# Do Something
	echo "$(date '+%d %b %Y %H:%M:%S %Z') NetworkUp - Primary network service '${sv_ServiceName}' up on '${sv_InterfaceName}'" >> /tmp/NetworkStatusWarden.log

## How to uninstall:

Open the Terminal app, and download the latest [NetworkStatusWarden-Uninstaller.pkg](https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden-Uninstaller.pkg) uninstaller to your desktop by typing the following command. 

	curl -k --silent --retry 3 --retry-max-time 6 --fail https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden-Uninstaller.pkg --output ~/Desktop/NetworkStatusWarden-Uninstaller.pkg


To uninstall, double-click the downloaded package.

The uninstaller will remove the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.networkstatuswarden.plist
	/usr/NetworkStatusWarden/

After the uninstall everything goes back to normal, and network status up and down events will not be tracked.

There's no need to reboot.

## Logs:

The example scripts write to the following log file:

	/tmp/NetworkStatusWarden.log

The installer writes to the following log file:

	/Library/Logs/com.github.execriez.networkstatuswarden.log
  
You should check this log if there are issues when installing.

## History:

1.0.9 - 02 MAY 2022

* Compiled as a fat binary to support both Apple Silicon and Intel Chipsets. This version requires MacOS 10.9 or later.

* The example scripts now just write to a log file. Previously they made use of the "say" command.

* The package creation and installation code has been aligned with other "Warden" projects.

* The code now keeps track of interface status to make sure that up or down events are only triggered at status change.

* Removed the anti-flapping code from the example scripts as it doesn't appear to be needed since the latest updates.

1.0.8 - 20 JAN 2019

* A slight modification to the anti-flapping code in the example scripts, to make sure that multiple NetworkStatusWarden installs don't interfere with one another.

* Removed the anti-flapping code from the "InterfaceUp" and "InterfaceDown" scripts. It only makes sense in the "NetworkUp" and "NetworkDown" scripts to smooth out Primary Network fluctuations.

* Added comments to the anti-flapping code to emphasise that is optional.

1.0.7 - 16 NOV 2018

* The NetworkStatusWarden binary now always calls a "NetworkDown" script before the "NetworkUp" script when the active network service changes. Network down events were noticeably missing when disconnecting Cisco VPN client connections.

* The example scripts now include an anti-flapping section at the beginning. This smooths out events caused by the network service fluctuating between up and down. This is noticeable when disconnecting Cisco VPN client connections.

* The example scripts now write a log to "/tmp/NetworkStatusWarden.log"

1.0.6 - 03 OCT 2018

* Network events no longer wait for earlier events to finish before running. Events can now be running simultaneously.

* The example scripts have been simplified, and the readme has been improved.

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
