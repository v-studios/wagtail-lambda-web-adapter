#!/bin/sh -x
# If the function is Janitor, initialize; else start Django server.

echo "## ${0} WAGTAIL_JANITOR=${WAGTAIL_JANITOR}"
if [ -z "${WAGTAIL_JANITOR}" ]
then
    echo "## ${0} Run Server..."
    ./manage.py runserver 0.0.0.0:8000
else
    ./s3check.py

    echo "## ${0} Migrate..."
    ./manage.py migrate

    echo "## ${0} Superuser..."
    DJANGO_SUPERUSER_PASSWORD=KILLME ./manage.py createsuperuser --noinput --username chris --email chris@v-studios.com || echo "COULD NOT SET SUPERUSER, MAYBE ALREADY SET"

    echo "## ${0} Collect Static..."
    # --clear flag throws error
    ./manage.py collectstatic --noinput -v 3
fi

