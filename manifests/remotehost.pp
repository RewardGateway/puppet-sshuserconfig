define sshuserconfig::remotehost(
  $config_title         = $title,
  $remote_hostname      = undef,
  $remote_port          = '22',
  $remote_username      = undef,
  $ciphers              = undef,
  $macs                 = undef,
  $kex_algorithms       = undef,
  $connect_timeout      = undef,
  $identities_only      = 'yes',
  $unix_user,
  $ssh_config_dir       = undef,
  $ssh_config_file_name = 'config',
  $key_name             = $title,
  $private_key_content  = undef,
  $public_key_content   = undef,
) {

  if $identities_only != 'yes' and $identities_only != 'no' {
    fail "Expected 'yes' or 'no' \$identities_only, got '${identities_only}'"
  }

  if $ssh_config_dir == undef {
    if $unix_user == 'root' {
      $ssh_config_dir_prefix = "/root/.ssh"
    } else {
      $ssh_config_dir_prefix = "/home/${unix_user}/.ssh"
    }
  } else {
    $ssh_config_dir_prefix = $ssh_config_dir
  }
  debug "\$ssh_config_dir_prefix set to '${$ssh_config_dir_prefix}'"

  $ssh_config_file = "${ssh_config_dir_prefix}/${ssh_config_file_name}"
  debug "\$ssh_config_file set to '${ssh_config_file}'"

  $concat_namespace = "ssh_userconfig_${unix_user}"
  $fragment_name = "${concat_namespace}_${title}"

  if $private_key_content == undef {
    $synthesized_privkey_path = undef
  } else {
    $synthesized_privkey_path = "${ssh_config_dir_prefix}/id_rsa_${key_name}"

    file { $synthesized_privkey_path :
      ensure  => 'present',
      content => $private_key_content,
      owner   => $unix_user,
      mode    => '0600',
    }
  }

  if $public_key_content == undef {
    $synthesized_pubkey_path = undef
  } else {
    $synthesized_pubkey_path = "${ssh_config_dir_prefix}/id_rsa_${key_name}.pub"

    file { $synthesized_pubkey_path :
      ensure  => 'present',
      content => $public_key_content,
      owner   => $unix_user,
      mode    => '0600',
    }
  }

  ensure_resource(
    'concat',
    $ssh_config_file,
    {
      owner => $unix_user
    }
  )

  concat::fragment { $fragment_name :
    target  => $ssh_config_file,
    content => template('sshuserconfig/fragment.erb')
  }
}
