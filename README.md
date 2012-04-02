MacBak
======

Makes backups of specified folders on your Mac to a network share over
ssh.

Apple's Timemachine is great, however I did not feel like having a
external drive plugged into my macbook pro the whole time, and with the
severly crippled network backup functionality, where it's unable(without
some hacks) to backup to a non-Apple server over a network, I wrote my
own backup utility that uses rsync to make backups to a remote server.

Functionality
-------------

Two backup modes.

* backup
* sync

Most users should use the "backup" mode. No deletes happens on the backup
server, so say you have a document and you accidently deleted it, it will still
be on the backup server. Sync on the other hand will remove a file from the backup
server if it get's removed locally as well. Sync is usefull if you want to 
keep two Mac's in sync. For example you want the exact same Documents folder
on your Macbook and iMac. Usefull to keep two Linux servers in sync as well :)

Usage
-----

* Run it manually ./MacBak.rb from the command line
* Create a Launchd plist file (check repo for example)
* Schedule it in cron

NOTE : Apart from the alerts, it should work perfectly on Linux as well,
just make ALERT off in the conf file. Infact I use MacBak to keep certain
directories on Ubuntu Linux servers in sync.

Todo
----

For my needs the script works great and I depend on it daily, however
it would be nice to have a easier...almost more Mac friendly way of
adding the folders you want to backup and do the scheduling.
