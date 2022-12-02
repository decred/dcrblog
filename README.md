# dcrblog

Source code for the Decred Project Blog, hosted at <https://blog.decred.org>.

## Development

Install the **extended** version of [Hugo](https://gohugo.io/) somewhere along your `$PATH`.

```bash
$ bin/watch.sh
```

Then access the page with a browser (the server usually starts in `https://localhost:1313`).

## Deployment

```bash
$ bin/build.sh
```

This will build the docker image.
