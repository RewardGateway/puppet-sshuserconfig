define sshuserconfig::remotehost(
  $remote_hostname,
  $remote_port = '22',
  $remote_username,
  $ciphers,
  $macs,
  $kex_algorithms,
  $connect_timeout,
  $identities_only = 'yes',
  $unix_user,
  $ssh_config_dir,
  $ssh_config_file_name = 'config',
  $private_key_content,
  $public_key_content,
) {

  if $unix_user == undef {
    fail "Expected a value for \$unix_user, got nothing"
  }

  if $identities_only != 'yes' && $identities_only != 'no' {
    fail "Expected 'yes' or 'no' \$identities_only, got '${identities_only}'"
  }

  if $ssh_config_dir == undef {
    if $ssh_config_dir == 'root' {
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

  $synthesized_privkey_path = "${ssh_config_dir_prefix}/id_rsa_${title}"
  $synthesized_pubkey_path = "${ssh_config_dir_prefix}/id_rsa_${title}.pub"

  file { $synthesized_privkey_path :
    ensure  => 'present',
    content => $private_key_content,
    owner   => $unix_user,
    mode    => '0600',
  }

  file { $synthesized_pubkey_path :
    ensure  => 'present',
    content => $public_key_content,
    owner   => $unix_user,
    mode    => '0600',
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
