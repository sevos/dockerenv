# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu-docker"
  config.vm.box_url = "http://nitron-vagrant.s3-website-us-east-1.amazonaws.com/vagrant_ubuntu_12.04.3_amd64_virtualbox.box"

  config.vm.network :forwarded_port, guest: 4243, host: 4243
  config.vm.network :forwarded_port, guest: 5000, host: 5000
  config.vm.network :forwarded_port, guest: 5432, host: 25432

  (49000..49900).each do |port|
    config.vm.network :forwarded_port, :host => port + 10_000, :guest => port
  end

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  config.vm.network "private_network", ip: "192.168.50.4"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  ['apps', 'backup'].each do |folder|
    config.vm.synced_folder folder, "/media/#{folder}"#, nfs: true, mount_options: ['nolock,vers=3,udp']
  end
  config.vm.synced_folder '~', '/media/home'

  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    # vb.gui = true

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  config.vm.provision "shell", inline: <<-SCRIPT
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
    sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
    apt-get update
    apt-get install -y lxc-docker
    echo 'DOCKER_OPTS="-H 0.0.0.0:4243 -H unix:///var/run/docker.sock -d"' >> /etc/default/docker
    service docker restart
    #wget -O /usr/local/bin/shipyard-agent https://github.com/shipyard/shipyard-agent/releases/download/v0.1.1/shipyard-agent
    #chmod +x /usr/local/bin/shipyard-agent
  SCRIPT
end
