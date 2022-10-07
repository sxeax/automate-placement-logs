require 'webdrivers'

def element_present(driver:, class_name:)
  driver.find_elements(class: class_name).size > 0 ? driver.find_element(class: class_name) : nil
end

unless (username = ARGV[0]) && (password = ARGV[1])
  username = 'test-user'
  password = 'test-password'
end

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(timeout: 3, interval: 0.5, message: 'Timed out after 3 sec')
driver.navigate.to 'https://mahara.nottingham.ac.uk/'

driver.manage.timeouts.implicit_wait = 500

user_box = driver.find_element(name: 'login_username')
user_box.send_keys(username)

password_box = driver.find_element(name: 'login_password')
password_box.send_keys(password)

sleep 2

submit_button = driver.find_element(name: 'submit')
submit_button.click

sleep 2

if cookie_button = element_present(driver: driver, class_name: 'cc_btn')
  cookie_button.click
end


sleep 1

portfolio_button = driver.find_element(class: 'outer-link')
portfolio_button.click

sleep 1

edit_button = driver.find_element(xpath: "//a[@title='Edit this page']")
edit_button.click 

sleep 1

title_button = driver.find_element(xpath: "//a[@title='Add text snippets to your page']")
title_button.click 

sleep 1

submit_button = driver.find_element(id: 'addblock_submit')
submit_button.click 

sleep 1

title_box = driver.find_element(name: 'title')
title_box.clear
title_box.send_keys("Test log UID:#{rand(100)}")

sleep 2

text_box = driver.find_element(id: 'instconf_text_ifr')
sleep 0.5
text_box.send_keys(' Test description for test log')

sleep 1

save_button = driver.find_elements(xpath: "//*[starts-with(@id, 'instconf_action_configureblockinstance_id_')]")
save_button[1].click 

sleep 5

driver.close

puts 'Log created :)'

