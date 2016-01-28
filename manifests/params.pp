class confd::params {
  $install_method  = 'http' # 'package' or 'http'
  $package_name    = 'confd'
  $confd_version   = '0.11.0'
  $config_path     = '/etc/confd/confd.toml'
  $resources_path  = '/etc/confd/conf.d'
  $templates_path  = '/etc/confd/templates'

  $backend         = 'etcd'
  $client_cakeys   = undef
  $client_cert     = undef
  $client_key      = undef
  $interval        = undef
  $log_level       = undef
  $nodes           = ['http://127.0.0.1:4001']
  $no_op           = undef
  $prefix          = undef
  $scheme          = 'http'
  $srv_domain      = undef
  $sync_only       = undef
  $watch           = undef

  $binary_base_url = "https://github.com/kelseyhightower/confd/releases/download/v${confd_version}/confd-${confd_version}"
  $binary_target   = '/usr/bin/confd'
}

