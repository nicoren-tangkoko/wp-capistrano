namespace "wp-capistrano" do
  desc 'Install plugins dependencies using composer'
  task :plugins_composer_install do
      on roles(:app) do
        pluginDirectory = "../app/web/wp-content/plugins/"

        Dir.foreach(pluginDirectory) { |directory| 
          if (directory != "." and directory != "..")
            puts "#################################\n# Plugin #{directory}\n#################################" 
            Dir.chdir(pluginDirectory + directory) do
              puts 
              if (Dir.exist?(Dir.pwd + '/vendor') == false && File.exist?(Dir.pwd + '/composer.lock') == true)
                puts '=> NEED INSTALL : There is no vendor installed and composer.lock'
                execute "ls #{release_path}/wp-content/plugins/"
                execute "composer install --working-dir=#{release_path}/wp-content/plugins/" + directory
              else
                puts '=> NO NEED INSTALL'
              end
            end

            puts ' '
          end
        }
        
        puts "#################################\n#End Install Plugins\n#################################"
      end
  end
end

