FROM powerdns/pdns-recursor-51

USER root

RUN apt-get update && apt-get install -y cron python3-pip && pip3 install requests

COPY pdns.yaml /etc/powerdns/recursor.conf
COPY dns-config.lua /etc/powerdns/dns-config.lua
COPY dns-queries.lua /etc/powerdns/dns-queries.lua
COPY policy_source.json /etc/powerdns/policy_source.json
COPY default.rpz /etc/powerdns/default.rpz

COPY fetch_url_filter.py /usr/local/bin/fetch_url_filter.py

RUN chmod +x /usr/local/bin/fetch_url_filter.py

RUN touch /var/log/cron.log
RUN echo "*/30 * * * * python3 /usr/local/bin/fetch_url_filter.py >> /var/log/cron.log 2>&1" > /etc/cron.d/fetch_url_filter
RUN chmod 0644 /etc/cron.d/fetch_url_filter
RUN crontab /etc/cron.d/fetch_url_filter

EXPOSE 53/tcp 53/udp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
