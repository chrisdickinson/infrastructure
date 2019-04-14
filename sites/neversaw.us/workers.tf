# this terraform file contains definitions for the content backing the
# blog as well as the dynamic worker scripts and page rules that act
# on that content.

# This bucket contains only static content (HTML & CSS) served in website
# mode.
resource "aws_s3_bucket" "bucket-site" {
  bucket = "www.${var.domain}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "bucket-apocrypha" {
  bucket = "apocrypha.${var.domain}"
  acl    = "private"
}

# This bucket stores a single, well-known object. The object contains the
# latest build of the cloudflare worker.
resource "aws_s3_bucket" "cloudflare-workers" {
  bucket = "cloudflare-workers"
  acl    = "private"
}

# We pull in that well-known object here.
data "aws_s3_bucket_object" "cloudflare_worker_script" {
  bucket = "${aws_s3_bucket.cloudflare-workers.id}"
  key    = "neversawus.js"
}

# ...and give it to Cloudflare.
resource "cloudflare_worker_script" "neversawus_worker" {
  zone    = "${var.domain}"
  content = "${data.aws_s3_bucket_object.cloudflare_worker_script.body}"
}

resource "cloudflare_worker_route" "neversawus_worker_route" {
  zone    = "${var.domain}"
  pattern = "www.${var.domain}/*"
  enabled = true
  depends_on = ["cloudflare_worker_script.neversawus_worker"]
}
