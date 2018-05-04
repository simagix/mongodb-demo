FROM mongo:3.6-jessie

MAINTAINER Ken Chen <simagix@gmail.com>

ADD ./*.sh /
ADD ./*.keyfile /etc/ssl/
ADD mongo*conf /etc/
RUN chmod go+w /etc/mongo*conf && chmod 644 /etc/ssl/*.keyfile
USER mongodb

CMD ["/entrypoint.sh"]

