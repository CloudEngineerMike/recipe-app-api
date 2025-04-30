FROM python:3.13.3-alpine3.21
LABEL maintainer="cloudengineermike"

ENV PYTHONUNBUFFERED=1
ENV PATH="/py/bin:$PATH"

ARG DEV=false

RUN apk add --no-cache --virtual .build-deps \
    gcc musl-dev libffi-dev openssl-dev python3-dev \
    && python -m venv /py

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

RUN /py/bin/pip install --upgrade pip \
    && /py/bin/pip install -r /tmp/requirements.txt \
    && if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi \
    && rm -f /tmp/requirements.txt /tmp/requirements.dev.txt \
    && apk del .build-deps

COPY ./app /app
WORKDIR /app
EXPOSE 8000

RUN adduser --disabled-password --no-create-home django-user
USER django-user
