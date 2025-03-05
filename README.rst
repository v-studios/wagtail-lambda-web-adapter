====================================
 Wagtail on Lambda with Web Adapter
====================================

The AWS Lambda Web Adapter allows conventional HTTP-request
web apps to run in a Lambda environment, using an adapter to convert
Lambda request/response into HTTP request/response:

https://github.com/awslabs/aws-lambda-web-adapter

We'll deploy the Wagtail CMS (based on Django). I wish I'd seen this before
starting: 

https://github.com/fun-with-serverless/serverless-django/

Local with Docker
=================

Build the image and run the container locally::

  make build
  make run

TODO: That ``make run`` doesn't work. We can run our Serverless-built image with a tag it applies::

  docker run -it --rm serverless-wagtaillwa-dev:wagtaillwa bash

This is useful for testing things like ``collectstatic`` etc.

Because the DB is currently an SQLite on the Lambda, each new instance will get
an empty DB and have to go through the slow-ish migrate stuff. It might be
better to use an external DB, emulating the Aurora Serverless DB we'll hav ein
AWS. 

AWS with Aurora Serverless DB
=============================

All the other AWS infrastructure is defined in ``serverless.yml``: VPC, subnets,
Aurora Serverless v2 scale-to-zero DB, Lambda, Function URL, etc. Install the
Serverless Framework v3 with::
  
  npm install
  
Set your AWS profile like::

  export AWS_PROFILE=chris@chris+hack

Then we can build and deploy and update with::

  npx sls deploy

It first builds the Docker image and uploads it to ECR, creating a new ECR
Repository if needed. It then builds all the networking infrastructure, then the
Database Cluster and Instance, and finally the Lambdas that reference it.  The
first run takes a long time, almost 10 minutes, due to the DB. Subsequent
deploys take about 48 seconds (yeah, too long, but see `TODO.rst`_)


wagtailjanitor for initial setup, migration
===========================================

Use function ``wagtailjanitor`` uses the same image as the plain ``wagtail``
function, but sets a variable that ``start.sh`` script uses to setup the initial
data. There's no Function URL so just do it HOW from the console.

It first runs ./s3check.py to verify access to S3. Then it runs ``migrate`` to
setup the DB schema. Then it creates an admin with a password. Then it runs
``collectstatic`` to gather the static files. Finally it runs ``createsuperuser``, which will be OK if it's already been created. It has a longer timeout than the main service, since migrations can take a while.

For safety's sake, there's no Function URL like on the main service. Instead, go
to the Lambda console and hit the test button. You can also run it from the
CLI::

  npx sls invoke --log --function wagtailjanitor

TODO: talk about wiping and loading data with WAGTAIL_JANITOR="reset_db"...

wagtailresetdb to wipe and reload the DB
========================================

Just like above, but this one first wipes the Postgres DB (in case it's gotten corrupted by upgrading from an incompatible version, just saying). Then it loads the initial data.  It then does the same ``migrate``, ``collectstatic``, and ``createsuperuser`` as above.

  npx sls invoke --log --function --wagtailresetdb

You should use this before you try and attach to the app for the first time, or after hosing your DB. 

If you run it and see::

  psycopg.errors.ObjectInUse: database "wagtaillwa" is being accessed by other users
  DETAIL:  There are 2 other sessions using the database.

it means another Wagtail instance still has a connection to the DB. You'll have to wait a while for them to timeout, then try again.

Check wagtail itself
====================

After the initial setup, you should have a running wagtail. The Serverless
deploy output shows the function URL, plug it into a browser; you can also see
it in the AWS Console for the Lambda.


Update the Wagtail site code
============================

You can deploy changes that ONLY affect the lambda like::
  
  npx sls deploy --function wagtail  

This takes about 17 seconds.

This will NOT update the function's *configuration*, e.g., environment variables. You'll need the full deploy for that.


Issues
======

After running ``wagtailjanitor``, opening the wagtail app isn't getting styled. The janitor does the ``collectstatic`` which populates the S3 with non-public assets. During use of the webapp, Django-Storages calculates S3 Pre-Signed URLs which allow limited time viewing -- but these were giving me access denied or failed checksum errors.  I found adding the AWS region to the settings file fixed it::

  "region_name": "eu-west-3", 

OK, I take it back: I've removed that from ``staticfiles`` and it still works. Why didn't it work, and why does it work now? 


Flame
=====

Aurora Serverless v1 had proper defaults for MySQL and PostgreSQL ports: 3306 and 5432, respectively.  Serverless v2 requires ``provisioned`` and stupidly defaults both MySQL and PostgreSQL to use port 3306! This is a wildly unexpected change and breaks connectivity. Specify the DB cluster Port explicitly or ensure your SecurityGroups and DB connection strings are correct.
