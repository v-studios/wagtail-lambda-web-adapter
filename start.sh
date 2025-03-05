#!/bin/sh -x
# If the function is Janitor, initialize; else start Django server.

echo "## ${0} WAGTAIL_JANITOR=${WAGTAIL_JANITOR}"
if [ -z ${WAGTAIL_JANITOR+x} ]
then
    echo "## ${0} Run Server... for SITE=$SITE"
    #./manage.py runserver 0.0.0.0:8000
    gunicorn $SITE.wsgi:application -w=1 -b=0.0.0.0:8000 # only 1 worker for Lambda
    exit 0
else
    # Can I find event data in the environment?
    echo "## ${0} Event Data..."    
    echo "## ${0} AWS_LAMBDA_EVENT_BODY=${AWS_LAMBDA_EVENT_BODY}"
    echo "## ${0} AWS_LAMBDA_EVENT_BODY_FILE=${AWS_LAMBDA_EVENT_BODY_FILE}" 
    echo "## ${0} 1=$1"
    echo "## ${0} 2=$2"

    # run the setup(s) specified in the WAGTAIL_JANITOR env var;
    # Use `case` since it's Posix and works in plain `sh`;
    # but `case` only runs the first match, so use multiple.
    case $WAGTAIL_JANITOR in
        *s3check*)
            echo "## ${0} S3 Check..."
            ./s3check.py
            ;;
    esac
    case $WAGTAIL_JANITOR in
        *reset_db*)
            echo "## ${0} Reset DB..."
            # requires django-extensions and put in INSTALLED_APPS
            ./manage.py reset_db --noinput
            ;;
    esac
    case $WAGTAIL_JANITOR in
        *load_data*)
            echo "## ${0} Load Data..."
            # Load the NewSite sample data
            # From Makefile target `load-data`
            ./manage.py createcachetable
            ./manage.py migrate
            ./manage.py load_initial_data 
            ;;
    esac

    # It's always safe to createsuperuser, migrate, collectstatic
    echo "## ${0} Superuser..."
    DJANGO_SUPERUSER_PASSWORD=KILLME ./manage.py \
        createsuperuser --noinput --username chris --email chris@v-studios.com \
        || echo "COULD NOT SET SUPERUSER, MAYBE ALREADY SET"

    echo "## ${0} Migrate..."
    ./manage.py migrate

    # --clear flag throws error:
    # File "/VENV/lib/python3.12/site-packages/botocore/validate.py",
    # line 381, in serialize_to_request raise
    # ParamValidationError(report=report.generate_report())
    # botocore.exceptions.ParamValidationError: Parameter validation
    # failed: Invalid length for parameter Key, value: 0, valid min
    # length: 1
    echo "## ${0} Collect Static..."
    ./manage.py collectstatic --noinput -v 1
fi
exit 0
