require 'json'
namespace "wp-capistrano" do
  desc 'Install wordpress plugins'
  task :install_plugins do
    on roles(:app) do
bashScript = <<BASH
          #!/bin/bash

Help()
{
   # Display Help
   echo "Download installed wordpress plugins"
   echo
   echo "Syntax: install_plugins [-c|n|h|v]"
   echo "options:"
   echo "-c | --current_path     Current wordpress path."
   echo "-n | --new_path     Path of release currently in deployment."
   echo "-h | --help    Print this Help."
   echo "-v | --verbose    Verbose mode."
   echo
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --current_path )           shift
                                current_path="$1"
                                ;;
        -p | --plugins )           shift
                                plugins="$1"
                                ;;
        -n | --new_path )    shift
                                new_path="$1"
                                ;;
        -h | --help )           Help
                                exit
                                ;;
        * )                     Help
                                exit 1
    esac
    shift
done


if [ -z $new_path ];
then
   echo -e "\e[31mArgument -n | --new_path is mandatory\e[0m"
   exit 1
fi

if [ -z $current_path ];
then
   echo -e "\e[32mArgument -c | --current_path not defined. Plugin installation skipped.\e[0m"
   exit 
fi

echo -e "\e[32mInstalling plugins ...\e[0m"

plugins=($(/usr/local/bin/php /tmp/wp-cli.phar plugin list --path=$current_path |awk '{ print $1 }'))
nbPlugins=$((${#plugins[@]} - 1))
plugins_status=($(/usr/local/bin/php /tmp/wp-cli.phar plugin list --path=$current_path |awk '{ print $2 }'))
plugins_versions=($(/usr/local/bin/php /tmp/wp-cli.phar plugin list --path=$current_path |awk '{ print $4 }'))
for i in `seq 1 $nbPlugins`;
do
  /usr/local/bin/php /tmp/wp-cli.phar plugin install ${plugins[i]} --path=$new_path --version=${plugins_versions[i]}
  echo /usr/local/bin/php /tmp/wp-cli.phar plugin install ${plugins[i]} --path=$new_path
  if [ ${plugins_status[i]} = "active" ];
  then
     /usr/local/bin/php /tmp/wp-cli.phar plugin activate ${plugins[i]} --path=$new_path
  else
     /usr/local/bin/php /tmp/wp-cli.phar plugin deactivate ${plugins[i]} --path=$new_path
  fi
done
BASH
    
         info "Check file #{release_path}/plugins.json"
         if (test("[ -f #{release_path}/plugins.json ]"))
            debug "#{release_path}/plugins.json exist"
            pluginsStr = capture("cat #{release_path}/plugins.json")
            jsonPlugins = JSON.parse(pluginsStr)
         end
         
         if(test("[ -L #{current_path} ]"))
            info "installing pluggins..."
            installedPlugins = capture("/usr/local/bin/php /tmp/wp-cli.phar plugin list --path=#{current_path} |awk '{ print $1 }'")
            installedPluginsArr = installedPlugins.to_s.gsub(/\n/, '|').split("|")
            installedPluginsStatus = capture("/usr/local/bin/php /tmp/wp-cli.phar plugin list --path=#{current_path} |awk '{ print $2 }'")
            installedPluginsStatusArr = installedPluginsStatus.to_s.gsub(/\n/, '|').split("|")
            installedPluginsVersion = capture("/usr/local/bin/php /tmp/wp-cli.phar plugin list --path=#{current_path} |awk '{ print $4 }'")
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
               existingPlugins = capture("/usr/local/bin/php /tmp/wp-cli.phar plugin search #{plugin[:slug]} --path=#{release_path} --field=slug --per-page=999999")
               if (existingPlugins.to_s.gsub(/\n/, '|').split("|").include?("#{plugin[:slug]}") == false)
                  warn "Pluggin #{plugin[:slug]} not known in wordpress repository. skip installation"
                  next
               end

               info "install #{plugin[:slug]}:#{plugin[:version]}"
               execute "/usr/local/bin/php /tmp/wp-cli.phar plugin install #{plugin[:slug]} --path=#{release_path} --version=#{plugin[:version]}"
               if (plugin[:status] == "active")
                  execute "/usr/local/bin/php /tmp/wp-cli.phar plugin activate #{plugin[:slug]} --path=#{release_path}"
                  info "activate #{plugin}"
               else
                  execute "/usr/local/bin/php /tmp/wp-cli.phar plugin deactivate #{plugin[:slug]} --path=#{release_path}"
                  info "deactivate #{plugin[:slug]}"
               end
           end
         end
      end
    end
end