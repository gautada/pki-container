#!/usr/bin/python3
import sys
assert 3 == len(sys.argv), "FQDN and query must be provided"
fqdn = sys.argv[1]
query = sys.argv[2]
tokens = fqdn.split(".")
domain = None
host = "*"
if 2 == len(tokens) or 3 == len(tokens):
 domain = "%s.%s" % (tokens[-2], tokens[-1])
 if 3 == len(tokens):
  host = tokens[0]
assert domain is not None, "Doman cannot be null"
if "domain" == query.lower(): 
 print(domain)
 sys.exit(0)
elif "host" == query.lower():
 print(host)
 sys.exit(0)
else:
 print("Unknown query(%s)" % query)
 sys.exit(1)
