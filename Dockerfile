FROM python:3.13.3-alpine3.21
LABEL maintainer="cloudengineermike"

ENV PYTHONUNBUFFERED=1
ENV PATH="/py/bin:$PATH"

ARG DEV=false

# Install runtime dependencies (NO build deps needed for psycopg2-binary)
RUN apk add --no-cache \
    libpq postgresql-libs libffi

# Create virtual environment
RUN python3 -m venv /py

# Copy requirements
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Install Python dependencies
RUN /py/bin/pip install --upgrade pip \
    && /py/bin/pip install -r /tmp/requirements.txt \
    && if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi \
    && rm -f /tmp/requirements.txt /tmp/requirements.dev.txt

# Copy app code
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# Use non-root user
RUN adduser --disabled-password --no-create-home django-user
USER django-user
