======
 TODO
======

Create S3 and use for statics and media.

Create a non-web lambda that does the makemigrations, migrate, createsuperuser.
We'd just run it as a one-off.
Since it'd be deployed in the VPC, it will have access to the DB.


Maybe we can collectstatic when we build the image and serve locally?
See Dockerfile and polls/polls/settings.,py in
https://github.com/fun-with-serverless/serverless-django/

Use gunicorn and maybe whitenoise
https://aws.amazon.com/blogs/containers/deploy-and-scale-django-applications-on-aws-app-runner/


