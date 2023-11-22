#!/bin/sh
# Start Django, after first doing a migration and setting root user password.

echo "## ${0} Migrate..."
./manage.py migrate
echo "## ${0} Superuser..."
DJANGO_SUPERUSER_PASSWORD=KILLME ./manage.py createsuperuser --noinput --username chris --email chris@v-studios.com || echo "COULD NOT SET SUPERUSER, MAYBE ALREADY SET"
echo "## ${0} Collect Static..."
./manage.py collectstatus --noinput
echo "## ${0} Run Server..."
./manage.py runserver 0.0.0.0:8000
