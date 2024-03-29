#Quick Manifest to stand up a demo Puppet Master

node default {
  
  host { 'puppet.petabyte.cl':
    ensure       => 'present',
    host_aliases => ['puppet'],
    ip           => '172.16.210.10',
    target       => '/etc/hosts',
  }

  
  package {'puppetmaster':
    ensure  =>  latest,
    require => Host['puppet.petabyte.cl'],
  }
    
  # Configure puppetdb and its underlying database
  class { 'puppetdb': 
    listen_address => '0.0.0.0',
    require => Package['puppetmaster'],
    puppetdb_version => latest,
    }
  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config': }
    
  class {'dashboard':
    dashboard_site    => $fqdn,
    dashboard_port    => '3000',
    require           => Package["puppetmaster"],
  }
 
  ##we copy rather than symlinking as puppet will manage this
  file {'/etc/puppet/puppet.conf':
    ensure => present,
    owner => root,
    group => root,
    source => "/vagrant/puppet/puppet.conf",
    notify  =>  [Service['puppetmaster'],Service['puppet-dashboard']],
    require => Package['puppetmaster'],
  }
    
  file {'/etc/puppet/autosign.conf':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/autosign.conf",
    notify  =>  [Service['puppetmaster'],Service['puppet-dashboard']],
    require => Package['puppetmaster'],
  }
  
  file {'/etc/puppet/auth.conf':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/auth.conf",
    notify  =>  [Service['puppetmaster'],Service['puppet-dashboard']],
    require => Package['puppetmaster'],
  }
  
  file {'/etc/puppet/fileserver.conf':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/fileserver.conf",
    notify  =>  [Service['puppetmaster'],Service['puppet-dashboard']],
    require => Package['puppetmaster'],
  }
  
  file {'/etc/puppet/modules':
    mode  => '0644',
    recurse => true,
  }
  
  file { '/etc/puppet/hiera.yaml':
    ensure => link,
    owner => root,
    group => root,
    source => "/vagrant/puppet/hiera.yaml",
    notify  =>  [Service['puppetmaster'],Service['puppet-dashboard']],
  }
  
  file { '/etc/puppet/hieradata':
    mode => '0644',
    recurse => true,
  }
    
}
