# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = 'digital_ocean'
  config.vm.box_url = "https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  config.ssh.private_key_path = ENV.fetch('SSH_PRIVATE_KEY_PATH', '~/.ssh/id_ed25519')
  
  config.vm.synced_folder "remote_files", "/minitwit", type: "rsync"
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.provision "file", source: "schema.sql", destination: "/minitwit/schema.sql"
  config.vm.provision "file", source: ".env", destination: "/minitwit/.env"

  config.vm.define "minitwit", primary: true do |server|
    server.vm.provider :digital_ocean do |provider|
      provider.ssh_key_name = ENV["SSH_KEY_NAME"]
      provider.token = ENV["DIGITAL_OCEAN_TOKEN"]
      provider.image = 'ubuntu-22-04-x64'
      provider.region = 'fra1'
      provider.size = 's-1vcpu-1gb'
    end

    server.vm.hostname = "minitwit"
    
    server.vm.provision "shell", inline: <<-SHELL

    sudo apt-get update

    # Replace keys
    rm -rf /root/.ssh/authorized_keys
    mv /minitwit/authorized_keys /root/.ssh/authorized_keys

    # The following address an issue in DO's Ubuntu images, which still contain a lock file
    sudo killall apt-get
    sudo rm /var/lib/dpkg/lock-frontend

    # Install docker and docker compose
    sudo apt-get install -y docker.io docker-compose-v2
    sudo systemctl status docker

    echo -e "\nOpening port for minitwit and SSH ...\n"
    ufw allow 4567 && \
    ufw allow 22/tcp

    echo ". $HOME/.bashrc" >> $HOME/.bash_profile

    echo -e "\nConfiguring credentials as environment variables...\n"

    source $HOME/.bash_profile

    echo -e "\nSelecting Minitwit Folder as default folder when you ssh into the server...\n"
    echo "cd /minitwit" >> ~/.bash_profile
    
    # INSTALL DOCTL
    sudo snap install doctl

    # Create missing folders
    sudo mkdir -p /root/.config /root/.docker

    # Allow doctl to connect to docker
    sudo snap connect doctl:dot-docker

    # 
    doctl auth init -t #{ENV['DIGITAL_OCEAN_TOKEN']}

    doctl registry login --never-expire

    # run the deploy.sh script
    cd /minitwit
    mkdir tmp
    sh deploy.sh


    echo "================================================================="
    echo "=                            DONE                               ="
    echo "================================================================="
    echo "Navigate in your browser to:"
    THIS_IP=`hostname -I | cut -d" " -f1`
    echo "http://${THIS_IP}:4567"
    SHELL
  end
end