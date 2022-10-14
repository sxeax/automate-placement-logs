require_relative '../lib/mahara-driver.rb'
require_relative '../lib/email-driver.rb'


email = EmailDriver.new
mahara = MaharaDriver.new

email.send_email(subject: email.entry_subject, body: "Hi Sean, time to tell me what you've done this week!")

reply = email.check_reply

url = mahara.add_log(reply)

email.send_email(subject: 'Log added', body: "This is to let you know the log has been added. The log can be found at this url: #{url}, and in the attatched screenshot.", file: 'screenshot.png')

