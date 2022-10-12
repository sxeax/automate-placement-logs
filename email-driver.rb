require 'mail'

class EmailDriver

  attr_reader :entry_subject

  def initialize 
    @entry_subject = 'Weekly Mahara Log entry time'

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
  end

  def send_email(subject:, body:)
    Mail.deliver do
      from    'seanbutcher17@gmail.com'
      to      'seanbutcher17@gmail.com'
      subject subject
      body    body
    end
  end

  def check_reply
    reply = ''
    while reply.empty?
      emails = Mail.find(:what => :last, :count => 6, :order => :dsc)
      emails.each do |email|
        next unless email.multipart?
        if email.subject.include?(@entry_subject)
          reply = email.parts[email.parts.length - 1].decoded
          break
        end
      end
      break unless reply.empty?
      sleep 60
    end
    reply
  end

  def parse_reply(reply:)
    reply.scan(/(?<=\<div dir="auto">).*?(?=<\/div>)/).reduce { |total, curr| curr.include?('<br>') ? total : total + "\n" + curr}
  end
end




