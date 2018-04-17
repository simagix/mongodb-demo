FROM mongo:3.6-jessie

MAINTAINER Ken Chen <simagix@gmail.com>
ADD ./entrypoint.sh /
ADD ./*.keyfile /etc/ssl/

CMD ["/entrypoint.sh"]

