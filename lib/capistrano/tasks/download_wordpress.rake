namespace "wp-capistrano" do
  desc 'Download wordpress'
  task :download_wordpress do
    on roles(:app) do
          execute "wget http://wordpress.org/latest.tar.gz -P /tmp/"
          execute "tar xzf /tmp/latest.tar.gz -C #{release_path} wordpress --strip-components=1"
          execute "wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp/"
        end
    end
end