namespace "wp-capistrano" do
desc 'Download wordpress'
task :update_wordpress do
    on roles(:app) do
        execute "php /tmp/wp-cli.phar core update --path=#{release_path}"
        end
    end
end