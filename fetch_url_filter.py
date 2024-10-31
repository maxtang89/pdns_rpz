import requests as req
import os
import json

URL_FILTER_POLICY = {}
REDIRECT_TO = "RPZ-BLOCAK.local"

try:
        with open("/etc/powerdns/policy_source.json", "r") as f:
                URL_FILTER_POLICY = json.load(f)
except Exception as e:
        print(f"Read /etc/powerdns/policy_source.json failed: {e}")
        exit(1)

for policy in URL_FILTER_POLICY:
        rpz_output = """$TTL 60
@ IN SOA localhost. root.localhost. (
  2021100401 ; Serial
  1h ; Refresh
  15m ; Retry
  1w ; Expire
  1h ; Negative Cache TTL
)

@ IN NS localhost. 

; Filtered domains
"""
        for url in policy['urls']:
                try:
                        response = req.get(url)
                        if response.status_code != 200:
                                print(f"Fetch {url} failed: {response.status_code}")
                                continue
                        for line in response.text.split("\n"):
                                if line.strip() == "":
                                        continue
                                if line.startswith("#"):
                                        continue
                                rpz_output += f"{line.strip()} CNAME {REDIRECT_TO}\n"
                except Exception as e:
                        print(f"Fetch {url} failed: {e}")
                        continue
        try:
                with open(f"/etc/powerdns/{policy['name']}.rpz", "w") as f:
                        f.write(rpz_output)
        except Exception as e:
                print(f"Write to /etc/powerdns/{policy['name']}.rpz failed: {e}")
                exit(1)

try:
        os.system("rec_control reload-lua-config /etc/powerdns/dns-config.lua")
except Exception as e:
        print(f"Reload lua script failed: {e}")
        exit(1)