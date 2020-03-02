'use strict'

addEventListener('fetch', event => {
  event.respondWith(main(event).then(
    res => res,
    err => new Response(`caught error (${err.stack})`, {
      status: 500
    })
  ))
})

async function main (event) {
  const response = await fetch(event.request)
  const headers = new Headers(response.headers)

  headers.set('x-clacks-overhead', 'GNU Terry Pratchett')
  headers.set('meta', JSON.stringify({
    release: process.env.RELEASE
  }))

  return new Response(response.body, {
    statusText: response.statusText,
    status: response.status,
    headers
  })
}
