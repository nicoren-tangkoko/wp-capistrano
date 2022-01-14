# Default Flow
#before 'deploy:check:linked_files', 'wp-capistrano:create_wp_config'
before 'deploy:updating', 'wp-capistrano:download_wordpress'
after 'wp-capistrano:download_wordpress', 'wp-capistrano:install_wordpress'
after 'wp-capistrano:install_plugins', 'wp-capistrano:update_wordpress'
after 'deploy:updating', 'wp-capistrano:install_plugins'
