MacBak
======

Makes backups of specified folders on your Mac to a network share over
ssh.

Apple's Timemachine is great, however I did not feel like having a
external drive plugged into my macbook pro the whole time, and with the
severly crippled network backup functionality, where it's unable(without
some hacks) to backup to a non-Apple server over a network, I wrote my
own backup utility that uses rsync to make backups to a remote server.

Usage
-----

* Run it manually ./MacBak.sh from the command line
* Create a Launchd plist file (check repo for example)
* Schedule it in cron

NOTE : Apart from the alerts, it should work perfectly on Linux as well,
just make ALERT blank in the conf file.

Todo
----

For my needs the script works great and I depend on it daily, however
it would be nice to have a easier...almost more Mac friendly way of
adding the folders you want to backup and do the scheduling.