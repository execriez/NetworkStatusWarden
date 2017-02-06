#!/bin/bash
#
# Short:    Install NetworkStatusWarden from the command-line
# Author:   Mark J Swift
# Version:  1.0.2
# Modified: 04-Jan-2017
#

# ---

GLB_Tag="Example"

# Set the signature for the NetworkStatusWarden installation
GLB_NetworkStatusWardenSignature="com.github.execriez.NetworkStatusWarden"

# Path to this script
GLB_MyDir="$(dirname "${0}")"

# Change working directory
cd "${GLB_MyDir}"

# Filename of this script
GLB_MyFilename="$(basename "${0}")"

# Filename without extension
GLB_MyName="$(echo ${GLB_MyFilename} | sed 's|\.[^.]*$||')"

# Full souce of this script
GLB_MySource="${0}"

# ---

# Get user name
GLB_UserName="$(whoami)"

# ---

# Check if user is an admin (returns "true" or "false")
if [ "$(dseditgroup -o checkmember -m "${GLB_UserName}" -n . admin | cut -d" " -f1)" = "yes" ]
then
  GLB_IsAdmin="true"
else
  GLB_IsAdmin="false"
fi

# ---

if [ "${GLB_IsAdmin}" = "false" ]
then
  echo "Sorry, you must be an admin to install this script."
  echo ""

else
  echo ""
  echo "Installing NetworkStatusWarden."
  echo "If asked, enter the password for user '"${GLB_UserName}"'"
  echo ""
  
  sudo su root <<HEREDOC

  # Delete any unwanted files from the install
  find "${GLB_MyDir}" -iname .DS_Store -exec rm -f {} \;

  # Lets begin
  mkdir -p /usr/local/NetworkStatusWarden
  chown root:wheel /usr/local/NetworkStatusWarden
  chmod 755 /usr/local/NetworkStatusWarden
  
  if test -f "${GLB_MyDir}/LICENSE"
  then
    cp "${GLB_MyDir}/LICENSE" /usr/local/NetworkStatusWarden/
    chown root:wheel "/usr/local/NetworkStatusWarden/LICENSE"
    chmod 755 "/usr/local/NetworkStatusWarden/LICENSE"
  fi
  
  if test -f "${GLB_MyDir}/README.md"
  then
    cp "${GLB_MyDir}/README.md" /usr/local/NetworkStatusWarden/
    chown root:wheel "/usr/local/NetworkStatusWarden/README.md"
    chmod 755 "/usr/local/NetworkStatusWarden/README.md"
  fi
  
  if test -d "${GLB_MyDir}/payload"
  then
    mkdir -p /usr/local/NetworkStatusWarden/${GLB_Tag}
    chown root:wheel /usr/local/NetworkStatusWarden/${GLB_Tag}
    chmod 755 /usr/local/NetworkStatusWarden/${GLB_Tag}

    cp -pR "${GLB_MyDir}/payload/" "/usr/local/NetworkStatusWarden/${GLB_Tag}/"
    chown -R root:wheel "/usr/local/NetworkStatusWarden/${GLB_Tag}"
    chmod -R 755 "/usr/local/NetworkStatusWarden/${GLB_Tag}"

    if test -f "/usr/local/NetworkStatusWarden/${GLB_Tag}/NetworkStatusWarden"
    then
      cat << EOF > /Library/LaunchDaemons/${GLB_NetworkStatusWardenSignature}.${GLB_Tag}.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${GLB_NetworkStatusWardenSignature}.${GLB_Tag}</string>
	<key>Program</key>
	<string>/usr/local/NetworkStatusWarden/${GLB_Tag}/NetworkStatusWarden</string>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<false/>
</dict>
</plist>
EOF
      chown root:wheel /Library/LaunchDaemons/${GLB_NetworkStatusWardenSignature}.${GLB_Tag}.plist
      chmod 644 /Library/LaunchDaemons/${GLB_NetworkStatusWardenSignature}.${GLB_Tag}.plist

    fi
  fi
    
  echo "PLEASE REBOOT."
  echo ""

HEREDOC

fi
