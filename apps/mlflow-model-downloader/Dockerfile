FROM python:3.11.11-slim

WORKDIR /apps

RUN pip install --upgrade pip

ADD requirements.txt /apps
RUN pip install -r requirements.txt

ADD docker-entrypoint.sh /usr/bin
ADD *.py /apps
RUN chmod a+x /usr/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]

