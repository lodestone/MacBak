#!/usr/bin/env bash
# Does a rsync backup over ssh. Key access must be enabled and working.
# The BACKUP_PATH must exsist on the server where the backups is going to.
# Schedule this script with cron/launchd if you want.
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

BACKUP_SERVER="10.0.0.15"
BACKUP_PATH="/home/wernerg/backups/macbookpro"
AVAIL_CHECK=`nmap $BACKUP_SERVER -p 22 | awk '/open/ {print $2}'`
USERNAME="wernerg"

if [ -z $AVAIL_CHECK ]; then
  echo "$BACKUP_SERVER is not availible"
else
  echo "Starting backup to $BACKUP_SERVER"
  # Do something usefull with --stats!!
  rsync --stats -a --progress /Users/wernergillmer/Documents -e ssh $USERNAME@$BACKUP_SERVER:$BACKUP_PATH
  rsync --stats -a --progress /Users/wernergillmer/Code -e ssh $USERNAME@$BACKUP_SERVER:$BACKUP_PATH
  rsync --stats -a --progress /Users/wernergillmer/Pictures -e ssh $USERNAME@$BACKUP_SERVER:$BACKUP_PATH


  #########
  # Do some sort of DEFAULT_ALERT, thing here.

  # Dialog box to alert backups was done.
  # Makes finder icon bounch and on click shows dialog box.
  ## nohup osascript -e 'tell app "Finder" to display dialog "Backups done"' &
  # Pops a dialog box directly open on the screen.
  ### osascript -e 'tell app "System Events" to display dialog "Backups done"'
  # Growl notication
  GROWL=`osascript check_growl | grep true`
  if [ -z $GROWL ]; then
    # Cannot find Growl default to dialog
    nohup osascript -e 'tell app "Finder" to display dialog "Backups done"' &
  else
    osascript ./message_growl
  fi

fi
