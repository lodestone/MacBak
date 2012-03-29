#!/usr/bin/env ruby
# Ruby version of Macbak.sh
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

require 'yaml'
require 'socket'
require 'timeout'
require 'net/ssh'
require 'ruby-growl'

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

			@backupList.each do |backup|
				if Dir.exist?(backup)
					return true
				else
					puts "ERROR: #{backup} does not exsist"
					Process.exit
				end
			end

	else
		confError = "ERROR : #{@confFile} was not found."
		puts confError
		system "nohup osascript -e 'tell app \"System Events\" to display dialog \"#{confError}\"' &"
		Process.exit
	end
end

# Sends alert message based on ALERT configured in confFile
def alertMessage(message)
	case @alert
		when "growl"
    	puts "Growl : #{message}"
    	g = Growl.new "localhost", "ruby-growl",
    		              ["ruby-growl Notification"]
    	g.notify "ruby-growl Notification", "It Came From Ruby-Growl",
    		         "Greetings!"
		when "dialog"
			system "nohup osascript -e 'tell app \"System Events\" to display dialog \"#{message}\"' &"
		when "finder_dialog"
			system "nohup osascript -e 'tell app \"Finder\" to display dialog \"#{message}\"' &"
		when "email"
			puts "EMAIL : #{message}"
		when "off"
			puts "OFF: #{message}"
	end
end


def syncNow

	rsyncOptions = "-z --progress --stats -a" 
	backupSSH = "-e \"ssh -i #{@sshKey}\" #{@username}@#{@backupServer}" 

	@backupList.each do |directory| 
		case @backupType
			when "backup"
				backupCommand = "rsync #{rsyncOptions} #{directory} #{backupSSH}:#{@backupPath}"
					system backupCommand
			when "sync"
			  dirname, basename = File.split(directory)
				backupCommand = "rsync #{rsyncOptions} --delete #{directory} #{backupSSH}:#{dirname}"
				system backupCommand
			else
				alertMessage("Unkown value for BACKUP_TYPE in #{@confFile}")
				Process.exit
		end
	end	
end

# Start of main 
confCheck

# Check if the backup server is available
begin
	s = TCPSocket.new(@backupServer,'22')
	# Check if we can successfully authenticate
	begin
		ssh =Net::SSH.start(
				 @backupServer,@username,
		     :keys => [@sshKey])
     
   			   syncNow 
  
	rescue Net::SSH::AuthenticationFailed, Errno::ECONNREFUSED
		alertMessage("MacBak ERROR : Authentication failed for #{@username} againts #{@backupServer}")
		Process.exit
	end
rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
	alertMessage("MacBak ERROR : Cannot connect to #{@backupServer}")
	Process.exit
end






