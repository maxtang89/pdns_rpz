#!/bin/bash
python3 /usr/local/bin/fetch_url_filter.py
service cron start
exec pdns_recursor --config-dir=/etc/powerdns --daemon=no