#!/usr/bin/env ruby
# Ruby version of Macbak.sh
# Coded by Werner Gillmer <werner.gillmer@gmail.com>
# v0.0.1

require 'yaml'
require 'ssh_test'
require 'rsync_wrap'
require './lib/alert_message.rb'
require 'find'
require 'listen'
require 'daemons'

# Does the rsync work
def syncNow(directory)
	puts "syncNow #{directory}"
    backup = RsyncWrap.new(
	  	'transport' => 'ssh',
   	  'backup' => @backupType,
	  	'username' => @username,
	  	'keyfile' => @sshKey, 
	  	'server' => @backupServer,
	  	'compress' => true,
	  	'logging' => true  # Set this to true for debugging. Logs to /tmp/rsyncwrap.log
    	)
			backup.rsync(directory,@backupPath)
end

# Watch the backup dirs for changes
# startup = true or false, if true it forces a 
# sync without checking if something changed.
def watchDirs
    Daemons.daemonize

	@backupList.each do |dir|
		puts "Watching #{dir}"
	  pid = fork do 
        Listen.to(dir) do |modified, added, removed|
         syncNow(dir)
				end
	 			syncNow(dir)
			end
     ### #@message.alert(@alert,"#{dir}")
  	  end
    Process.detach(pid)
end

# Main

	# Check for configuration file
	@confFile = File.dirname(File.expand_path(__FILE__)) + '/macbak.cnf'
		if File.exist?(@confFile)
			config = YAML::load(File.open(@confFile))
				@backupServer = config['BACKUP_SERVER']
				@username = config['USERNAME']
				@alert = config['ALERT']
				@sshKey = config['SSH_KEY']
				@backupType = config['BACKUP_TYPE']
				@emailAddress = config['EMAIL_ADDRESS']
				@backupPath = config['BACKUP_PATH']
				@backupList = config['BACKUP_LIST']

        # alert message object
	      @message = AlertMessage.new

	else
		puts "ERROR : #{@confFile} was not found."
		Process.exit
	end

  # Check if backup directories actually exist.
  @backupList.each do |dir|
  	if File.exist?(dir)
  	 puts "found #{dir}"	
		else
			@message.alert(@alert,"Cannot find #{dir} exiting...")
			Process.exit
		end
	end

	# Check if the backup server is available
	ssh = SSHTest.new
	if ssh.test(@backupServer,@username,@sshKey) == false
		@message.alert(@alert,"ERROR : ssh failed")
		Process.exit
  end

	 # Everything tested 100% let's start a initial sync
 	 # and then start watching the dirs
	 	 watchDirs
	 	 
