FROM python:3-alpine as build-env
MAINTAINER Ed Leafe <ed@leafe.com>

RUN apk add --no-cache git gcc musl-dev linux-headers pcre-dev

RUN python -m venv /app
RUN /app/bin/pip install -U pip

RUN git clone --depth=1 https://github.com/EdLeafe/replacement.git
RUN /app/bin/pip --no-cache-dir install /replacement/
RUN /app/bin/pip --no-cache-dir install uwsgi
RUN /app/bin/pip --no-cache-dir install python-memcached

FROM python:3-alpine
COPY --from=build-env /app /app

# pcre and psql shared libs required
RUN apk add --no-cache pcre

# add in the uwsgi configuration
ADD /shared/placement-uwsgi.ini /

# copy in the startup script, which syncs the database and
# starts uwsgi.
ADD /shared/startup.sh /

# Add the script to wait for the DB to be started
ADD /shared/wait_for_db.sh /

ENTRYPOINT ["/startup.sh"]
EXPOSE 80
