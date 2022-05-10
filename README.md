# Running a Ruby app on Heroku with Phusion Passenger

[Phusion Passenger](https://www.phusionpassenger.com/) is an application server, designed to be fast, robust and lightweight. By combining Heroku with Phusion Passenger, you can boost the performance of your apps, utilize the available resources on your dynos much more efficiently and increase its stability.

Phusion Passenger for Heroku brings *the power of Nginx* to your dynos. Nginx is an extremely fast and lightweight web server that powers 10% of the Internet. All the cool guys are rapidly switching to Nginx. Phusion Passenger *replaces Thin and Unicorn*, and makes full use of Nginx to serve your Ruby apps faster and better.

<center><a href="https://www.phusionpassenger.com/"><img src="http://blog.phusion.nl/wp-content/uploads/2009/04/nginx_passenger_eyecatcher.png" height="150"></a></center>

<center><a href="http://vimeo.com/phusionnl/review/80475623/c16e940d1f"><img src="http://blog.phusion.nl/wp-content/uploads/2014/01/gameofthrones.jpg" height="250"></a></center>

Here's a list of the benefits that using Phusion Passenger will bring you:

 * **Static asset acceleration through Nginx** - Don't let your Ruby app serve static assets, let Nginx do it for you and offload your app for the really important tasks. Nginx will do a much better job.
 * **Multiple worker processes** - Instead of running only one worker on a dyno, Phusion Passenger runs multiple worker on a single dyno, thus utilizing its resources to its fullest and **giving you more bang for the buck**. This approach is similar to Unicorn's. But unlike Unicorn, Phusion Passenger dynamically scales the number of worker processes based on current traffic, thus freeing up resources when they're not necessary.
 * **Memory optimizations** - Phusion Passenger uses less memory than Thin and Unicorn. It also supports copy-on-write virtual memory in combination with code preloading, thus making your app use even less memory when run on Ruby 2.0.
 * **Request/response buffering** - The included Nginx buffers requests and responses, thus protecting your app against slow clients (e.g. mobile devices on mobile networks) and improving performance.
 * **Out-of-band garbage collection** - Ruby's garbage collector is slow, but why bother your visitors with long response times? Fix this by running garbage collection outside of the normal request-response cycle! This concept, first introduced by Unicorn, has been improved upon: Phusion Passenger ensures that only one request at the same time is running out-of-band garbage collection, thus eliminating all the problems Unicorn's out-of-band garbage collection has.
 * **JRuby support** - Unicorn's a better choice than Thin, but it doesn't support JRuby. Phusion Passenger does.

More information about Phusion Passenger:

 * [Website](https://www.phusionpassenger.com/)
 * [Documentation](https://www.phusionpassenger.com/library/)
 * [Support](https://www.phusionpassenger.com/support/)
 * [Source code](https://github.com/phusion/passenger)
 * [Community discussion forum](https://groups.google.com/d/forum/phusion-passenger)
 * [Issue tracker](https://github.com/phusion/passenger/issues)

## What people say

<img src="https://blog.phusion.nl/content/images/2015/05/lukepatrickheroku.png">
<img src="https://blog.phusion.nl/wp-content/uploads/2013/09/heroku-tweet.png">
<img src="https://blog.phusion.nl/wp-content/uploads/2013/11/heroku-tweet.png">

[Tweet about us too](https://twitter.com/share) or [follow us on Twitter](https://twitter.com/phusion_nl).

## Creating a new app

Clone this repository and push it to Heroku:

    git clone https://github.com/phusion/passenger-ruby-heroku-demo.git
    cd passenger-ruby-heroku-demo
    heroku create
    git push heroku master
    heroku open

Your app is now powered by Phusion Passenger!

## Switching an existing app to Phusion Passenger

Phusion Passenger is a drop-in replacement for Thin and Unicorn and very easy to install.

Open your app's Gemfile. Remove the following lines if they exist:

    gem "unicorn"
    gem "thin"
    gem "puma"

Insert:

    gem "passenger"

Open your app's Procfile, or create one if you don't already have one. Remove lines like this:

    web: bundle exec ruby web.rb -p $PORT
    web: bundle exec unicorn -p $PORT
    web: bundle exec thin start -p $PORT
    web: bundle exec puma -p $PORT

If you depend on Omniauth to authenticate with Facebook, G+, etc you must add the following lines to your `config/application.rb`:

    config.autoload_paths += Dir["#{config.root}/lib"]
    config.middleware.insert_before Rails::Rack::Logger, "HerokuNginxHeadersMiddleware"

Copy the `lib/heroku_nginx_headers_middleware.rb` to the `lib` directory in your Rails app.

Insert:

    web: bundle exec passenger start -p $PORT --max-pool-size 3

Finally, bundle install, commit and deploy:

    bundle install
    git commit -a -m "Switch to Phusion Passenger"
    git push heroku master

Congratulations, you're now running on Phusion Passenger!

## Configuration

Any configuration is done by customizing the arguments passed to the `passenger` command. The most important ones are:

 * `--max-pool-size` - The maximum number of worker processes to run. The maximum number that you can run depends on the amount of memory your dyno has.
 * `--min-instances` - If you don't want the number of worker processes to scale dynamically, then use this option to set it to a value equal to `--max-pool-size`.
 * `--spawn-method` - By default, Phusion Passenger preloads your app and utilizes copy-on-write (the "smart" spawning method). You can disable this by setting this option to `direct`.
 * `--no-friendly-error-pages` - If your app fails to start, Phusion Passenger will tell you by showing a friendly error page in the browser. This option disables it.

Please refer to the [configuration reference](https://www.phusionpassenger.com/library/config/standalone/reference/) for more information.

## Status service

Passenger provides [the `passenger-status` command](https://www.phusionpassenger.com/library/admin/standalone/overall_status_report.html), which displays a status report that tells you what application processes are currently running, how much memory and CPU they use, how many requests are being handled, etc.

However, `passenger-status` doesn't work out-of-the-box on Heroku because Heroku does not allow SSH access to its servers. For this reason, we have created the [Passenger Status Service](https://status-service.phusionpassenger.com/) for making Passenger status reports work.

Please visit [https://status-service.phusionpassenger.com/](https://status-service.phusionpassenger.com/) for more information.

## Passenger Enterprise

You can also use [Phusion Passenger Enterprise](https://www.phusionpassenger.com/enterprise) on Heroku, but with a caveat:

 * Passenger Enterprise's rolling restarts don't work. You need to use [Heroku's preboot facility](https://devcenter.heroku.com/articles/preboot) for that.

Here are the instructions for running Passenger Enterprise on Heroku:

 1. Add the Enterprise repo and gem to your Gemfile:

        source "https://download:#{your_download_key}@www.phusionpassenger.com/enterprise_gems"
        gem 'passenger-enterprise-server', '>= 5.0.22'

    'your_download_key' can be found in the [Customer Area](https://www.phusionpassenger.com/orders).

 2. Download the license key to your local workstation. Save it somewhere, e.g. to ~/passenger-enterprise-license.
 3. Transfer the contents of the license key to a Heroku  environment variable:

        heroku config:set PASSENGER_ENTERPRISE_LICENSE_DATA="`cat  ~/passenger-enterprise-license`"

 4. Commit and push to Heroku:

        git commit -a -m "Use Phusion Passenger Enterprise"
        git push heroku master

### Using Passenger open source in development, Enterprise in staging and production

It is possible to use Passenger open source in development, while using Passenger Enterprise in staging production. This works by creating a binstub `bin/passenger` which will start either Passenger open source or Passenger enterprise, depending on the value of the `RAILS_ENV` environment variable. Then the user must use the `bin/passenger` binstub instead of using the `passenger` command directly.

First, ensure that your Gemfile contains both 'passenger' and 'passenger-enterprise-server' but in different groups, like this:

    source 'https://rubygems.org'
    source "https://download:#{your_download_key}@www.phusionpassenger.com/enterprise_gems"

    group :development do
      gem 'passenger', '>= 5.0.22'
    end

    group :staging, :production do
      gem 'passenger-enterprise-server', '>= 5.0.22'
    end

Second, create a binstub `bin/passenger`. This binstub will start Passenger open source in development, Passenger Enterprise in staging and production. The binstub must contain:

    #!/usr/bin/env ruby

    require 'pathname'
    ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../../Gemfile",
      Pathname.new(__FILE__).realpath)

    require 'rubygems'
    require 'bundler/setup'

    if ENV['RAILS_ENV'] == 'staging' || ENV['RAILS_ENV'] == 'production'
      gem_name = 'passenger-enterprise-server'
    else
      gem_name = 'passenger'
    end

    bin_dir = Gem.loaded_specs[gem_name].bin_dir
    load File.join(bin_dir, 'passenger')

Make it executable:

    chmod +x bin/passenger

Third, modify your Procfile to use `./bin/passenger` instead of `passenger`. Replace this...

    web: bundle exec passenger start -p $PORT ...

...with this:

    web: bundle exec ./bin/passenger start -p $PORT ...

Install the gem bundle and commit the result:

    bundle install
    git add Gemfile Gemfile.lock Procfile bin/passenger
    git commit -a -m "Use Passenger Enterprise only in staging and production"

You can test the binstub locally as follows:

    $ ./bin/passenger --version
    Phusion Passenger 5.0.22
    $ RAILS_ENV=production ./bin/passenger --version
    Phusion Passenger Enterprise 5.0.22

## Next steps

 * Using Phusion Passenger on Heroku? [Tweet about us](https://twitter.com/share), [follow us on Twitter](https://twitter.com/phusion_nl) or [fork us on Github](https://github.com/phusion/passenger).
 * Having problems? Please post a message at [the community discussion forum](https://groups.google.com/d/forum/phusion-passenger).

[<img src="http://www.phusion.nl/assets/logo.png">](http://www.phusion.nl/)

Please enjoy Phusion Passenger, a product by [Phusion](http://www.phusion.nl/). :-)
