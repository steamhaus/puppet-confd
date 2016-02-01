# == Define: confd::resource
#
#  This define allows you to create or remove a confd resource.
#
# === Parameters
#
# [*templ*]
#    String. The confd template file.
#    Mandatory parameter (no defaults).
#
# [*keys*]
#    String. The keys to watch for (in etcd, or consuld etc).
#    Mandatory parameter (no defaults).
#
# [*dest*]
#    String. Path to the generated file.
#    Mandatory parameter (no defaults).
# 
# [*service_reload*]
#    Bool. Wether to reload or not the 'confd' service after a config
#    or template change. Default 'false'.

# [*owner*]
#    String. Owner of the generated file. Default 'undef'.
#
# [*group*]
#    String. Owner group of the generated file. Default 'undef'.
#
# [*mode*]
#    String. Mode of the generated file. Default 'undef'.
#
# [*check_cmd*]
#    String. Command to validate the generated file after changes. Default 'undef'.
#
# [*reload_cmd*]
#    String. Command to launch after the target is re-generated. Default 'undef'.
#
# [*prefix*]
#    String. The string to prefix to keys.
#
# [*resources_path*]
#    String. Where to place resources toml configs. Default '/etc/confd/conf.d'.
#
# [*templates_path*]
#    String. Where to place resources' templates. Default '/etc/confd/templates'.
#    
define confd::resource (
  $templ,
  $keys,
  $dest,

  $service_reload  = false,
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
  validate_array($keys)
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
    source  => "${templ}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if str2boool($service_reload) {
    service { 'confd':
      subscribe => [
          File["${templates_path}/${name}.tmpl"],
          File["${resources_path}/${name}.toml"],
      ]
    }
  }
}

