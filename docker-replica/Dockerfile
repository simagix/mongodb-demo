FROM mongo:3.6-jessie

MAINTAINER Ken Chen <simagix@gmail.com>

ADD ./entrypoint.sh /
ADD ./test.sh /
ADD ./*.keyfile /etc/ssl/
ADD mongod.conf /etc/

CMD ["/entrypoint.sh"]

