# -*- mode: ruby -*-

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "vagrant-test-server" do |test_server|
    test_server.vm.box = "ubuntu/trusty64"
    test_server.vm.network "private_network", ip: "192.168.50.4"
  end
end
