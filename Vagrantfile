VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  config.vm.box = "vincent-box"
  config.vm.box_url = "http://cotocisternas.cl/files/vagrant/veewee/vincent-box.box"
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
  end

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "768"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on", "--natdnshostresolver1", "on"]
  end

  config.vm.define "puppet" do |master|
    master.vm.hostname = "puppet.petabyte.cl"
    master.vm.network :private_network, ip: "172.16.210.10"
    master.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "1536"]
    end
    master.vm.provision :shell, :path => "master_conf/puppet_master.sh"
    master.vm.provision :shell, :path => "master_conf/puppet_r10k.sh"
    master.vm.provision :puppet do |puppet|
      puppet.manifests_path = "master_conf/manifests"
      puppet.manifest_file  = "default.pp"
      puppet.options        = "--verbose --debug --modulepath /home/vagrant/modules"
    end
    master.vm.synced_folder "puppet/manifests", "/etc/puppet/manifests"
    master.vm.synced_folder "puppet/modules", "/etc/puppet/modules"
    master.vm.synced_folder "puppet/hieradata", "/etc/puppet/hieradata"
  end

  nodes = {
    :node01 => {:domain => 'petabyte.cl', :ip => '172.16.210.20'}
  }

  nodes.each do |name, options|
    config.vm.define name do |node|
      if options[:box] && options[:box_url]
        node.vm.box = options[:box]
        node.vm.box_url = options[:bor_url]
      end
      node.vm.provision :shell, :inline => "echo '172.16.210.10   puppet.petabyte.cl  puppet' >> /etc/hosts"
      node.vm.provision :shell, :inline => "sed -i '/templatedir/d' /etc/puppet/puppet.conf"
      node.vm.provision "puppet_server" do |puppet|
        puppet.puppet_server = "puppet.petabyte.cl"
        puppet.options = "--verbose --debug"
      end
      node.vm.hostname = "#{name}.#{options[:domain]}"
      node.vm.network :private_network, ip: options[:ip]
      node.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--memory", options[:mem]] if options[:mem]
        v.customize ["modifyvm", :id, "--cpus", options[:cpu]] if options[:cpu]
      end
    end
  end
end