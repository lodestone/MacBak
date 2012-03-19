#!/usr/bin/env bash
# Does a rsync backup over ssh
# Schedule this script with cron/launchd if you want.
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

BACKUP_SERVER="10.0.0.15"
AVAIL_CHECK=`nmap $BACKUP_SERVER -p 22 | awk '/open/ {print $2}'`

if [ -z $AVAIL_CHECK ]; then
  echo "$BACKUP_SERVER is not availible"
else
  echo "Starting backup to $BACKUP_SERVER"
  rsync --stats -a --progress /Users/wernergillmer/Documents -e ssh wernerg@$BACKUP_SERVER:/home/wernerg/backups/macbookpro
  rsync --stats -a --progress /Users/wernergillmer/Code -e ssh wernerg@$BACKUP_SERVER:/home/wernerg/backups/macbookpro
  rsync --stats -a --progress /Users/wernergillmer/Pictures -e ssh wernerg@$BACKUP_SERVER:/home/wernerg/backups/macbookpro

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
