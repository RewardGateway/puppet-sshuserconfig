# This manifest is the entry point for `rake test:integration`.
# Use it to set up integration tests for this Puppet module.

# Test the module
sshuserconfig::remotehost { 'someidentifier' :
  remote_hostname     => 'github.com',
  remote_username     => 'git',
  unix_user           => 'vagrant',
  private_key_content => "some vagrant privkey content\n",
  public_key_content  => "some vagrant pubkey content\n",
  ssh_config_dir      => '/tmp'
}

sshuserconfig::remotehost { 'someidentifier2' :
  remote_hostname     => 'github.com',
  remote_username     => 'git',
  unix_user           => 'vagrant',
  private_key_content => "some vagrant privkey content2\n",
  public_key_content  => "some vagrant pubkey content2\n",
  ssh_config_dir      => '/tmp',
  connect_timeout     => 10
}

sshuserconfig::remotehost { 'someidentifier3 someidentifier4' :
  remote_hostname      => 'bitbucket.org',
  remote_port          => '2222',
  remote_username      => 'git',
  ciphers              => 'aes256-ctr',
  macs                 => 'hmac-sha2-512',
  kex_algorithms       => 'diffie-hellman-group14-sha1',
  connect_timeout      => 10
  identities_only      => 'no'
  unix_user            => 'root',
  ssh_config_file_name => 'unsual_config'
  private_key_content  => "some root privkey content\n",
  public_key_content   => "some root pubkey content\n",
}
