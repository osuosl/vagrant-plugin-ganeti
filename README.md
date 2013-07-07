# Vagrant Ganeti Provider
This is a Vagrant 1.2+ plugin that adds an Ganeti provider to Vagrant, allowing Vagrant to control and provision 
machines in Ganeti.

NOTE: This plugin requires Vagrant 1.2+,

## Installation

Build the Gem:

    $  gem build 'vagrant-plugin-ganeti.gemspec'



Install using standard Vagrant 1.1+ plugin installation methods. After installing, vagrant up and specify the ganeti provider. An example is shown below.

    $  vagrant plugin install vagrant-plugin-ganeti-0.0.1.gem

## Usage

    $ vagrant up --provider=ganeti
    ...
Of course prior to doing this, you'll need to obtain an Ganeti-compatible box file for Vagrant.


##Quick Start

After installing the plugin (instructions above), the quickest way to get started is to actually use a dummy Ganeti box and specify all the details manually within a config.vm.provider block. So first, add the dummy box using any name you want:

$ vagrant box add dummy https://github.com/osuosl/vagrant-plugin-ganeti/blob/master/example_box/dummy.box
...
And then make a Vagrantfile that looks like the following, filling in your information where necessary.

    Vagrant.configure("2") do |config|
      config.vm.box = "dummy"
      config.vm.provider :ganeti do |ganeti, override|
        ganeti.username = "#rapiuser"
        ganeti.password = "#password"
        ganeti.host = "https://10.10.10.10:5080/"
        ganeti.os_name = "image+debian-squeeze"
        ganeti.mode = "create"
        ganeti.instance_name = "gimager3.organisation.org"
        ganeti.pnode = "gnode.organisation.org"
        ganeti.nics = [{"ip"=>"10.10.10.100"}]
        ganeti.disks =[{"size"=>"8000"}] 
        ganeti.disk_template = "plain"
        override.ssh.username = "User name of the default user "
        override.ssh.private_key_path = "Path to your private key"
      end
    end


And then run vagrant up --provider=ganeti.

This will start an  instance in the Ganeti Cluster. And assuming your SSH information was filled in properly within your Vagrantfile, SSH and provisioning will work as well.

If you have issues with SSH connecting, make sure that the instances are being launched with a security group that allows SSH access.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
