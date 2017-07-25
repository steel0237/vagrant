class Wearelt
    def Wearelt.configure(config, settings)
        # Set The VM Provider
        ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

        # Configure Local Variable To Access Scripts From Remote Location
        scriptDir = File.dirname(__FILE__)

        # Prevent TTY Errors
        config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

        # Allow SSH Agent Forward from The Box
        config.ssh.forward_agent = true
        config.ssh.username = "ubuntu"

        # Configure The Box
        config.vm.define settings["name"] ||= "wearelt"
        config.vm.box = settings["box"] ||= "ubuntu/xenial64"
        #config.vm.box_version = settings["version"] ||= ">= 2.0.0"
        config.vm.hostname = settings["hostname"] ||= "wearelt"

        # Configure A Private Network IP
        config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

        # Configure Additional Networks
        if settings.has_key?("networks")
            settings["networks"].each do |network|
                config.vm.network network["type"], ip: network["ip"], bridge: network["bridge"] ||= nil
            end
        end

        # Configure A Few VirtualBox Settings
        config.vm.provider "virtualbox" do |vb|
            vb.name = settings["name"] ||= "wearelt"
            vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
            vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", settings["natdnshostresolver"] ||= "on"]
            vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
            vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]
            if settings.has_key?("gui") && settings["gui"]
                vb.gui = true
            end
        end

        # Configure A Few VMware Settings
        ["vmware_fusion", "vmware_workstation"].each do |vmware|
            config.vm.provider vmware do |v|
                v.vmx["displayName"] = settings["name"] ||= "wearelt"
                v.vmx["memsize"] = settings["memory"] ||= 2048
                v.vmx["numvcpus"] = settings["cpus"] ||= 1
                v.vmx["guestOS"] = "ubuntu-64"
                if settings.has_key?("gui") && settings["gui"]
                    v.gui = true
                end
            end
        end

        # Configure A Few Parallels Settings
        config.vm.provider "parallels" do |v|
            v.name = settings["name"] ||= "wearelt"
            v.update_guest_tools = settings["update_parallels_tools"] ||= false
            v.memory = settings["memory"] ||= 2048
            v.cpus = settings["cpus"] ||= 1
        end

        # Standardize Ports Naming Schema
        if (settings.has_key?("ports"))
            settings["ports"].each do |port|
                port["guest"] ||= port["to"]
                port["host"] ||= port["send"]
                port["protocol"] ||= "tcp"
            end
        else
            settings["ports"] = []
        end

        # Default Port Forwarding
        default_ports = {
        }

        # Use Default Port Forwarding Unless Overridden
        unless settings.has_key?("default_ports") && settings["default_ports"] == false
            default_ports.each do |guest, host|
                unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
                    config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
                end
            end
        end

        # Add Custom Ports From Configuration
        if settings.has_key?("ports")
            settings["ports"].each do |port|
                config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: true
            end
        end



        # Configure The Public Key For SSH Access
        if settings.include? 'authorize'
            if File.exists? File.expand_path(settings["authorize"])
                config.vm.provision "shell" do |s|
                    s.inline = "echo $1 | grep -xq \"$1\" /home/ubuntu/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/ubuntu/.ssh/authorized_keys"
                    s.args = [File.read(File.expand_path(settings["authorize"]))]
                end
            end
        end

        # Copy The SSH Private Keys To The Box
        if settings.include? 'keys'
            if settings["keys"].to_s.length == 0
                puts "Check your Homestead.yaml file, you have no private key(s) specified."
                exit
            end
            settings["keys"].each do |key|
                if File.exists? File.expand_path(key)
                    config.vm.provision "shell" do |s|
                        s.privileged = false
                        s.inline = "echo \"$1\" > /home/ubuntu/.ssh/$2 && chmod 600 /home/ubuntu/.ssh/$2"
                        s.args = [File.read(File.expand_path(key)), key.split('/').last]
                    end
                else
                    puts "Check your Homestead.yaml file, the path to your private key does not exist."
                    exit
                end
            end
        end

        # Register All Of The Configured Shared Folders
        if settings.include? 'folders'
            settings["folders"].each do |folder|
                if File.exists? File.expand_path(folder["map"])
                    mount_opts = []

                    if (folder["type"] == "nfs")
                        mount_opts = folder["mount_options"] ? folder["mount_options"] : ['actimeo=1', 'nolock']
                    elsif (folder["type"] == "smb")
                        mount_opts = folder["mount_options"] ? folder["mount_options"] : ['vers=3.02', 'mfsymlinks']
                    end

                    # For b/w compatibility keep separate 'mount_opts', but merge with options
                    options = (folder["options"] || {}).merge({ mount_options: mount_opts })

                    # Double-splat (**) operator only works with symbol keys, so convert
                    options.keys.each{|k| options[k.to_sym] = options.delete(k) }

                    config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options

                    # Bindfs support to fix shared folder (NFS) permission issue on Mac
                    if Vagrant.has_plugin?("vagrant-bindfs")
                        config.bindfs.bind_folder folder["to"], folder["to"]
                    end
                else
                    config.vm.provision "shell" do |s|
                        s.inline = ">&2 echo \"Unable to mount one of your folders. Please check your folders in Homestead.yaml\""
                    end
                end
            end
        end







        #if settings.has_key?("config")
        #    settings["config"].each do |config|
        #        config.vm.provision "fix-no-tty", type:"shell" do |s|
        #            s.privileged = true
        #            s.path = scriptDir + "/create-config.sh"
        #        end
        #    end
        #end



        #config.vm.provision "shell" do |s|
        #    s.name = "Restarting Nginx"
        #    s.inline = "sudo service nginx restart; sudo service php7.1-fpm restart"
        #end
                config.vm.provision "file" do |f|
                    f.source = File.expand_path("./.scripts/config")
                    f.destination = "/tmp/"
                end

                config.vm.provision "shell" do |s|
                    s.privileged = true
                    s.name = "Creating nginx: "
                    s.path = scriptDir + "/create-nginx.sh"
                end


            config.vm.provision "shell" do |s|
                s.privileged = true
                s.path = scriptDir + "/create-php.sh"
            end

            config.vm.provision "shell" do |s|
                s.privileged = true
                s.path = scriptDir + "/create-sys.sh"
            end

        # Configure All Of The Configured Databases
        if settings.has_key?("databases")
            settings["databases"].each do |db|
                config.vm.provision "shell" do |s|
                    s.name = "Creating Postgres Database: " + db
                    s.path = scriptDir + "/create-postgres.sh"
                    s.args = [db]
                end

            end
        end

        if settings.has_key?("other")
            settings["other"].each do |other|
                config.vm.provision "shell" do |s|
                    s.name = "Install Others utils: " + other
                    s.privileged = true
                    s.path = scriptDir + "/create-other.sh"
                    s.args = [other]
                end
            end
        end


        if settings.include? 'sites'
            settings["sites"].each do |site|

                # Create SSL certificate
                #config.vm.provision "shell" do |s|
                    #s.name = "Creating Certificate: " + site["map"]
                    #s.path = scriptDir + "/create-certificate.sh"
                    #s.args = [site["map"]]
                #end

                config.vm.provision "shell" do |s|
                    s.name = "Creating Site: " + site["map"]
                    s.privileged = true
                    if site.include? 'params'
                        params = "("
                        site["params"].each do |param|
                            params += " [" + param["key"] + "]=" + param["value"]
                        end
                        params += " )"
                    end
                    s.path = scriptDir + "/create-site.sh"
                    s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443", params ||= ""]
                end
            end
        end


                #config.vm.provision "shell" do |s|
                #    s.inline = "cp -fr /tmp/config/config/php/ /etc/php/"
                #    s.inline = "cp -fr /tmp/config/config/nginx/ /etc/nginx/"
                #end



        #if settings.has_key?("variables")
        #    settings["variables"].each do |var|
        #        config.vm.provision "shell" do |s|
        #            s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php/7.1/fpm/php-fpm.conf"
        #            s.args = [var["key"], var["value"]]
        #        end
        #    end
        #    config.vm.provision "shell" do |s|
        #        s.inline = "service php7.1-fpm restart"
        #    end
        #end

        # Update Composer On Every Provision

        #config.vm.provision "shell" do |s|
        #    s.name = "Update Composer"
        #    s.inline = "sudo /usr/local/bin/composer self-update && sudo chown -R ubuntu:ubuntu /home/ubuntu/ && mkdir /home/ubuntu/run/ && mkdir /home/ubuntu/log/ && mkdir /home/ubuntu/tmp/"
        #end


        config.vm.provision "shell" do |s|
            s.name = "Reload services : "
            s.privileged = true
            s.inline = "service php7.1-fpm restart && service nginx restart && service postgresql restart"
        end



    end
end
