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

echo $plugins

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
         upload! StringIO.new(bashScript), "/tmp/install_plugins.sh"
         if(File.exist?("#{release_path}/plugins.json"))
            then plugins = JSON.parse(File.read("#{release_path}/plugins.json"))
         end
         execute "/bin/bash /tmp/install_plugins.sh -c \"#{current_path}\" -n #{release_path} -p #{plugins}"
      end
    end
end