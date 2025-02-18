# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = 'digital_ocean'
  config.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  config.ssh.private_key_path = '~/.ssh/id_ed25519'
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".env.example", ".git", ".gitignore"]

  config.vm.define "itu-minitwit", primary: false do |server|
    server.vm.provider :digital_ocean do |provider|
      provider.ssh_key_name = ENV["SSH_KEY_NAME"]
      provider.token = ENV["DIGITAL_OCEAN_TOKEN"]
      provider.image = 'ubuntu-22-04-x64'
      provider.region = 'fra1'
      provider.size = 's-1vcpu-1gb'
      provider.privatenetworking = true
    end

    server.vm.hostname = "itu-minitwit"

    server.vm.provision "shell", inline: <<-SHELL
      apt install -y curl gpg
      gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

      echo "Installing Ruby 3.3.7..."
      curl -sSL https://get.rvm.io | bash -s stable
      source /usr/local/rvm/scripts/rvm || source /etc/profile.d/rvm.sh
      rvm install 3.3.7

      cd /vagrant/
      
      echo "Installing bundle packages..."
      bundle install

      echo "Initializing db..."
      ./control.sh init

      echo "Starting application..."
      ruby ./minitwit.rb > ./tmp/out.log &
      echo "================================================================="
      echo "=                            DONE                               ="
      echo "================================================================="
      echo "Navigate in your browser to:"
      THIS_IP=`hostname -I | cut -d" " -f1`
      echo "http://${THIS_IP}:4567"
    SHELL
  end
end