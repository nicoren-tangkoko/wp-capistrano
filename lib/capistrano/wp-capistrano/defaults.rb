# Default Flow
#before 'deploy:check:linked_files', 'wp-capistrano:create_wp_config'
before 'deploy:updated', 'wp-capistrano:download_wordpress'
after 'wp-capistrano:download_wordpress', 'wp-capistrano:install_wordpress'
after 'wp-capistrano:install_plugins', 'wp-capistrano:update_wordpress'
after 'wp-capistrano:install_wordpress', 'plugins_composer_install'
after 'plugins_composer_install', 'wp-capistrano:install_plugins'
