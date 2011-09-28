define network::bridge(
  $ensure = 'present',
  $interface = '',
  $vlan = '',
  $bridge_ip = $ipaddress,
  $bridge_netmask = $netmask
){
  require network::bridge-utils

 if $vlan == ''  {
  Network::Interface <| title == $interface |> {
    network => '0.0.0.0',
    netmask => '0.0.0.0',
    ipaddress => '0.0.0.0',
    broadcast => '0.0.0.0',
    ensure => up,
    bridge => $name,
  }
 }
 else {
  #warning("In vlan: $name if: $interface")
  Network::Vlan <| title == $interface |> {
    network => '0.0.0.0',
    netmask => '0.0.0.0',
    ipaddress => '0.0.0.0',
    broadcast => '0.0.0.0',
    ensure => up,
    bridge => $name,
  }
 }
 
  file { "/etc/sysconfig/network-scripts/ifcfg-$name":
    owner => root,
    group => root,
    mode => 600,
    content =>
      template("network/sysconfig/network-scripts/ifcfg.bridge.erb"),
    ensure => $ensure,
    alias => "ifcfg-$name"
  }

  case $ensure {
    present: {
      if $vlan == ''  {
        #warning("exec if: $name if: $interface")
       exec { "/sbin/ifdown $name; /sbin/ifup $name":
         subscribe => File["ifcfg-$name"],
         refreshonly => true,
         before => Network::Interface["$interface"],
       }
      } else {
        #warning("exec vlan: $name if: $interface")
       exec { "/sbin/ifdown $name; /sbin/ifup $name":
         subscribe => File["ifcfg-$name"],
         refreshonly => true,
         before => Network::Vlan["$interface"],
       }
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
