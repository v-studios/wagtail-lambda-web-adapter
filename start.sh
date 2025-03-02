#!/bin/sh -x
# If the function is Janitor, initialize; else start Django server.

echo "## ${0} WAGTAIL_JANITOR=${WAGTAIL_JANITOR}"
if [ -z "${WAGTAIL_JANITOR}" ]
then
    echo "## ${0} Run Server..."
    #./manage.py runserver 0.0.0.0:8000
    gunicorn scale0.wsgi:application -w=1 -b=0.0.0.0:8000 # only 1 worker for Lambda
else
    ./s3check.py

    echo "## ${0} Migrate..."
    ./manage.py migrate

    echo "## ${0} Superuser..."
    DJANGO_SUPERUSER_PASSWORD=KILLME ./manage.py createsuperuser --noinput --username chris --email chris@v-studios.com || echo "COULD NOT SET SUPERUSER, MAYBE ALREADY SET"

    echo "## ${0} Collect Static..."
    # --clear flag throws error:
    # File "/VENV/lib/python3.12/site-packages/botocore/validate.py", line 381, in serialize_to_request
    # raise ParamValidationError(report=report.generate_report())
    # botocore.exceptions.ParamValidationError: Parameter validation failed:
    # Invalid length for parameter Key, value: 0, valid min length: 1

    AWS_DEFAULT_ACL='public-read' ./manage.py collectstatic --noinput -v 1
    err=$?
    if [ $err -ne 0 ]
    then
        echo "## ${0} Collect Static Error: ${err}"
        exit $err
    fi
fi
