======
 TODO
======

* After initial wagtailjanitor, opening the wagtail app isn't getting styled.

#### DEV.PY STORAGES configuring STORAGES for S3 bucket_name='wagtaillwa-dev-s3media-r0fhnejxii1y'
Copying '/app/scale0/static/css/scale0.css'
...
Copying '/VENV/lib/python3.12/site-packages/django/contrib/admin/static/admin/js/vendor/xregexp/xregexp.min.js'
223 static files copied.

I see lots of files in S3.

S3 static website hosting
Disabled

If I try to get one of the assets by it's HTTP address, it's AccessDenied.
https://wagtaillwa-dev-s3media-r0fhnejxii1y.s3.eu-west-3.amazonaws.com/wagtailimages/images/Jcrop.gif

Looking at Permissions, it shows Everyone(public) is NOT allowed Read access.

If I look at the URLs of missing resources, I see they're Presigned URLs, so we don't need to set the files to be public-read. We need to figure out why the Presigned URLs aren't working.

See dev.py where I specify bucket info. May need to add AWS_SIGNATURE_VERISON="s3v4"

* Create prefix "/media/" and "/static/"

* figure out why collectstatic -c is failing on the -c

* See Dockerfile and polls/polls/settings.,py in
  https://github.com/fun-with-serverless/serverless-django/
  See settings for AWS POWER TOOLS logger
  XXX settings for STATIC_URL, STATIC_ROOT, in fact no S3 at all

* https://aws.amazon.com/blogs/containers/deploy-and-scale-django-applications-on-aws-app-runner/
  use gunicorn
  ALLOWD_HOSTS for AppRunner
  STATIC_URL, STATIC_ROOT, STORAGES (with files)


