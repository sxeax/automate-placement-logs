require 'mail'
require 'logger'

class EmailDriver

  attr_reader :entry_subject

  def initialize
    @logger = Logger.new(STDOUT)
    @entry_subject = 'Weekly Mahara Log entry time'

    email = File.readlines('secrets.txt').first.split[0]
    email_password = File.readlines('secrets.txt').first.split[1]

    delivery_options = { 
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => 'localhost',
      :user_name            => email,
      :password             => email_password,
      :authentication       => 'plain',
      :enable_starttls_auto => true  
    }  
    
    retriever_options = {
      :address    => "imap.gmail.com",
      :port       => 993,
      :user_name  => email,
      :password   => email_password,
      :enable_ssl => true
    }
    
    Mail.defaults do
    delivery_method :smtp, delivery_options
    retriever_method :imap, retriever_options
    end

    @logger.info('Initialized logger correct retriever options and delivery options')
  end

  def send_email(subject:, body:, file: nil)
    Mail.deliver do
      from    'seanbutcher17@gmail.com'
      to      'seanbutcher17@gmail.com'
      subject subject
      body    body
      add_file :filename => file, :content => File.read('./' + file) unless file.nil?
    end
    @logger.info("Sent email to myself. Subject: #{subject}. Body: #{body}")
  end

  def check_reply
    @logger.info('Checking for replies now')
    reply = ''
    while reply.empty?
      @logger.info('Scanning for replies')
      emails = Mail.find(:what => :last, :count => 6, :order => :dsc)
      emails.each do |email|
        next unless email.multipart?
        if email.subject.include?(@entry_subject)
          reply = email.parts[email.parts.length - 1].decoded
          break
        end
      end
      break unless reply.empty?
      sleep 30
      @logger.info('Unable to find reply. Checking again')
    end
    @logger.info('Reply located')
    reply.scan(/(?<=\<div dir="auto">).*?(?=<\/div>)/).reduce { |total, curr| curr.include?('<br>') ? total : total + "\n" + curr}
  end

end




