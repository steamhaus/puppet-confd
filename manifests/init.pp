# == Class: confd
#
# Installs and configure the Kelsey Hightower's confd daemon.
#
# === Parameters
#
# [*install_method*]
#   Either 'package' (install the package $package_name) or 'http'
#   (download the binary from Github ; only possible for Linux or
#   MacOS X, and only on x86_64 architectures).
#   Default 'http'.
#
# [*package_name*]
#   The name of the package to install. Only relevant when 
#   $install_mehod is 'package'.
#   Default 'confd'.
#
# [*confd_version*]
#   If $install_method is 'http', this specifies the confd version
#   to download from Github.
#   Default '0.11.0'.
#
# [*config_path*]
#   Path to the main confd config file.
#   Default '/etc/confd/confd.toml'.
#
# [*resources_path*]
#   Target directory for resources definitions.
#   Default '/etc/confd/conf.d'.
#
# [*templates_path*]
#   Target directory for templates.
#   Default '/etc/confd/templates'.
#
# [*backend*]
# [*client_cakeys*]
# [*client_cert*]
# [*client_key*]
# [*interval*]
# [*log_level*]
# [*nodes*]
# [*no_op*]
# [*prefix*]
# [*scheme*]
# [*srv_domain*]
# [*sync_only*]
# [*watch*]
#   Confd configuration parameters. For details see
#   https://github.com/kelseyhightower/confd/blob/master/docs/configuration-guide.md .
#   Nb: 'nodes' must be an array. 'no_op', 'sync_only' and 'watch' must be boolean
#   passed as trings ('true' or 'false').
#   All parameters are optionals.
#
# === Examples
#
#  class { confd:
#      backend  => 'etcd',
#      interval => 2,
#      nodes    => [ 'http://127.0.0.1:4001' ],
#  }
#
# === Authors
#
# Benjamin Pineau <ben.pineau@gmail.com>
#
# === Copyright
#
# Copyright 2016 - Apache License, Version 2.0
#
class confd (
  $install_method  = $confd::params::install_method,
  $package_name    = $confd::params::package_name,
  $confd_version   = $confd::params::confd_version,
  $config_path     = $confd::params::config_path,
  $resources_path  = $confd::params::resources_path,
  $templates_path  = $confd::params::templates_path,
  $binary_target   = $confd::params::binary_target,

  $backend         = $confd::params::backend,
  $client_cakeys   = $confd::params::client_cakeys,
  $client_cert     = $confd::params::client_cert,
  $client_key      = $confd::params::client_key,
  $interval        = $confd::params::interval,
  $log_level       = $confd::params::log_level,
  $nodes           = $confd::params::nodes,
  $no_op           = $confd::params::no_op,
  $prefix          = $confd::params::prefix,
  $scheme          = $confd::params::scheme,
  $srv_domain      = $confd::params::srv_domain,
  $sync_only       = $confd::params::sync_only,
  $watch           = $confd::params::watch,

) inherits confd::params {

  validate_re($install_method, [ '^package$', '^http$' ])
  validate_string($package_name)
  validate_absolute_path($config_path)
  validate_absolute_path($resources_path)
  validate_absolute_path($templates_path)
  if $backend { validate_string($backend) }
  if $client_cakeys { validate_absolute_path($client_cakeys) }
  if $client_cert { validate_absolute_path($client_cert) }
  if $client_key { validate_absolute_path($client_key) }
  if $interval { validate_integer($interval) }
  if $log_level { validate_string($log_level) }
  if $nodes { validate_array($nodes) }
  if $no_op { validate_re($no_op, ['^true$', '^false$' ]) }
  if $prefix { validate_string($prefix) }
  if $srv_domain { validate_string($srv_domain) }
  if $sync_only { validate_re($sync_only, ['^true$', '^false$' ]) }
  if $watch { validate_re($watch, ['^true$', '^false$' ]) }

  if $install_method == 'package' {
    ensure_packages([$package_name])
  }

  if $install_method == 'http' {
    case $::kernel {
      'Linux':  { 
        $host_os       = 'linux'
        $download_tool = 'wget --no-check-certificate -O'
      }
      'Darwin': {
         $host_os       = 'darwin'
         $download_tool = 'curl -L --insecure -o'
      }
      default: { fail("'${module_name}' don't know where to find confd binary for '$::kernel'") }
    }

    case $::architecture {
      'x86_64': { $arch = 'amd64' }
      default: { fail("'${module_name}' don't know where to find confd binary for '$::architecture'") }
    }

    $url = "${binary_base_url}-${host_os}-${arch}"

    exec { 'download_confd_binary':
      command => "${download_tool} ${binary_target} ${url} 2> /dev/null",
      creates => "${binary_target}",
      path    => '/usr/local/bin:/usr/bin:/bin',
      timeout => 300,
      notify  => Exec['set_confd_binary_mode'],
    }

    exec { 'set_confd_binary_mode':
      command     => "chmod 0755 ${binary_target}",
      path        => '/usr/local/bin:/usr/bin:/bin',
      refreshonly => true,
    }
  }

  $conf_dir = dirname("${config_path}")

  file { "${conf_dir}":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${resources_path}":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File["${conf_dir}"],
  }

  file { "${templates_path}":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File["${conf_dir}"],
  }

  file { "${config_path}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/confd.toml.erb"),
    require => File["${conf_dir}"],
  }

}

