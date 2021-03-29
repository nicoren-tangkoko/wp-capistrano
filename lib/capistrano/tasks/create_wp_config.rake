namespace "wp-capistrano" do
    desc 'create empty wp-config.php'
    task :create_wp_config do
        on roles(:app) do
            execute "touch #{shared_path}/wp-config.php"
        end
    end
end