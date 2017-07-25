# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'yaml'

VAGRANTFILE_API_VERSION ||= "2"
confDir = $confDir ||= File.expand_path(File.dirname(__FILE__))

weareltYamlPath = confDir + "/wearelt.yaml"
weareltJsonPath = confDir + "/wearelt.json"

require File.expand_path(File.dirname(__FILE__) + '/.scripts/wearelt.rb')

Vagrant.require_version '>= 1.9.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|


    if File.exist? weareltYamlPath then
        settings = YAML::load(File.read(weareltYamlPath))
    elsif File.exist? weareltJsonPath then
        settings = JSON.parse(File.read(weareltJsonPath))
    else
        abort "wearelt settings file not found in #{confDir}"
    end

    Wearelt.configure(config, settings)

    if defined? VagrantPlugins::HostsUpdater
        config.hostsupdater.aliases = settings['sites'].map { |site| site['map'] }
    end
end
