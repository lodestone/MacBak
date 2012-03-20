#!/usr/bin/env bash
# Does a rsync backup over ssh. Key access must be enabled and working.
# The BACKUP_PATH must exsist on the server where the backups is going to.
# Schedule this script with cron/launchd if you want.
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

if [ -f ./macbak.conf ]; then
  source ./macbak.conf
else
  echo "ERROR : config file not found."
  exit
fi

AVAIL_CHECK=`nmap $BACKUP_SERVER -p 22 | awk '/open/ {print $2}'`
if [ -z $AVAIL_CHECK ]; then
  echo "$BACKUP_SERVER is not availible"
else
  echo "Starting backup to $BACKUP_SERVER"
  echo "`date \"+%d-%m-%y %H:%M\"` Starting backups" >> ./macbak.log

  # Do something usefull with --stats!!
  rsync --stats -a --progress /Users/wernergillmer/Documents -e "ssh -i $SSH_KEY" $USERNAME@$BACKUP_SERVER:$BACKUP_PATH
  rsync --stats -a --progress /Users/wernergillmer/Code -e "ssh -i $SSH_KEY" $USERNAME@$BACKUP_SERVER:$BACKUP_PATH
  rsync --stats -a --progress /Users/wernergillmer/Pictures -e "ssh -i $SSH_KEY" $USERNAME@$BACKUP_SERVER:$BACKUP_PATH

  # Write log entry to verify later that the backups ran.
  echo "`date \"+%d-%m-%y %H:%M\"` Backups done" >> ./macbak.log


  # Show configued alert box.
  case $ALERT in
    growl)
      # Growl notication
      GROWL=`osascript check_growl | grep true`
      if [ -z $GROWL ]; then
        # Cannot find Growl default to dialog
        nohup osascript -e 'tell app "Finder" to display dialog "Backups done"' &
      else
        osascript ./message_growl
      fi
    ;;
    dialog)
      nohup osascript -e 'tell app "System Events" to display dialog "Backups done"' &
    ;;
    finder_dialog)
      nohup osascript -e 'tell app "Finder" to display dialog "Backups done"' &
    ;;
    *)
      # $ALERT is set to empty, so show no alert box.
      echo "backup done"
  esac

fi
