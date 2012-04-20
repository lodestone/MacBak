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
	  	'progress' => true
    	)
			backup.rsync(directory,@backupPath)
end

# Watch the backup dirs for changes
def watchDirs
	@backupList.each do |dir|
	  pid = fork do 
		  puts "Watching #{dir}"
      Listen.to(dir) do |modified, added, removed|
          syncNow(dir)
      #@message.alert(@alert,"#{dir}")
      	`echo "\`date +%H:%M:%S\` :: #{dir}" >> /tmp/macbak.log`
  	  end
		end 
  #  `echo #{pid} >> /tmp/macbak.pid`
    Process.detach(pid)
  end 
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

	 # Everything tested 100% let's start watching the
	 # directories we want to backup
	   Daemons.daemonize
	 	 watchDirs
