======
 TODO
======

* The Makefile isn't being used; it wants to be helpful for local development
  and running, but we're not doing that.  I've added the ``run_wagtaillwa`` to
  run the image built by Serverless and drop into a shell to poke around; you
  can probably set environment vars to connect it to S3.

* Separate AWS infra from serverless code: The infrastructure changes very
  little while the functions (wagtail app code) get updated  frequently. The
  ``sls deploy`` takes 48 seconds without any infra changes. If we separate out
  the network, database, and other non-Lambba stuff, we should be able to make
  code deploys much faster. 

* can I extend wagtailjanitor to accept arbitrary commands? I'd like to sometimes flush the DB or make migrations, etc, but not always. 