# -*- mode: ruby -*-
# vi: set ft=ruby :
# to use forwarded_port, serve jekyll with --host 0.0.0.0

Vagrant.configure("2") do |config|
  config.vm.box = "marii/wax"
  config.vm.box_version = "0.0.1"
  config.vm.network "forwarded_port", guest: 4000, host: 4000
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
    v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
  end
end
