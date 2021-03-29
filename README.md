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

## Workflow

The default capistrano workflow is used with the addition of theses tasks.

```ruby
before 'deploy:check:linked_files', 'wp-capistrano:create_wp_config'
before 'deploy:updating', 'wp-capistrano:download_wordpress'
after 'wp-capistrano:download_wordpress', 'wp-capistrano:install_wordpress'
after 'wp-capistrano:download_wordpress', 'wp-capistrano:update_wordpress'
```
