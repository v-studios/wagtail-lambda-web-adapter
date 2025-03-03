from .base import *

import dj_database_url

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = "django-insecure-!jr0je-3w+3i6as15ob(kpnax(9yn9b&mmlk3z_uc+y1vhq@8f"

# TODO SECURITY WARNING: define the correct hosts in production!
ALLOWED_HOSTS = ["*"]

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"


# Fix to allow App Runner origins to submit forms
CSRF_TRUSTED_ORIGINS=[
    'https://*.us-east-1.awsapprunner.com',
    'https://*.eu-west-3.awsapprunner.com',
    'https://*.lambda-url.eu-west-3.on.aws',  # lambda function URL

]

# TODO: we want media and static to live under different roots but this isn't
# doing it, static lives at top-level like /admin/, /css/, /js/.
# print(f"#### DEV.py {MEDIA_ROOT=} {STATIC_ROOT=}") # /app/media, /app/static

# [print(i) for i in dict(os.environ).items()]  # Got region? bucket for djsto?

# django-storages defaults to storing in S3 without public-read, and calculates
# presigned URLs for access at page render time. I thought we had to supply the
# region_name but it appears not. 
#
# Storages will use options (not env vars!) including:
# * bucket_name / AWS_STORAGE_BUCKET_NAME (required)
# * region_name / AWS_S3_REGION_NAME
#
# Our serverless.yml sets:
# AWS_STORAGE_BUCKET_NAME='wagtaillwa-dev-s3media-r0fhnejxii1y'
# and provides other Lambda environment vars we can use:
# AWS_DEFAULT_REGION='eu-west-3'
# AWS_REGION='eu-west-3'

bucket_name = os.environ.get("AWS_STORAGE_BUCKET_NAME")
if bucket_name:
    print(f"#### DEV.PY STORAGES configuring STORAGES for S3 {bucket_name=}")
    # This was needed before WT-6, then not for WT-6, but for NewsSite it is.
    if "storages" not in INSTALLED_APPS:
        INSTALLED_APPS.append("storages")
    STORAGES = {
        "default": {
            "BACKEND": "storages.backends.s3.S3Storage",
            "OPTIONS": {
                "bucket_name": bucket_name,
                #"region_name": os.environ["AWS_REGION"]
            },
        },
        "staticfiles": {
            "BACKEND": "storages.backends.s3.S3Storage",
            "OPTIONS": {
                "bucket_name": bucket_name,
                #"region_name": os.environ["AWS_REGION"]
            },
    },
}

INSTALLED_APPS.append("django_extensions")  # for reset_db

# Configure from DATABASE_URL:
# * "sqlite:////tmp/db.sqlite3"
# * "postgres://USER:PASSWORD@HOST:PORT/NAME"
# only /tmp is writable on Lambda
# dj_database_url .config() expects env var DATABASE_URL,
# but for local str we can use .parse(database_url, conn_max_age=600)
if not os.environ.get("DATABASE_URL"):
    print(f"#### WARNING: no DATABASE_URL environment var")
    os.environ["DATABASE_URL"] = "sqlite:////tmp/default.sqlite3"
DATABASES['default'] = dj_database_url.config(conn_max_age=600)
print(f"#### DEV.PY DB {DATABASES=}")

try:
    from .local import *
except ImportError:
    pass
