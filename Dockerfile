FROM ubuntu:14.04
RUN apt-get update &&\
    apt-get install -y python python-virtualenv python-dev python-pip python-setupdocs sqlite3 nginx libsasl2-dev libldap2-dev libssl-dev &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm /etc/nginx/sites-enabled/default

RUN useradd -d /home/ubuntu ubuntu &&\
    mkdir /home/ubuntu

ADD ./docker/vaas.conf /etc/nginx/sites-enabled/vaas.conf
ADD ./docker/start.sh /var/tmp/start.sh
ADD ./docker/backend_statuses.sh /var/tmp/backend_statuses.sh
ADD ./vaas-app/ /home/ubuntu/vaas-app/

RUN chown -R ubuntu:ubuntu /home/ubuntu &&\
    chmod 755 /var/tmp/*.sh

USER ubuntu

RUN cd /home/ubuntu &&\
    virtualenv prod-env &&\
    . prod-env/bin/activate &&\
    cd /home/ubuntu/vaas-app &&\
    touch src/vaas/settings/__init__.py &&\
    pip install uwsgi &&\
    python setup.py install &&\
    cd &&\
    rm -r vaas-app

USER root

CMD ["/var/tmp/start.sh"]
