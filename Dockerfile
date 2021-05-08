FROM freeradius/freeradius-server:3.2.0-alpine
COPY raddb/ /etc/raddb/
RUN apk update --no-cache && apk add --no-cache bash