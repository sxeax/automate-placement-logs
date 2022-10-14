# automate-placement-logs

For my placement I have to create a log in Mahara each week. This log outlines my accomplishments and what I've done etc, however I have consistently forgotten to create this log meant I have to do bulk logs. I have created this project to help me fix this issue!

As of now, this project can send you an automated email asking what you completed this week. It will then scan the inbox for replies, and if a reply is found it will extract the body of that email. Selenium is then used to navigate through Mahara to create a log for you with that extracted body, and also a correct title (formulating it from the previous log's title). Selenium can then take a screenshot of the created log, as well as the url of the new log and send you another email acknowledging that this was created.

Skill developed/ improved from this project:
- Selenium to auotmate navigating websites
- Scraping HTML of websites to find useful information
- Setting up email servers locally to be able to recieve and send emails
- Improving my overall Ruby knowledge to help create an efficient program like this quickly
- Setting up cronjobs on my laptop in order to have this run at the end of each week

Future improvements to this project:
- Containerize it! It will help make this project more portable, meaning it could be used on other operating systems and onto the cloud
- Look at how to deal with environment variables regarding usernames/ passwords. Due to this only running locally I've not had to consider this, but in the future it will be worth looking into
- Improve the waiting schema in Selenium. Due to the small timebox I have set myself for this project, I used 'sleep' statements rather than waiting within Selenium itself. Although using 'sleep' works, it is quite hack-ish and can be inefficient so more research can be put into implicit/ explicit/ fluent waiting

If any other placement students come across this repo and have the same issue with remembering to create Mahara logs, send me an email at seanbutcher17@gmail.com and I can show you how to get this setup!
