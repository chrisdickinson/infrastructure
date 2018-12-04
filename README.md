# chrisdickinson's personal infrastructure

I run a couple of HYPERTEXT PROTOCOL WEBSERVERS on the internet, amongst other
things.

This repository contains terraform configuration for these sites:

- neversaw.us
- unbearablecomics.com
- modules.guide
- didact.us

The resources and configuration for the sites live in `sites/`, while common
functionality will be factored out into `modules/`.

To do anything with this repository, you'll need the following environment
variables set:

```
export CLOUDFLARE_EMAIL=
export CLOUDFLARE_ZONE_ID=
export CLOUDFLARE_TOKEN=
export AWS_ACCESS_KEY=
export AWS_SECRET_KEY=
export TF_VAR_access_key="$AWS_ACCESS_KEY"
export TF_VAR_secret_key="$AWS_SECRET_KEY"
```

Don't commit them!

## Notes

Example "upload the entire site to S3" command:

```
AWS_DEFAULT_REGION=us-west-2 aws s3 cp . s3://www.unbearablecomics.com/ --recursive --acl public-read
```
