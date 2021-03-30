# wp-capistrano

Capistrano tasks used to deploy wordpress project.

## Install

```ruby
#add this line in your Gemfile
gem 'wp-capistrano3'
```

```ruby
#add this line in your Capfile
require 'capistrano/wp-capistrano'
```
Then run 
```shell
bundle install 
#or bundle update
```
set following variables in your deploy.rb
These variables will be used to generate wp_config.php at first deployment.
And will install an empty wordpress
```ruby
set :wp_db_name, "wp_db_name"
set :wp_db_password, "wp_db_password"
set :wp_db_user, "wp_db_user"
set :wp_db_host, "127.0.0.1"
#ADMIN LOCALE
set :wp_locale, "en_GB"

set :wp_url, "wp_domain"
set :wp_title, "wp site name"
set :wp_admin_user, "admin"
set :wp_admin_password, "password"
set :wp_admin_email, "admin@xxxx.com"
```

## Workflow

The default capistrano workflow is used with the addition of theses tasks.

```ruby
before 'deploy:check:linked_files', 'wp-capistrano:create_wp_config'
before 'deploy:updating', 'wp-capistrano:download_wordpress'
after 'wp-capistrano:download_wordpress', 'wp-capistrano:install_wordpress'
after 'wp-capistrano:download_wordpress', 'wp-capistrano:update_wordpress'
after 'wp-capistrano:install_wordpress', 'wp-capistrano:install_plugins'
```
