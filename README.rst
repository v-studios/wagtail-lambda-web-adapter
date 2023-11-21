====================================
 Wagtail on Lambda with Web Adapter
====================================

The AWS Lambda Web Adapter promises to allow conventional HTTP-request
web apps runable in Lambda environment, using an adapter to convert
Lambda request/response into HTTP request/response. Try to get Wagtail
running in it.

https://github.com/awslabs/aws-lambda-web-adapter

We can build the image and run the container locally::

  make build
  make run

We can build and deploy to Lambda with a Function URL::

  npx sls deploy

Because the DB is currently an SQLite on the Lambda, each new instance
will get an empty DB and have to go through the slow-ish migrate
stuff.

We need to create an external DB, like Aurora Serverless v1.
