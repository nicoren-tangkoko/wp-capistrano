namespace "wp-capistrano" do
  desc 'Install wordpress'
  task :install_wordpress do
    on roles(:app), filter: :no_release do
          if (File.exist?("#{release_path}/wp-config.php") == false)
          	execute "php #{fetch(:tmp_dir)}/wp-cli.phar config create --dbname=#{fetch(:wp_db_name)} --dbuser=#{fetch(:wp_db_user)} --dbpass=#{fetch(:wp_db_password)} --dbhost='#{fetch(:wp_db_host)}'  --locale=#{fetch(:wp_locale)} --path=#{release_path}"
          	execute "cp #{release_path}/wp-config.php #{shared_path}/"
          end
          execute "php #{fetch(:tmp_dir)}/wp-cli.phar core install --url='#{fetch(:wp_url)}' --title='#{fetch(:wp_title)}' --admin_user='#{fetch(:wp_admin_user)}' --admin_password='#{fetch(:wp_admin_password)}' --admin_email='#{fetch(:wp_admin_email)}' --skip-email --path=#{release_path}"
        end
    end
end
