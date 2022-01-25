FROM python:3.10.2-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# RUN apk add --ino-cache git py3-pip npm py3-babel tini swig gcc alpine-sdk python3-dev
RUN apt-get update && apt-get install -y tini npm swig gcc curl

# Install Python poetry (HEAD)
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/share/pypoetry/venv/bin/poetry /usr/local/bin/poetry

# Copy config files
RUN mkdir -p /app
COPY ./package.json /app/package.json
COPY ./package-lock.json /app/package-lock.json
COPY ./pyproject.toml /app/pyproject.toml
COPY ./poetry.lock /app/poetry.lock
COPY ./bower.json /app/bower.json
COPY ./.bowerrc /app/bowerrc

# Alternatively you can install the latest stable (1.1) version:
# RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
# For version 1.2 (not released yet) onwards:
# RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python3 && \

# To use git version instead of the current use:
# RUN cd / && git clone -b main --depth=1 https://github.com/gstos/qpanel.git
COPY ./src /app

WORKDIR /app

# This will create a virtual environment and install all poetry.lock dependencies
RUN poetry env use $(python3 --version | sed "s/Python //") && poetry install -n
RUN poetry run pybabel compile -d qpanel/translations
RUN npm install

# COPY ../config.ini /app/config.ini

# Exposes the default HTTP port on config
EXPOSE 8080

# tini: spawn a single child wait for it to exit all
# while reaping zombies and performing signal forwarding.
CMD ["tini", "--", "poetry", "run", "app.py"]
