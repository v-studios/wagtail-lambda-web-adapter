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

print(f"#### DEV.py {MEDIA_ROOT=} {STATIC_ROOT=}")
# MEDIA_ROOT='/app/media' STATIC_ROOT='/app/static'
# TODO put media and static under separate prefixes, how?
bucket_name = os.environ.get("AWS_STORAGE_BUCKET_NAME")
if bucket_name:
    print(f"#### DEV.PY STORAGES configuring STORAGES for S3 {bucket_name=}")
    INSTALLED_APPS.append("storages")  # media/ and static/ in S3
    STORAGES = {
        "default": {
            "BACKEND": "storages.backends.s3.S3Storage",
            "OPTIONS": {
                "bucket_name": bucket_name,  # should be found from ENV var
                # Default behavior uses non-public objects with Presigned URLs.
                #"default_acl": "public-read",
                #"querystring_auth": False,
                "region_name": "eu-west-3",
            },
        },
        "staticfiles": {
            "BACKEND": "storages.backends.s3.S3Storage",
            "OPTIONS": {
                "bucket_name": bucket_name,
                #"default_acl": "public-read",
                #"querystring_auth": False,
                "region_name": "eu-west-3",

            },
    },
}


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
