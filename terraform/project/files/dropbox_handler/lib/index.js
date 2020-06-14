'use strict'

const fetch = require('node-fetch')

async function main (event, context) {
  if ('challenge' in (event.queryStringParameters || {})) {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'text/plain',
        'X-Content-Type-Options': 'nosniff'
      },
      body: event.queryStringParameters.challenge
    }
  }

  console.log('received request')
  const resp = await fetch('https://api.github.com/repos/chrisdickinson/neversaw.us/dispatches', {
    method: 'POST',
    headers: {
      authorization: `token ${process.env.GITHUB_TOKEN}`,
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      event_type: 'dropbox',
      client_payload: {}
    })
  })
  console.log('response status=%s', resp.status)
  console.log('response body=%s', await resp.text())

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8'
    },
    body: '<p>Bonjour au monde!</p>'
  }
}

exports.main = main
exports.handlers = (event, context, ready) => {
  return main(event, context).then(
    xs => ready(null, xs),
    xs => {
      console.error(xs)
      return ready(null, {
        statusCode: 500,
        body: xs.stack || xs.message,
        headers: { 'Content-Type': 'text/plain' }
      })
    }
  )
}
