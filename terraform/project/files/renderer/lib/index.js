'use strict'

const hl = require('remark-highlight.js')
const mdhtml = require('remark-html')
const toml = require('@iarna/toml')
const remark = require('remark')
const S3 = require('aws-sdk/clients/s3')

const FRONTMATTER = '\n---\n\n'

async function main (event, context) {
  console.log(`main`, event)
  const start = Date.now()
  const s3Client = new S3({
    accessKeyId: process.env.S3_ACCESS_KEY,
    secretAccessKey: process.env.S3_SECRET_KEY,
    region: process.env.REGION || 'us-west-2'
  })
  for (const { s3 = null, eventName = null } of event.Records) {
    if (!s3 || !s3.object || !s3.object.key || !s3.bucket || !s3.bucket.name) {
      continue
    }

    // only process markdown, please.
    if (!/\.md/.test(s3.object.key)) {
      continue
    }

    console.log(`Processing ${eventName} for ${s3.bucket.name}/${s3.object.key}`)
    if (!/ObjectCreated/.test(eventName)) {
      continue
    }

    let data = null
    try {
      const response = await s3Client.getObject({
        Key: s3.object.key,
        Bucket: s3.bucket.name
      }).promise()

      data = String(response.Body)
    } catch (err) {
      console.error(`Caught error ${err.message} while fetching bucket=${s3.bucket.name} key=${s3.object.key}`)
      continue
    }

    let [first, ...rest] = data.split(FRONTMATTER)
    if (!rest.length) {
      rest = [first]
      first = ''
    }

    let frontmatter = null
    try {
      frontmatter = toml.parse(first)
    } catch (err) {
      console.error(`Caught error ${err.message} while parsing toml front matter for bucket=${s3.bucket.name} key=${s3.object.key}`)
      continue
    }

    const { title, slug = s3.object.key.replace(/.md$/, ''), date, metadata, framing = 'default.html' } = frontmatter

    const markdown = rest.join(FRONTMATTER)
    const html = await remark().use(hl).use(mdhtml).process(markdown)

    await s3Client.putObject({
      Key: slug ? `${slug}/index.html` : s3.object.key.replace(/(\.md)+$/, '/index.html'),
      Bucket: process.env.S3_DESTINATION_BUCKET,
      Body: String(html.contents) + `\n\n<!-- built at ${new Date().toISOString()} by ${process.env.RELEASE} in ${Date.now() - start}ms -->`,
      ACL: 'public-read',
      ContentType: 'text/html; charset=utf-8',
      Metadata: {
        title: title || 'Untitled',
        date: String(date || new Date()),
        fromdoc: s3.object.key,
        framing,
        ...metadata
      }
    }).promise()
  }
}

exports.main = main
exports.handlers = (event, context, ready) => {
  return main(event, context).then(
    xs => ready(),
    xs => {
      console.error(xs)
      return ready()
    }
  )
}
