#!/usr/bin/env ruby
# Ruby version of Macbak.sh
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

require 'yaml'
require 'ruby-growl'
require 'ssh_test'
require 'rsync_wrap'
require 'pony'

@confFile = File.dirname(File.expand_path(__FILE__)) + '/macbak.cnf'

# Testing for conf file
def confCheck
	if File.exist?("#{@confFile}")
		config = YAML::load(File.open(@confFile))
			@backupServer = config['BACKUP_SERVER']
			@username = config['USERNAME']
			@alert = config['ALERT']
			@sshKey = config['SSH_KEY']
			@backupType = config['BACKUP_TYPE']
			@emailAddress = config['EMAIL_ADDRESS']
			@backupPath = config['BACKUP_PATH']
			@backupList = config['BACKUP_LIST']
	else
		puts "ERROR : #{@confFile} was not found."
		Process.exit
	end
end

# Sends alert message based on ALERT configured in confFile
def alertMessage(message)
	case @alert
		when "growl"
    	g = Growl.new "localhost", "ruby-growl",
    		              ["ruby-growl Notification"]
    	g.notify "ruby-growl Notification", "MacBak",
    		         "#{message}"
		when "email"
      Pony.mail(:to => @emailAddress,
      					:from => 'macbak@yourmacorpc.fake',
      					:subject => 'MacBak',
      					:body => "#{message} \n")	
		when "off"
			puts "OFF: #{message}"
	end
end


# Does the rsync work
def syncNow
	@backupList.each do |directory|
    backup = RsyncWrap.new(
	  	'transport' => 'ssh',
	  	'backup' => @backupType,
	  	'username' => @username,
	  	'keyfile' => @sshKey, 
	  	'server' => @backupServer,
	  	'progress' => true
    	)
			backup.rsync(directory,@backupPath)
			# If alert is email, a mail goes out for every
			# directory getting backed up. Might be too much
			# spam. Move this alertMessage out of the syncNow 
			# function?
			alertMessage("#{directory} backup done")
	  end	
end

# Start of main 
confCheck

# Check if the backup server is available
ssh = SSHTest.new
if ssh.test(@backupServer,@username,@sshKey) == false
	alertMessage( "ERROR : ssh failed")
	Process.exit
else
  syncNow	
end	

