#!/usr/bin/env python
# You might have to go to google settings to allow less secure apps to connect
# https://www.google.com/settings/security/lesssecureapps
# You should probably disable that again after.
import getpass
import smtplib
import sys
import argparse
import csv

import jinja2

GMAIL_SMTP_HOST = "smtp.gmail.com"
GMAIL_SMTP_PORT = 587

WPI_SMTP_HOST = "submission.wpi.edu"
WPI_SMTP_PORT = 587

DEFAULT_EMAIL = "mike.j.perrone@gmail.com"


def initialize_smtp_server(from_email):
    '''
    This function initializes and greets the smtp server.
    It logs in using the provided credentials and returns
    the smtp server object as a result.
    '''
    domain = args.from_email[args.from_email.find('@'):]
    if domain == "@gmail.com":
        host = GMAIL_SMTP_HOST
        port = GMAIL_SMTP_PORT
    elif domain == "@wpi.edu":
        host = WPI_SMTP_HOST
        port = WPI_SMTP_PORT
    else:
        raise ValueError("Unknown sending domain: {}, must be @gmail.com or @wpi.edu".format(domain))

    smtpserver = smtplib.SMTP(host, port)
    smtpserver.ehlo()
    smtpserver.starttls()
    smtpserver.ehlo()
    return smtpserver


def send_mail(server, from_email, to_email, subject, body):
    # The header consists of the To, From, and Subject lines
    # separated by newline
    header = "To:%s\nFrom:%s\nSubject:%s \n" % (to_email, from_email, subject)
    content = header + "\n" + body
    server.sendmail(from_email, to_email, content)


def templated_mass_send(server, from_email, to_emails, subject_template, body_template, args):
    subjects, bodies = render_templates(subject_template, body_template, args)
    for to_email, subject, body in zip(to_emails, subjects, bodies):
        send_mail(server, from_email, to_email, subject, body)


def render_templates(subject_template, body_template, args):
    # args as a list of dicts, each dict corresponding to a different render env
    # returns a list of pairs (rendered subject, rendered body)
    subject_template = jinja2.Template(subject_template)
    body_template = jinja2.Template(body_template)
    subj_body_pairs = [(subject_template.render(arg), body_template.render(arg)) for arg in args]
    subjects, bodies = [x[0] for x in subj_body_pairs], [x[1] for x in subj_body_pairs]
    return subjects, bodies


def load_templates(subject_fname, body_fname):
    # returns the subject and body files dumped as a string
    sf, bf = open(subject_fname, 'r'), open(body_fname, 'r')
    return sf.read(), bf.read()


def load_args_csv(fname):
    # returns two lists (to_emails:str, args:dict[str->str])
    # only required column in the argument csv is "email"
    f = open(fname, 'r')
    reader = csv.DictReader(f, delimiter=",")
    args = list(reader)
    emails = [row["email"] for row in args]

    return emails, args


def load_templated_send(args_fname, subject_fname, body_fname):
    # returns the subject template, body template, and lists of to_emails, and args
    subject_template, body_template = load_templates(subject_fname, body_fname)
    to_emails, args = load_args_csv(args_fname)
    return subject_template, body_template, to_emails, args


def test_print_send(from_email, to_email, content):
    print '-' * 80
    print "From: " + from_email
    print "To: " + to_email
    print "content: " + content


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--from_email', '-f', type=str, help='The email address from which this email will be sent, must be gmail, default is %s' % DEFAULT_EMAIL, default=DEFAULT_EMAIL)
    parser.add_argument('--to_email', '-t', type=str, help='The email address to send to, default is %s, if template_args is set this is ignored' % DEFAULT_EMAIL, default=DEFAULT_EMAIL)
    parser.add_argument('--subject', '-s', type=str, help='The subject of the email, or the path to a jinja2 template file for the subject', default='msg from terminal')
    parser.add_argument('--body', '-b', type=str, help='The body of the email that you are sending, or a path to a jinja2 template file for the body (optional, defaults to stdin if unset)')
    parser.add_argument('--template_args', '-a', type=str, help='The path to a csv with header line and minimally the column "email". with this, --subject and --body are required and must be paths')
    parser.add_argument('--test', dest='test', action='store_true', help='Don\'t actually send the email, but print out what would have been sent')
    parser.set_defaults(test=False)
    args = parser.parse_args()

    server = initialize_smtp_server(args.from_email)
    if args.test:
        server.sendmail = test_print_send
    else:
        password = getpass.getpass("Enter password for sender account {}:".format(args.from_email))
        server.login(args.from_email, password)

    if args.template_args:
        subject_template, body_template, to_emails, argz = load_templated_send(args.template_args, args.subject, args.body)
        templated_mass_send(server, args.from_email, to_emails, subject_template, body_template, argz)
    else:
        send_mail(server, args.from_email, args.to_email, args.subject, args.body if args.body else sys.stdin.read())

    server.close()
