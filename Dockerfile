# Builds a container with the version specified via --build-arg GIT_BRANCH=<branch> (defaults to 'main')
FROM python:3.10.2-slim
ARG GIT_BRANCH=main

# TODO: Check if this is needed here
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# RUN apk add --ino-cache git py3-pip npm py3-babel tini swig gcc alpine-sdk python3-dev
RUN apt-get update && apt-get install -y tini npm swig gcc curl

# Install Python poetry (HEAD)
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/share/pypoetry/venv/bin/poetry /usr/local/bin/poetry

# Alternatively you can install the latest stable (1.1) version:
# RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
# For version 1.2 (not released yet) onwards:
# RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python3 && \

# Download the latest development version of the application
RUN git clone -b $GIT_BRANCH --depth=1 https://github.com/gstos/qpanel.git /app


WORKDIR /app

# Install npm packages
RUN npm install

# This will create a virtual environment and install all poetry.lock dependencies
RUN poetry env use $(python3 --version | sed "s/Python //") && poetry install -n
RUN poetry run pybabel compile -d qpanel/translations

# tini: spawn a single child wait for it to exit all
# while reaping zombies and performing signal forwarding.
CMD ["tini", "--", "poetry", "run", "app.py"]
