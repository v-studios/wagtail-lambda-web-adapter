#!/bin/sh -x
# If the function is Janitor, initialize; else start Django server.

echo "## ${0} WAGTAIL_JANITOR=${WAGTAIL_JANITOR}"
if [ -z "${WAGTAIL_JANITOR}" ]
then
    echo "## ${0} Run Server... for SITE=$SITE"
    #./manage.py runserver 0.0.0.0:8000
    gunicorn $SITE.wsgi:application -w=1 -b=0.0.0.0:8000 # only 1 worker for Lambda
else
    ./s3check.py

    echo "## ${0} WIPE DB"
    # requires django-extensions and put in INSTALLED_APPS
    ./manage.py reset_db --noinput
    #./manage.py flush --noinput
    # CommandError: Database wagtaillwa couldn't be flushed. Possible reasons:
    # * The database isn't running or isn't configured correctly.
    # * At least one of the expected database tables doesn't exist.
    # * The SQL was invalid. Hint: Look at the output of 'django-admin
    # sqlflush'. That's the SQL this command wasn't able to run.

    echo "## ${0} Migrate..."
    ./manage.py migrate

    echo "## ${0} Superuser..."
    DJANGO_SUPERUSER_PASSWORD=KILLME ./manage.py createsuperuser --noinput --username chris --email chris@v-studios.com || echo "COULD NOT SET SUPERUSER, MAYBE ALREADY SET"

    # Load the NewSite sample data
    make load-data

    echo "## ${0} Collect Static..."
    # --clear flag throws error:
    # File "/VENV/lib/python3.12/site-packages/botocore/validate.py", line 381, in serialize_to_request
    # raise ParamValidationError(report=report.generate_report())
    # botocore.exceptions.ParamValidationError: Parameter validation failed:
    # Invalid length for parameter Key, value: 0, valid min length: 1
    SECRET_KEY=none ./manage.py collectstatic --noinput -v 1

fi
exit 0
