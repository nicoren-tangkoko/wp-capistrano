require 'json'
namespace "wp-capistrano" do
  desc 'Install wordpress plugins'
  task :install_plugins do
    on roles(:app) do  
         jsonPlugins = []
         info "Check file #{release_path}/plugins.json"
         if (test("[ -f #{release_path}/plugins.json ]"))
            debug "#{release_path}/plugins.json exist"
            pluginsStr = capture("cat #{release_path}/plugins.json")
            jsonPlugins = JSON.parse(pluginsStr)
         end
                  
         if(test("[ -L #{current_path} ]"))
            info "installing pluggins..."
            installedPlugins = capture("php #{fetch(:tmp_dir)}/wp-cli.phar plugin list --path=#{current_path} |awk 'BEGIN{OFS=":"} {print $2,$4,$6,$8}'");
            execute "php #{fetch(:tmp_dir)}/wp-cli.phar plugin list --path=#{current_path} |awk 'BEGIN{OFS=":"} {print $2,$4,$6,$8}'"
            plugins = []
            languages = []
            
            installedPlugins.each_line do |line|
                 
                  plugin = line.split(":");
                  if(plugin[0].empty?)
                     next
                  end
                  pluginInfo = {:slug =>  plugin[0], :version =>  plugin[1], :status =>  plugin[2] }
                  plugins.push(pluginInfo)
            end
            if( !jsonPlugins["plugins"].nil? )
	        jsonPlugins["plugins"].each do |plugin, version|
	            plugginInfo = plugins.detect {|f| f[:slug] == plugin }
	            if(plugginInfo)
	              plugginInfo[:version] = version
	              plugginInfo[:status] = "active"
	            else
	              pluginInfo = {:slug =>  plugin, :version => version, :status => "active" }
	              plugins.push(pluginInfo)
	            end
	        end
	    end
	    
	    if( !jsonPlugins["languages"].nil? )
	        jsonPlugins["languages"].each do |language|
	            execute "php #{fetch(:tmp_dir)}/wp-cli.phar language core install #{language} --path=#{release_path}"
	            execute "php #{fetch(:tmp_dir)}/wp-cli.phar language core activate #{language} --path=#{release_path}"
	        end
	    end


            plugins.each do |plugin|
               if (plugin[:version] == "uninstall")
                  warn "Uninstall pluggin #{plugin[:slug]}"
                  next
               end
               
               if(plugin[:slug].empty?)
                  warn "Slug empty : '#{plugin[:slug]}'"
                  next
               end
               
               existingPlugins = capture("php #{fetch(:tmp_dir)}/wp-cli.phar plugin search #{plugin[:slug]} --path=#{release_path} --field=slug --per-page=999999")
               if (existingPlugins.to_s.gsub(/\n/, '|').split("|").include?("#{plugin[:slug]}") == false)
                  warn "Pluggin #{plugin[:slug]} not known in wordpress repository. skip installation"
                  next
               end
               
               info "install #{plugin[:slug]}:#{plugin[:version]}"
               if(plugin[:version]) == "latest"
                  execute "php #{fetch(:tmp_dir)}/wp-cli.phar plugin install #{plugin[:slug]} --path=#{release_path} --force"
                  info "install #{plugin[:slug]}"
               else
                  execute "php #{fetch(:tmp_dir)}/wp-cli.phar plugin install #{plugin[:slug]} --path=#{release_path} --version=#{plugin[:version]} --force"
                  info "install #{plugin[:slug]} #{plugin[:version]}"
               end
           end
           plugins.each do |plugin|
            if(plugin[:version] == "uninstall")
              warn "Skipping #{plugin[:slug]}"
              next
            end
           	if (plugin[:status] == "active")
                  execute "php #{fetch(:tmp_dir)}/wp-cli.phar plugin activate #{plugin[:slug]} --path=#{release_path}"
                  info "activate #{plugin[:slug]}"
                elsif(plugin[:status] == "active-network")
                  execute "php #{fetch(:tmp_dir)}/wp-cli.phar plugin activate #{plugin[:slug]} --path=#{release_path} --network"
                elsif(plugin[:status] == "inactive")
                  execute "php #{fetch(:tmp_dir)}/wp-cli.phar plugin deactivate #{plugin[:slug]} --path=#{release_path}"
                  info "deactivate #{plugin[:slug]}"
               end
           end
           
           if( !jsonPlugins["languages"].nil? )
	        jsonPlugins["languages"].each do |language|
	            execute "php #{fetch(:tmp_dir)}/wp-cli.phar language plugin install --all #{language} --path=#{release_path}"
	        end
	    end
         end
      end
    end
end
