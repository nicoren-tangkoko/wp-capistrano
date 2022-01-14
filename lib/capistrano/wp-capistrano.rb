#load File.expand_path("../tasks/create_wp_config.rake", __FILE__)
load File.expand_path("../tasks/download_wordpress.rake", __FILE__)
load File.expand_path("../tasks/install_wordpress.rake", __FILE__)
load File.expand_path("../tasks/update_wordpress.rake", __FILE__)
load File.expand_path("../tasks/install_plugins.rake", __FILE__)
load File.expand_path("../tasks/install_custom_plugins.rake", __FILE__)

namespace :load do
  task :defaults do
    load "capistrano/wp-capistrano/defaults.rb"
  end
end
