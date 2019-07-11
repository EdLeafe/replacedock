FROM python:3-alpine as build-env
MAINTAINER Ed Leafe <ed@leafe.com>

RUN apk add --no-cache git gcc musl-dev linux-headers pcre-dev

RUN python -m venv /app
RUN /app/bin/pip install -U pip

# Do this all in one big piece otherwise things get confused.
# Thanks to ingy for figuring out a faster way to do this.
# We must get rid of any symlinks which can lead to errors, see:
# https://github.com/python/cpython/pull/4267
RUN git clone --depth=1 https://github.com/EdLeafe/replacement.git && \
#ADD /ORIGreplacement /replacement
RUN cd /replacement && \
    # If any patches need to be merged in, list them in this section
    # below and uncomment it.
    # git fetch --depth=2 --append origin \
    #     refs/changes/57/600157/8 && \
    # git cherry-pick $(cut -f1 .git/FETCH_HEAD) && \
    find . -type l -exec rm {} \; && \
    pwd && \
    /app/bin/pip --no-cache-dir install /replacement/
    /app/bin/pip --no-cache-dir install .
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
