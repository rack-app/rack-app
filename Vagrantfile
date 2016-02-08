# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.provision "shell", inline: "sudo apt-get install -y curl"
  config.vm.provision "shell", inline: '\curl -sSL https://get.rvm.io | bash'
  config.vm.provision "shell", inline: 'rvm install 1.8'
  config.vm.provision "shell", inline: 'rvm install 1.9'

end
