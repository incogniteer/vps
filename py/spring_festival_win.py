import os
import sys
import time
import random
import logging
import smtplib
from string import Template
from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage

def get_contacts(filename):
    """
    Return 2 lists: names and emails
    read from a file specified by filename
    """

    names = []
    emails = []
    with open(filename, mode='r', encoding='utf-8') as contacts:
        for contact in contacts:
            names.append(contact.split()[0])
            emails.append(contact.split()[1])
    return names, emails

def read_template(filename):
    """
    Return a Template object comprising the contents of the file specified by filename
    """

    with open(filename, mode='rt', encoding='utf-8') as template:
        template_content = template.read()
    return Template(template_content)

def countdown(t):
    while t:
        min, sec = divmod(t, 60)
        timeformat = '{:02d}:{:02d}'.format(min, sec)
        print(timeformat, end='\r')
        time.sleep(1)
        t -= 1

def main(text_msg, html_msg):
    # sign in with SSL
    server = smtplib.SMTP_SSL(host = 'smtp.sinozoc.com', port = 465)
    server.login('sales03@sinozoc.com', 'zc@180730')

    names, emails = get_contacts(r"d:\py\messages\spring_festival_notice\contacts.txt")

    for name, email in zip(names, emails):
        # create email
        message = MIMEMultipart('alternative')

        # email parameters
        message['From'] = 'Calibur@Sinozoc <sales03@sinozoc.com>'
        message['To'] = email
        message['Cc'] = None
        message['Bcc'] = None
        message['Subject'] = 'Holiday Notice - Sinozoc/Calibur'

        # MIME text part message
        with open(text_msg, 'r') as fp:
            text_part = Template(fp.read()).substitute(recipient = name.title())

        # MIME html part message
        with open(html_msg, 'r') as fp:
            html_part = Template(fp.read()).substitute(recipient = name.title())

        """
        email.mime.text.MIMEText(_text, _subtype='plain', _charset=None, *, policy=compat32)
        _text string for message payload
        record the MIME types of both parts - text/html and text/html
        turn into MIMEtext objects
        """
        part1 = MIMEText(text_part, 'plain')
        part2 = MIMEText(html_part, 'html')

        """
        attach parts into message container according to RFC 2046, the last part of a multipart message, in this case the HTML message, is best and preferred.
        """
        message.attach(part1)
        message.attach(part2)

        # convert email message to string
        composed = message.as_string()
        server.sendmail('sales03@sinozoc.com', email, composed)
        try:
            server.sendmail('sales03@sinozoc.com', email, composed)
            logging.info('Success: ' + name.title() + ':' + email)
        except Exception as e:
            logging.error('Failed: ' + name.title() + ':' + email + '\r' + repr(e))

        #暂停跳过跳过最后一项
        if name != names[-1]:
            delay = random.randint(30, 90)
            countdown(delay)
        else:
            pass

    server.quit()

if __name__ == '__main__':
    logging.basicConfig(format="%(asctime)s:\t%(levelname)s:\t%(message)s",
                        datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    text_msg = r'D:\py\messages\spring_festival_notice\text_msg'
    html_msg = r'D:\py\messages\spring_festival_notice\html_msg'

    main(text_msg, html_msg)
