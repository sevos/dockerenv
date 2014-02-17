FROM ubuntu

RUN apt-get update
RUN apt-get -y install python-software-properties software-properties-common wget vim
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3
RUN echo "host    all             all             0.0.0.0/0               trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN sed -i "/data_directory =/c\data_directory = '/data'" /etc/postgresql/9.3/main/postgresql.conf

CMD chown -R postgres /data; chmod 700 /data; [ "$(ls -A /data)" ] || su postgres -c '/usr/lib/postgresql/9.3/bin/initdb -D /data'; /bin/su postgres -c '/usr/lib/postgresql/9.3/bin/postgres -D /data -c config_file=/etc/postgresql/9.3/main/postgresql.conf'

EXPOSE 5432
