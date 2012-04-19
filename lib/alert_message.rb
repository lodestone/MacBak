# Alert Message
# Easy way to send various alert messages from Ruby
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

require 'ruby-growl'
require 'pony'
require 'yaml'

class AlertMessage

 def init
 	 @confFile = File.dirname(File.expand_path(__FILE__)) + '/macbak.cnf'
 	 config = YAML::load(File.open(@confFile))
 	 @backupServer = config['BACKUP_SERVER']
   @username = config['USERNAME']
   @alert = config['ALERT']
   @sshKey = config['SSH_KEY']
   @backupType = config['BACKUP_TYPE']
   @emailAddress = config['EMAIL_ADDRESS']
   @backupPath = config['BACKUP_PATH']
   @backupList = config['BACKUP_LIST']
 end

 def alert(alert,message)
    case alert
    	# Growl
      when "growl"
        g = Growl.new "localhost", "ruby-growl", ["ruby-growl Notification"]
        g.notify "ruby-growl Notification", "MacBak", "#{message}"

			# TODO : Not working.	 
      # Email  
      when "email"
        Pony.mail(:to => @emailAddress,
                  :from => 'macbak@yourmacorpc.fake',
                  :subject => 'MacBak',
                  :body => "#{message} \n")

      # TODO : Not working.  
      when "off"
  	    puts "OFF: #{message}"
     end 
   end
end
