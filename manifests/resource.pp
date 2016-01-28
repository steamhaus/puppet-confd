define confd::resource (
  $templ,
  $keys,
  $dest,

  $service_reload  = undef,
  $owner           = undef,
  $group           = undef,
  $mode            = undef,
  $check_cmd       = undef,
  $reload_cmd      = undef,
  $prefix          = undef,

  $confd_version   = $confd::params::confd_version,
  $resources_path  = $confd::params::resources_path,
  $templates_path  = $confd::params::templates_path,
) {
  include confd::params

  validate_string($templ)
  validte_hash($keys)
  validate_string($dest)
  
  if $owner { validate_string($owner) }
  if $group { validate_string($group) }
  if $mode  { validate_string($mode) }
  if $prefix { validate_string($prefix) }
  if $check_cmd  { validate_string($check_cmd) }
  if $reload_cmd { validate_string($reload_cmd) }

  $src = "${name}.tmpl"

  file { "${resources_path}/${name}.toml":
    ensure  => present,
    content => template("${module_name}/confd-resource.toml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  } ->

  file { "${templates_path}/${name}.tmpl":
    ensure  => present,
    content => "${templ}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  #if $service_reload {
  #  service { 'confd':
  #    subscribe => 
  #  }
  #}
}

