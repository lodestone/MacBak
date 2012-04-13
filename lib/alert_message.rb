# Alert Message
# Easy way to send various alert messages from Ruby
# Coded by Werner Gillmer <werner.gillmer@gmail.com>

require 'ruby-growl'
require 'pony'
require 'yaml'

class AlertMessage
 def alert(alert,message)
    case alert
    	# Growl
      when "growl"
        g = Growl.new "localhost", "ruby-growl", ["ruby-growl Notification"]
        g.notify "ruby-growl Notification", "MacBak", "#{message}"

      # Email  
      when "email"
        Pony.mail(:to => @emailAddress,
                  :from => 'macbak@yourmacorpc.fake',
                  :subject => 'MacBak',
                  :body => "#{message} \n")
        
      when "off"
  	    puts "OFF: #{message}"
     end 
   end
end
