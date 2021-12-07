namespace "wp-capistrano" do
  desc 'Download wordpress'
  task :download_wordpress do
    on roles(:app) do
          execute "wget -N http://wordpress.org/latest.tar.gz -P #{fetch(:tmp_dir)}"
          execute "tar xzf /tmp/latest.tar.gz -C #{release_path} wordpress --strip-components=1"
          execute "wget -N https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P #{fetch(:tmp_dir)}"
          execute "chmod u+x #{fetch(:tmp_dir)}"
        end
    end
end
