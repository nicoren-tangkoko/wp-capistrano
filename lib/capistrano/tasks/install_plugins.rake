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
            installedPlugins = capture("/usr/bin/env php /tmp/wp-cli.phar plugin list --path=#{current_path} |awk '{ print $1 }'")
            installedPluginsArr = installedPlugins.to_s.gsub(/\n/, '|').split("|")
            installedPluginsStatus = capture("/usr/bin/env php /tmp/wp-cli.phar plugin list --path=#{current_path} |awk '{ print $2 }'")
            installedPluginsStatusArr = installedPluginsStatus.to_s.gsub(/\n/, '|').split("|")
            installedPluginsVersion = capture("/usr/bin/env php /tmp/wp-cli.phar plugin list --path=#{current_path} |awk '{ print $4 }'")
            installedPluginsVersionArr = installedPluginsVersion.to_s.gsub(/\n/, '|').split("|")
            
            plugins = []
            languages = []
            
            installedPluginsArr.each_with_index do |plugin, index|
                  if(index == 0)
                     next
                  end
                  pluginInfo = {:slug =>  plugin, :version => installedPluginsVersionArr[index], :status => installedPluginsStatusArr[index] }
                  plugins.push(pluginInfo)
            end
            if( !jsonPlugins["plugins"].nil? )
	        jsonPlugins["plugins"].each do |plugin, version|
	            plugginInfo = plugins.detect {|f| f["slug"] == plugin }
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
	            execute "/usr/bin/env php /tmp/wp-cli.phar language core install #{language} --path=#{release_path}"
	            execute "/usr/bin/env php /tmp/wp-cli.phar language core activate #{language} --path=#{release_path}"
	        end
	    end


            plugins.each do |plugin|
               existingPlugins = capture("/usr/bin/env php /tmp/wp-cli.phar plugin search #{plugin[:slug]} --path=#{release_path} --field=slug --per-page=999999")
               if (existingPlugins.to_s.gsub(/\n/, '|').split("|").include?("#{plugin[:slug]}") == false)
                  warn "Pluggin #{plugin[:slug]} not known in wordpress repository. skip installation"
                  next
               end
               
               if (plugin[:version] == "uninstall")
                  warn "Uninstall pluggin #{plugin[:slug]}"
                  next
               end

               info "install #{plugin[:slug]}:#{plugin[:version]}"
               if(plugin[:version]) == "latest"
                  execute "/usr/bin/env php /tmp/wp-cli.phar plugin install #{plugin[:slug]} --path=#{release_path}"
                  info "install #{plugin[:slug]}"
               else
                  execute "/usr/bin/env php /tmp/wp-cli.phar plugin install #{plugin[:slug]} --path=#{release_path} --version=#{plugin[:version]}"
                  info "install #{plugin[:slug]} #{plugin[:version]}"
               end
           end
           plugins.each do |plugin|
           	if (plugin[:status] == "active")
                  execute "/usr/bin/env php /tmp/wp-cli.phar plugin activate #{plugin[:slug]} --path=#{release_path}"
                  info "activate #{plugin[:slug]}"
               else
                  execute "/usr/bin/env php /tmp/wp-cli.phar plugin deactivate #{plugin[:slug]} --path=#{release_path}"
                  info "deactivate #{plugin[:slug]}"
               end
           end
         end
      end
    end
end
