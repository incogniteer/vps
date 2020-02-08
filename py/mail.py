#!/usr/bin/env py

import smtplib
from email.mime.text import MIMEText

gmail_user1 = 'incogniteer@gmail.com'
gmail_appPassword1 = 'klrkatqbwjpwqjqj'

gmail_user2 = 'calibur.wei@gmail.com'
gmail_appPassword2 = 'ydchrbbbbssbhzvq'

gmail_user3 = 'caliburwey@gmail.com'
gmail_appPassword3 = 'apmhabwzzupibfje'

gmail_user4 = 'clanclariusxxx@gmail.com'
gmail_appPassword4 = 'hcvtkpaajlwdhmws'

gmail_user5 = 'yarplyn@gmail.com'
gmail_appPassword5 = 'xgigfvpvwjbwfqpp'

gmail_user6 = 'wcjcharlie@gmail.com'
gmail_appPassword6 = 'clzkbrjulutgmjhy'

gmail_user7 = 'pagocompradora@gmail.com'
gmail_appPassword7 = 'jbqmllcuzhstelwz'

gmail_user8 = 'voscomprador@gmail.com'
gmail_appPassword8 = 'edbgkrnwmszfyduo'

sent_from = [gmail_user4]
to = ['calibur.wei@gmail.com']

text = '''
Hello there,

This is an email to keep you updated.

Best Regards
'''

msg = MIMEText(text)
msg['Subject'] = 'Python email!'

server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login(gmail_user4, gmail_appPassword4)
server.sendmail(sent_from, to, msg.as_string())
server.quit()
