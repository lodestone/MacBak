#!/usr/bin/env ruby
# Ruby version of Macbak.sh
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

require 'yaml'
require 'ruby-growl'
require 'ssh_test'
require 'rsync_wrap'
require 'pony'
require 'find'

# Sends alert message based on ALERT configured in confFile
def alertMessage(message)
	case @alert
		when "growl"
    	g = Growl.new "localhost", "ruby-growl", ["ruby-growl Notification"]
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

### Start of main
# Check for configuration file
@confFile = File.dirname(File.expand_path(__FILE__)) + '/macbak.cnf'
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

			# Handle "size" command line argument.
			# Passing size gives the size of your dirs you
			# want to backup back and then exit
      if ARGV[0] == 'size'
      	puts "Calculating..."
      	@backupList.each do |dir|
      		# Security issue? It's possible to make one of
      		# the dirs in BACKUP_LIST in the conf file
      		# a command like "; rm -Rf /" and that will get parsed
      		# into the dir varible here.
      		dirSize = `du -hs #{dir}`
					puts "#{dirSize}"
				end  
				puts "done"
	     	Process.exit
      end
	else
		puts "ERROR : #{@confFile} was not found."
		Process.exit
	end

# Check if the backup server is available
ssh = SSHTest.new
if ssh.test(@backupServer,@username,@sshKey) == false
	alertMessage( "ERROR : ssh failed")
	Process.exit
else
  # Check for run file. The run file get's used to
  # stop MacBak from starting if another instance is
  # still running
  @runFile = '/tmp/.macbak.run'
  if File.exist?(@runFile)
    puts "Another instance of MacBak is already running"
		Process.exit
	else
		# Create a new file and continue running
		File.open(@runFile,"w") {}
	end

	# Everything tested 100% do the backups now
  syncNow
  # remove the run file now, so that MacBak will
  # run on the next execute.
	File.delete(@runFile) 
end	

