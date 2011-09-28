define network::vlan(
  $ensure = 'present',
  $interface,
  $ipaddress = "",
  $netmask = "",
  $network = "",
  $broadcast = "",
  $mtu = "",
  $bridge = ""
){
  require network::vlan-utils

  Network::Interface <| title == $interface |> {
    network => '0.0.0.0',
    netmask => '0.0.0.0',
    ipaddress => '0.0.0.0',
    broadcast => '0.0.0.0',
    ensure => up,
  }
  
  file { "/etc/sysconfig/network-scripts/ifcfg-$name":
    owner => root,
    group => root,
    mode => 600,
    content =>
      template("network/sysconfig/network-scripts/ifcfg.vlan.erb"),
    ensure => $ensure,
    alias => "ifcfg-$name"
  }

  case $ensure {
    present: {
      exec { "/sbin/ifdown $name; /sbin/ifup $name":
        subscribe => File["ifcfg-$name"],
        refreshonly => true,
        before => Network::Interface["$interface"],
      }
    }
    absent: {
      exec { "/sbin/ifdown $name":
        before => File["ifcfg-$name"],
        onlyif => "/sbin/ifconfig $name"
      }
    }
  }
}
