FROM ubuntu:16.04

RUN echo "deb http://repo.percona.com/apt xenial main" > /etc/apt/sources.list.d/repo_percona_com_apt.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9334A25F8507EFA5 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends percona-xtrabackup-24 wget libconfig-simple-perl libwww-perl lbzip2 pigz pxz \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN wget -qO /mysql-backup.pl --no-check-certificate https://raw.githubusercontent.com/r0bj/mysql-backup/master/mysql-backup.pl && chmod +x /mysql-backup.pl

RUN wget -qO /usr/bin/confd --no-check-certificate https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 && chmod +x /usr/bin/confd
COPY mysql-backup.toml /etc/confd/conf.d/mysql-backup.toml
COPY mysql-backup.conf.tmpl /etc/confd/templates/mysql-backup.conf.tmpl
RUN mkdir /etc/backup

ENV ZABBIX_AGENT_VERSION="3.2.0"
ENV ZABBIX_AGENT="zabbix_agents_${ZABBIX_AGENT_VERSION}.linux2_6_23.amd64"
RUN wget -qO /tmp/${ZABBIX_AGENT}.tar.gz http://www.zabbix.com/downloads/${ZABBIX_AGENT_VERSION}/${ZABBIX_AGENT}.tar.gz \
	&& mkdir /tmp/$ZABBIX_AGENT \
	&& tar xpzf /tmp/${ZABBIX_AGENT}.tar.gz -C /tmp/$ZABBIX_AGENT \
	&& cp /tmp/${ZABBIX_AGENT}/bin/zabbix_sender /usr/bin/zabbix_sender \
	&& rm -rf /tmp/${ZABBIX_AGENT}.tar.gz /tmp/${ZABBIX_AGENT}

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
