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

## Setup

### 0. Clone this repo

`git clone git@github.com:chrisdickinson/infrastructure.git`

---

### 1. Install Direnv

You can follow the easy instructions [here](https://direnv.net/docs/installation.html).

Once you have direnv, `cd` into your checkout of this repository and type `direnv allow`. This will install the following
prerequisites:

- `awscli`
- `op`, the 1Password CLI
- `packer`
- `ansible`
- `terraform`
- `jq`

> You can see how these are installed by looking at `.envrc`, which is run in a
> subshell managed by direnv.

---

### 2. (Optionally) Configure 1Password Integration values

By default, this repo assumes you'll be logging into a personal 1Password
account (at my.1password.com), with a "Personal" vault and a secure note
called `credentials.env`.

You can configure different settings by setting the following environment variables:

- `ONEPASSWORD_DOMAIN`: If you are using this in a 1Pass team context, you can provide a team subdomain here. Example: `ONEPASSWORD_DOMAIN=mygreatcompany`. Defaults to `my` if not set.
- `ONEPASSWORD_VAULT`: Set this to the vault where you'd like to keep your AWS credentials. Example: `ONEPASSWORD_VAULT=Sprockets`. Defaults to `Personal`.
- `ONEPASSWORD_ITEM`: Set this to the name of the secure note you'd like to use. Defaults to `credentials.env`.

---

### 3. Configure 1Password CLI

If you are setting up a fresh install, you will need to run the following:

```
$ op signin my.1password.com <your email address>
```

You will be prompted for your secret 1Pass key as well as your password. If you
want to use a team domain, replace `my` with your team's name. You should also
set a `ONEPASSWORD_DOMAIN` variable with your team's name in your
`.bash_profile`.

---

### 4. Configure credentials in 1Password

Define and export the following environment variables in a new shell.

- `CLOUDFLARE_EMAIL`: The email associated with your Cloudflare account.
- `CLOUDFLARE_ZONE_ID`: The zone id of your Cloudflare account.
- `CLOUDFLARE_TOKEN`: The token granting programmatic access to your Cloudflare account.
- `AWS_ACCESS_KEY_ID`: The public half of the AWS keypair used for managing the account.
- `AWS_SECRET_ACCESS_KEY`: The secret half of the AWS keypair.
- `AWS_DEFAULT_REGION`: The AWS region you wish to operate in. Defaults to `us-west-2`.
- `TF_VAR_site_access_key`: The public half of the AWS keypair restricted to writing S3 data to a particular AWS bucket. Used in the AWS Lambda for writing items.
- `TF_VAR_site_secret_key`: The private half of the AWS keypair.
- `GITHUB_USERNAME`: Your GitHub username.

Run `bin/setup-credentials`. This will save a new secure note in your configured vault, replacing any existing item by the same name (defaults to `Personal` vault, `credentials.env`.)

Close the shell when you are finished.

---

### 5. Source activate-credentials

In order to run Terraform, Packer, AWS CLI, or any other scripts, run `source bin/activate-credentials`.

This will pull a script containing environment variables out of 1Password and source it, exporting those
values to your shell. Close your shell when you're finished!

---

## Notes

Example "upload the entire site to S3" command:

```
AWS_DEFAULT_REGION=us-west-2 aws s3 cp . s3://www.unbearablecomics.com/ --recursive --acl public-read
```

---

[Ubuntu AMI picker](https://cloud-images.ubuntu.com/locator/ec2/) for very good AMI bbs.

