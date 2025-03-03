ARG PYTHON=python:3.13.2-slim-bookworm
ARG PORT=8000
ARG AWS_LWA_PORT=8000
ARG OP_ENV=dev

FROM ${PYTHON} AS install

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.1 /lambda-adapter /opt/extensions/lambda-adapter

EXPOSE ${PORT}
ENV APPDIR=/app \
    SITE=NewsSite \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    VENV=/opt/VENV
# 'production' needs SSL/HTTPS so use 'dev' for HTTP now
ENV DJANGO_SETTINGS_MODULE=$SITE.settings.dev \
    PATH="$VENV/bin:$PATH"

RUN apt-get update --yes --quiet \
    && apt-get install --yes --quiet --no-install-recommends build-essential \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN useradd wagtail --create-home \
    && mkdir $APPDIR $VENV \
    && chown -R wagtail $APPDIR $VENV

WORKDIR $APPDIR
USER wagtail
RUN python -m venv ${VENV}
RUN pip install wagtail
RUN wagtail start --template=https://github.com/wagtail/news-template/archive/refs/heads/main.zip $SITE .
# We've got no custom sourcecode yet so no need to COPY that either.
# Use the requirements from the NewsSite.
RUN pip install --no-cache -r requirements.txt

RUN pip install django-extensions   # for reset_db

ENV DATABASE_URL=${DATABASE_URL}
ENV AWS_STORAGE_BUCKET_NAME=${AWS_STORAGE_BUCKET_NAME}

# TODO these are owned by root
COPY start.sh s3check.py ./
COPY dev.py ./$SITE/settings/
# Not Permitted: RUN chown wagtail:wagtail start.sh s3check.py ./$SITE/settings/dev.py

CMD SITE=$SITE ./start.sh
