FROM mongo:3.6-jessie

MAINTAINER Ken Chen <simagix@gmail.com>

ADD ./*.sh /
ADD ./*.keyfile /etc/ssl/
ADD mongod.conf /etc/
RUN chmod -R 777 /data/db/ && chmod go+w /etc/mongod.* && chmod 644 /etc/ssl/*.keyfile

# Note that OpenShift doesn't honor USER
#USER mongodb

CMD ["/entrypoint.sh"]

