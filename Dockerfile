# FROM registry.ng.bluemix.net/ibmnode:latest
FROM node:argon
# ##################################
# ####        mosquitto          ###
# ##################################         

# FROM debian:jessie

# MAINTAINER sourceperl <loic.celine@free.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget

RUN wget -q -O - http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key | apt-key add -
RUN wget -q -O /etc/apt/sources.list.d/mosquitto-jessie.list http://repo.mosquitto.org/debian/mosquitto-jessie.list
RUN apt-get update
RUN apt-get install -y mosquitto
COPY mosquitto/conf.d/ /etc/mosquitto/conf.d/

# EXPOSE 1883 9001

# CMD /usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf

# ##################################
# ####         vsftpd            ###
# ##################################

# FROM debian:jessie

RUN groupadd -g 48 ftp && \
    useradd --no-create-home --home-dir /srv -s /bin/false --uid 48 --gid 48 -c 'ftp daemon' ftp

RUN apt-get update \
    && apt-get install -y --no-install-recommends vsftpd db5.3-util whois \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/vsftpd/empty /etc/vsftpd/user_conf /var/ftp /srv && \
    touch /var/log/vsftpd.log && \
    rm -rf /srv/ftp

COPY vsftpd/vsftpd*.conf /etc/
COPY vsftpd/vsftpd_virtual /etc/pam.d/
COPY vsftpd/*.sh /

VOLUME ["/etc/vsftpd", "/srv"]

# EXPOSE 21 4559 4560 4561 4562 4563 4564

# ENTRYPOINT ["/entry.sh"]
# CMD ["vsftpd"]



# ##################################
# ####          app              ###
# ##################################
# FROM node:argon
# RUN mkdir -p /usr/src/app
# WORKDIR /usr/src/app
# COPY package.json /usr/src/app/
# RUN npm install
# EXPOSE 1880
# CMD ["npm","start"]

# ##################################
# ####       supervisord         ###
# ##################################

RUN apt-get update && apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# EXPOSE 22 80
# CMD ["/usr/bin/supervisord"]

EXPOSE 22 1883 9001 21 4559 4560 4561 4562 4563 4564 8080


# ##################################
# ####       storng-pm           ###
# ##################################

# FROM registry.ng.bluemix.net/ibmnode:latest

RUN useradd -ms /bin/bash strong-pm \
    && chown -R strong-pm:strong-pm /usr/local \
    && su strong-pm -c "npm install -g strong-pm && npm cache clear"

# Set up some semblance of an environment
WORKDIR /home/strong-pm
ENV HOME=/home/strong-pm PORT=3000

# Run as non-privileged user inside container
USER strong-pm

# Expose strong-pm and application ports
EXPOSE 8701
EXPOSE 3001-3010

# ENTRYPOINT ["/usr/local/bin/sl-pm", "--base", ".", "--listen", "8701"]

# ENTRYPOINT ["/entry.sh"]


CMD ["/usr/bin/supervisord"]
