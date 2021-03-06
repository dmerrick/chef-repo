# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "vagrant-ubuntu-raring-64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://cloud-images.ubuntu.com/raring/current/raring-server-cloudimg-vagrant-amd64-disk1.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8888

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #config.vm.provider :virtualbox do |vb|
  #  # Don't boot with headless mode
  #  vb.gui = true
  #
  #  # Use VBoxManage to customize the VM. For example to change memory:
  #  #vb.customize ["modifyvm", :id, "--memory", "1024"]
  #end

  # adding support for berkshelf
  # first: vagrant plugin install vagrant-berkshelf
  config.berkshelf.enabled = true

  # force update of chef
  # first: vagrant plugin install vagrant-omnibus
  config.omnibus.chef_version = :latest
  #config.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | bash"

  # remove node and client when the vagrant box is destroyed
  # first: vagrant plugin install vagrant-butcher
  # NOTE: this will be outdated soon: https://github.com/cassianoleal/vagrant-butcher/issues/9
  #config.butcher.knife_config_file = './.chef/knife.rb'

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  config.vm.provision :chef_solo do |chef|

    chef.roles_path = "./roles"
    chef.data_bags_path = "./data_bags"
    chef.environments_path = "./environments"

    chef.node_name = "app0"
    chef.environment = "development"

    chef.add_role "chef-solo"
    chef.add_role "vagrant"
    chef.add_role "ubuntu"
    chef.add_role "base"
    chef.add_role "db_server"
    chef.add_role "web_server"

    chef.json = {
      :set_fqdn => "*.soupstraw.com"
    }

    # set by the berkshelf plugin:
    #chef.cookbooks_path = "./cookbooks"
  end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #config.vm.provision :chef_client do |chef|
  #  chef.chef_server_url = "https://api.opscode.com/organizations/soupstraw"
  #  chef.validation_key_path = "./.chef/soupstraw-validator.pem"
  #  chef.validation_client_name = "soupstraw-validator"
  #  #chef.environment = "development" # test me
  #  chef.node_name = "app0"
  #  chef.add_role "vagrant"
  #  chef.add_role "ubuntu"
  #  chef.add_role "base"
  #end
end
