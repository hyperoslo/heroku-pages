# Heroku Pages

[![Code Climate](https://img.shields.io/codeclimate/github/hyperoslo/heroku-pages.svg?style=flat)](https://codeclimate.com/github/hyperoslo/heroku-pages)

Easily inspect, view and upload your [Heroku error and maintenance pages](https://devcenter.heroku.com/articles/error-pages#customize-pages).

**Supported Ruby versions: 1.9.3 or higher**

Licensed under the **MIT** license, see LICENSE for more information.


## Installation

This is a Heroku client plugin and as such requires the [Heroku Toolbelt](https://toolbelt.heroku.com/) to be installed.

```shell
heroku plugins:install https://github.com/hyperoslo/heroku-pages.git
```


## Usage

If you have multiple apps, you may specify either app or remote:

```shell
heroku pages -a hyper-rocks-staging
heroku pages -r staging
```

### Inspecting

To view the current set of Heroku pages:

```shell
heroku pages
```

### Opening / Viewing

To open all Heroku pages using the default application (which tends to be a browser):

```shell
heroku pages:open
```

### Uploading to S3

To upload your Heroku pages to S3 using [AWS Command Line Interface](http://aws.amazon.com/cli):

```shell
heroku pages:upload
```

It assumes the following configuration variables to be present for the given app:

- `AWS_REGION`
- `AWS_BUCKET`
- `AWS_KEY` or `AWS_ACCESS_KEY_ID`
- `AWS_SECRET` or `AWS_SECRET_ACCESS_KEY`

The folder `public/heroku_pages` is assumed to be present in your project.

Remote folder `heroku_pages` on your S3 bucket will be created and all files uploaded to it will be made public.

**Note**: Any hidden files - files starting with `.` - will not be uploaded.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create pull request


## Credits

Hyper made this. We're a digital communications agency with a passion for good code,
and if you're using this plugin we probably want to hire you.
