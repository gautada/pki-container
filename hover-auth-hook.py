#!/usr/bin/env python3

"""hover.py: Provides dynamic DNS functionality for Hover.com using their unofficial API.
    This script is based off one by Dan Krause: https://gist.github.com/dankrause/5585907"""

__author__  = "Adam T. Gautier"
__credits__ = ["Andrew Barilla", "Dan Krause"]
__license__ = "GPL"
__version__ = "1.0"
__maintainer__ = "Adam Gautier"
__email__ = "adam@gautier.org"
__status__ = "Development"

import os
import argparse
import requests
import json
import time
import logging
import sys

SLEEPTIME = 60

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("dydns")

class HoverException(Exception):
    pass

class HoverAPI(object):
    def __init__(self, username, password):
        params = {"username": username, "password": password}
        r = requests.post("https://www.hover.com/api/login", data=params)
        if not r.ok or "hoverauth" not in r.cookies:
            print(r.text)
            raise HoverException(r)
        self.cookies = {"hoverauth": r.cookies["hoverauth"]}
    
    def call(self, method, resource, data=None):
        url = "https://www.hover.com/api/{0}".format(resource)
        logger.info("%s" % url)
        r = requests.request(method, url, data=data, cookies=self.cookies)
        if not r.ok:
            print(r)
            raise HoverException(r)
        if r.content:
            body = r.json()
            if "succeeded" not in body or body["succeeded"] is not True:
                raise HoverException(body)
            return body

def validate(username=None, password=None, host=None, domain=None, validation=None):
    # connect to the API using your account
    client = HoverAPI(username, password)
    result = client.call("get", "domains/%s/dns" % domain)
    challenge = "_acme-challenge"
    if "*" != host:
        challenge = "%s.%s" % (challenge, host)
    for entry in result["domains"][0]["entries"]:
        if challenge == entry['name']:
            id = entry['id']
            client.call("put", "dns/" + id, {"content": validation})
            # print( entry )

def defaultEnviron(key='PATH'):
    if key in os.environ.keys():
        return os.environ[key]
    else:
        return None

def parseFQDN(fqdn):
    tokens = fqdn.split(".")
    domain = None
    host = "*"
    if 2 == len(tokens) or 3 == len(tokens):
        domain = "%s.%s" % (tokens[-2], tokens[-1])
        if 3 == len(tokens):
            host = tokens[0]
    assert domain is not None, "Doman cannot be null"
    return(host, domain)
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Update DNS TXT field validation for letsencrypt.org.')
    parser.add_argument('--username', default=defaultEnviron('HOVER_USERNAME'), help='The user name of the hover account')
    parser.add_argument('--password', default=defaultEnviron('HOVER_PASSWORD'), help='The password of the hover account')
    parser.add_argument('--validation', default=defaultEnviron('CERTBOT_VALIDATION'),
                        help='The TXT field validation for _acme-challenge.domain.tld')
    parser.add_argument('--fqdn', default=defaultEnviron('CERTBOT_DOMAIN'), help='The fully qualified domain name for DNS validation')
    args = parser.parse_args()
    print(args.username)
    print(args.password)
    host, domain = parseFQDN(args.fqdn)
    print(args.fqdn, host, domain)
    print(args.validation)
    print() ; print()
    validate(username=args.username, password=args.password, host=host, domain=domain, validation=args.validation)

