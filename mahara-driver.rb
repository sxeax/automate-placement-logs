require 'webdrivers'
require 'time'
require 'logger'
require 'mail'

class Driver

  def initialize 
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    @driver = Selenium::WebDriver.for :chrome, capabilities: options
    @driver.manage.timeouts.implicit_wait = 2
    @logger = Logger.new(STDOUT)
  end

  def add_log(username, password, log_description)
    login username, password
    access_portfolio_page
    add_log_entry log_description
  end

  private
  def login username, password
    @logger.info('About to navigate to Mahara')
    @driver.navigate.to 'https://mahara.nottingham.ac.uk/'
    
    user_box = @driver.find_element(name: 'login_username')
    user_box.send_keys(username)
    
    password_box = @driver.find_element(name: 'login_password')
    password_box.send_keys(password)

    sleep 0.5

    submit_button = @driver.find_element(name: 'submit')
    submit_button.click
    @logger.info('Logged into mahara')
  end

  def access_portfolio_page
    @logger.info('Accessing portfolio page')
    clear_cookie_button

    portfolio_button = @driver.find_element(class: 'outer-link')
    portfolio_button.click
    @logger.info('Accessed into portfolio page')
  end

  def add_log_entry description

    latest_log_title = @driver.find_element(class: 'panel-heading')
    new_log_title = next_log_title(current_title: latest_log_title.text)

    @logger.info('Clicking onto edit')
    edit_button = @driver.find_element(xpath: "//a[@title='Edit this page']")
    edit_button.click 

    sleep 0.5

    @logger.info('Clicking adding text button unto page')
    title_button = @driver.find_element(xpath: "//a[@title='Add text snippets to your page']")
    title_button.click 

    sleep 0.5

    @logger.info('Clicking the add block')
    submit_button = @driver.find_element(id: 'addblock_submit')
    submit_button.click 

    sleep 2

    @logger.info('Adding title into title box')
    title_box = @driver.find_element(name: 'title')
    title_box.clear
    title_box.send_keys(new_log_title)

    sleep 0.5

    @logger.info('Adding text into text box')
    text_box = @driver.find_element(id: 'instconf_text_ifr')
    sleep 0.5
    text_box.send_keys(" " + description)

    sleep 0.5

    @logger.info('Clicking save button')
    save_button = @driver.find_elements(xpath: "//*[starts-with(@id, 'instconf_action_configureblockinstance_id_')]")
    save_button[1].click 

    sleep 1
  end

  def clear_cookie_button 
    sleep 0.5
    if cookie_button = element_present(class_name: 'cc_btn')
      @logger.info('Cookie button had to be cleared')
      cookie_button.click
      sleep 0.5
    end
  end

  def element_present(class_name:)
    @driver.find_elements(class: class_name).size > 0 ? @driver.find_element(class: class_name) : nil
  end

  def next_log_title(current_title:)
    @logger.info("Given this current title: #{current_title}")
    log_number = current_title.split[1].to_i
    log_date = Date.parse(current_title.split[4])
    new_log_title = "Week #{log_number + 1} Log - #{(log_date + 7).strftime('%d/%m/%Y')}"
    @logger.info("New log title generated: #{new_log_title}")
    new_log_title
  end

end

d = Driver.new

unless (username = ARGV[0]) && (password = ARGV[1])
  username = 'testuser'
  password = 'testpass'
end

email = 'test-email'
email_password = 'test-email-pass'

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

lorem_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc molestie non nunc nec cursus. Mauris nulla quam, bibendum sed blandit eget, vehicula et lectus. Nulla porta, sem in imperdiet tincidunt, mi nibh dictum lacus, nec ullamcorper purus magna nec augue. Maecenas id gravida orci, eget cursus tortor. Sed a feugiat nibh, vitae elementum ante. Nam nibh nibh, porta eget laoreet eget, lacinia eu nunc. Donec ac facilisis sem. Quisque placerat rhoncus augue, vel malesuada felis varius eget. Fusce eu sodales lacus, ac euismod sapien. Donec tincidunt orci sit amet metus hendrerit, in fringilla velit maximus. Aliquam pretium purus at ligula.'

Mail.deliver do
  from    'seanbutcher17@gmail.com'
  to      'seanbutcher17@gmail.com'
  subject 'This is a test email'
  body    lorem_text
end

last_email = Mail.last

puts last_email.date.to_s
puts last_email.subject
log_description_work = last_email.multipart? ? last_email.parts[last_email.parts.length - 1].decoded : last_email.decoded

puts log_description_work

d.add_log username, password, log_description_work
