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

These example scripts use the "say" command to speak whenever there is a network event. You should customise the scripts to your own needs.


## How to install:

Download the NetworkStatusWarden installation package here [NetworkStatusWarden.pkg](https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden.pkg)

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

After installation, your computer will speak during network up and down events.

If the installer fails you should check the installation logs.

## Modifying the example scripts:

After installation, four simple example scripts can be found in the following location:

	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-InterfaceUp
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkDown
	/usr/NetworkStatusWarden/bin/NetworkStatusWarden-NetworkUp

These simple scripts use the "say" command to speak to let you know when the network is up or down. Modify the scripts to alter this default behaviour.

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

	nf_DoSomething()
	{
	  echo "${1}" >> /tmp/NetworkStatusWarden.log
	  say "${1}"
	}

	# Get a pronouncable interface name
	sv_PronouncableInterfaceName="$(echo "${sv_InterfaceName}" | sed "s|\(.\)|\1 |g")"

	nf_DoSomething "Network interface down - ${sv_PronouncableInterfaceName}"

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

	nf_DoSomething()
	{
	  echo "${1}" >> /tmp/NetworkStatusWarden.log
	  say "${1}"
	}

	# Get a pronouncable interface name
	sv_PronouncableInterfaceName="$(echo "${sv_InterfaceName}" | sed "s|\(.\)|\1 |g")"

	nf_DoSomething "Network interface up - ${sv_PronouncableInterfaceName}"

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

	nf_DoSomething()
	{
	  echo "${1}" >> /tmp/NetworkStatusWarden.log
	  say "${1}"
	}

	# Get a pronouncable interface name
	sv_PronouncableInterfaceName="$(echo "${sv_InterfaceName}" | sed "s|\(.\)|\1 |g")"

	if [ "${sv_ServiceName}" = "com.cisco.anyconnect" ]
	then
	  nf_DoSomething "Cisco VPN service down - on ${sv_PronouncableInterfaceName}"
	else
	  nf_DoSomething "Primary network service down - on ${sv_PronouncableInterfaceName}"
	fi

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

	nf_DoSomething()
	{
	  echo "${1}" >> /tmp/NetworkStatusWarden.log
	  say "${1}"
	}

	# Get a pronouncable interface name
	sv_PronouncableInterfaceName="$(echo "${sv_InterfaceName}" | sed "s|\(.\)|\1 |g")"

	if [ "${sv_ServiceName}" = "com.cisco.anyconnect" ]
	then
	  nf_DoSomething "Cisco VPN service up - on ${sv_PronouncableInterfaceName}"
	else
	  nf_DoSomething "Primary network service up - on ${sv_PronouncableInterfaceName}"
	fi

## How to uninstall:

Download the NetworkStatusWarden uninstaller package here [NetworkStatusWarden-Uninstaller.pkg](https://raw.githubusercontent.com/execriez/NetworkStatusWarden/master/SupportFiles/NetworkStatusWarden-Uninstaller.pkg)

The uninstaller will remove the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.networkstatuswarden.plist
	/usr/NetworkStatusWarden/

After the uninstall everything goes back to normal, and network up and down events will not be tracked.

There's no need to reboot.

## Logs:

The NetworkStatusWarden binary writes to the following log file:

	/var/log/systemlog
  
The following is an example of a typical system log file entry:

	Oct  3 19:32:42 mymac-01 NetworkStatusWarden[1951]: Interface up: en1
	Oct  3 19:32:45 mymac-01 NetworkStatusWarden[1951]: Primary network service up: old unset (unset), new 9804EAB2-718C-42A7-891D-79B73F91CA4B (en1)
	Oct  3 19:32:54 mymac-01 NetworkStatusWarden[1951]: Interface down: en1
	Oct  3 19:32:57 mymac-01 NetworkStatusWarden[1951]: Primary network service down: old 9804EAB2-718C-42A7-891D-79B73F91CA4B (en1), new unset (unset)

The installer writes to the following log file:

	/Library/Logs/com.github.execriez.networkstatuswarden.log
  
You should check this log if there are issues when installing.

## History:

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
