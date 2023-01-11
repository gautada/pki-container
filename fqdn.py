#!/usr/bin/env python3

import sys

def parse(fqdn):
   fqdn = fqdn.lower()
   tokens = fqdn.split(".")
   assert 3==len(tokens), "[ERROR] FQDN must be host.domain.tld format" 
   return {'host': tokens[0], 'domain': tokens[1], 'tld': tokens[2], 'fqdn': fqdn}




