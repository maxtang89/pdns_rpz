docker build -t pdns_recursor . && \
docker run -d -p 53:53/tcp -p 53:53/udp \
--log-opt max-size=500m --log-opt max-file=1200 \
--restart=always --name pdns_recursor pdns_recursor
