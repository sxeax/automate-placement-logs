require 'webdrivers'
require 'time'
require 'logger'

class MaharaDriver

  def initialize 
    @username = File.readlines('secrets.txt')[1].split[0]
    @pasword = File.readlines('secrets.txt')[1].split[1]
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--ignore-ssl-errors=yes')
    options.add_argument('--ignore-certificate-errors')
    @driver = Selenium::WebDriver.for :chrome, capabilities: options
    @driver.manage.timeouts.implicit_wait = 2
    @driver.manage.window.resize_to(1920, 1080)
    @driver.manage.window.maximize
    @logger = Logger.new(STDOUT)
  end

  def add_log(log_description)
    login 
    access_portfolio_page
    add_log_entry log_description
    
    @driver.save_screenshot("screenshot.png")
    @driver.current_url
  end

  private
  def login 
    @logger.info('About to navigate to Mahara')
    @driver.navigate.to 'https://mahara.nottingham.ac.uk/'
    
    user_box = @driver.find_element(name: 'login_username')
    user_box.send_keys(@username)
    
    password_box = @driver.find_element(name: 'login_password')
    password_box.send_keys(@pasword)

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

    sleep 0.5

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

    sleep 0.5


    display_buttons = @driver.find_elements(xpath:"//a")
    display_button = display_buttons.find { |button| button.text.include? 'Display page'}
    display_button.click

    sleep 0.5
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
