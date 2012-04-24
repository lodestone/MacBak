### MacBak

Runs in the background and monitor the specified directories, and makes
backups as files change.

Apple's Timemachine is great, however I did not feel like having a
external drive plugged into my macbook pro the whole time, and with the
severly crippled network backup functionality, where it's unable(without
some hacks) to backup to a non-Apple server over a network, I wrote my
own backup utility that uses rsync to make backups to a remote server.

### Usage

Open up macback.cnf and edit the file according to your needs.

* Run it manually ./MacBak.rb from the command line

NOTE : Apart from the alerts, it should work perfectly on Linux as well,
alerting will work if it's not set to growl. Infact I use MacBak to keep certain
directories on Ubuntu Linux servers in sync with the clone function. If you do 
run this one Linux add the following line to your /etc/sysctl.conf file

    fs.inotify.max_user_watches=100000

### Requirements

To get Growl notifications working on your Mac, make sure that
"Listen for incoming notifications" and "Allow remote application registration"
for growl in your System Preferences is checked.

### Todo

For my needs the script works great and I depend on it daily, however
it would be nice to have a easier...almost more Mac friendly way of
adding the folders you want to backup and do the scheduling.

