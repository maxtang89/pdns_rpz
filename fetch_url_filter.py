import requests as req
import os
import json

URL_FILTER_POLICY = {}
rpz_output = ""

try:
        with open("/etc/powerdns/policy_source.json", "r") as f:
                URL_FILTER_POLICY = json.load(f)
                print(URL_FILTER_POLICY)
except Exception as e:
        print(f"Read /etc/powerdns/policy_source.json failed: {e}")
        exit(1)

for policy in URL_FILTER_POLICY:
        print(policy)
        for url in policy['urls']:
                print(url)
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
                                rpz_output += f"{line.strip()}\n"
                except Exception as e:
                        print(f"Fetch {url} failed: {e}")
                        continue
        try:
                with open(f"/etc/powerdns/{policy['name']}.txt", "w") as f:
                        f.write(rpz_output)
        except Exception as e:
                print(f"Write to /etc/powerdns/rpz.txt failed: {e}")
                exit(1)

try:
        # os.system("rec_control reload-lua-config /etc/powerdns/dns-config.lua")
        os.system("rec_control reload-lua-script /etc/powerdns/dns-lua.lua")
except Exception as e:
        print(f"Reload lua script failed: {e}")
        exit(1)