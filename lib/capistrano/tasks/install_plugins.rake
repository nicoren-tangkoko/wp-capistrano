require 'json'
namespace "wp-capistrano" do
  desc 'Install wordpress plugins'
  task :install_plugins do
    on roles(:app) do  
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
            
            plugins = [];
            
            installedPluginsArr.each_with_index do |plugin, index|
                  if(index == 0)
                     next
                  end
                  pluginInfo = {:slug =>  plugin, :version => installedPluginsVersionArr[index], :status => installedPluginsStatusArr[index] }
                  plugins.push(pluginInfo)
            end

            jsonPlugins.each do |plugin, version|
              plugginInfo = plugins.detect {|f| f["slug"] == plugin }
               if(plugginInfo)
                  plugginInfo[:version] = version
               else
                  pluginInfo = {:slug =>  plugin, :version => version, :status => "activate" }
                  plugins.push(pluginInfo)
               end
            end

            plugins.each do |plugin|
               existingPlugins = capture("/usr/bin/env php /tmp/wp-cli.phar plugin search #{plugin[:slug]} --path=#{release_path} --field=slug --per-page=999999")
               if (existingPlugins.to_s.gsub(/\n/, '|').split("|").include?("#{plugin[:slug]}") == false)
                  warn "Pluggin #{plugin[:slug]} not known in wordpress repository. skip installation"
                  next
               end

               info "install #{plugin[:slug]}:#{plugin[:version]}"
               execute "/usr/bin/env php /tmp/wp-cli.phar plugin install #{plugin[:slug]} --path=#{release_path} --version=#{plugin[:version]}"
           end
           plugins.each do |plugin|
           	if (plugin[:status] == "active")
                  execute "/usr/bin/env php /tmp/wp-cli.phar plugin activate #{plugin[:slug]} --path=#{release_path}"
                  info "activate #{plugin}"
               else
                  execute "/usr/bin/env php /tmp/wp-cli.phar plugin deactivate #{plugin[:slug]} --path=#{release_path}"
                  info "deactivate #{plugin[:slug]}"
               end
           end
         end
      end
    end
end
