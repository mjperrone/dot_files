#!/usr/bin/env python
import getpass
import smtplib
import sys
import argparse


GMAIL_SMTP_SERVER = "smtp.gmail.com"
GMAIL_SMTP_PORT = 587

DEFAULT_EMAIL = "mperrone@kyru.us"


def initialize_smtp_server(from_email):
    '''
    This function initializes and greets the smtp server.
    It logs in using the provided credentials and returns
    the smtp server object as a result.
    '''
    smtpserver = smtplib.SMTP(GMAIL_SMTP_SERVER, GMAIL_SMTP_PORT)
    smtpserver.ehlo()
    smtpserver.starttls()
    smtpserver.ehlo()
    smtpserver.login(from_email, GMAIL_PASSWORD)
    return smtpserver


def send_mail(from_email, to_email, subject, body):
    # The header consists of the To and From and Subject lines
    # separated using a newline character
    header = "To:%s\nFrom:%s\nSubject:%s \n" % (to_email, from_email, subject)
    # Hard-coded templates are not best practice.
    content = header + "\n" + body
    smtpserver = initialize_smtp_server(from_email)
    smtpserver.sendmail(from_email, to_email, content)
    smtpserver.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--subject', '-s', type=str, help='the subject of the email', default='msg from terminal')
    parser.add_argument('--to_email', '-t', type=str, help='the email address to send to, default is %s' % DEFAULT_EMAIL, default=DEFAULT_EMAIL)
    parser.add_argument('--from_email', '-f', type=str, help='the email address from which this email will be sent, must be gmail, default is %s' % DEFAULT_EMAIL, default=DEFAULT_EMAIL)
    parser.add_argument('--body', '-b', type=str, help='the body of the email that you are sending')
    args = parser.parse_args()
    GMAIL_PASSWORD = getpass.getpass()
    send_mail(args.from_email, args.to_email, args.subject, args.body if args.body else sys.stdin.read())
