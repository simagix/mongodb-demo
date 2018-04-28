FROM mongo:3.6-jessie

MAINTAINER Ken Chen <simagix@gmail.com>

ADD ./*.sh /
ADD ./*.keyfile /etc/ssl/
ADD mongod.conf /etc/mongod.template
ADD mongod.conf /etc/
RUN chmod go+w /etc/mongod.* && chmod 400 /etc/ssl/*.keyfile

# Note that OpenShift doesn't honor USER
#USER mongodb

CMD ["/entrypoint.sh"]

