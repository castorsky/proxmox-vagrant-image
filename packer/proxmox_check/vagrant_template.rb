Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |v, override|
    v.memory = 4096
    v.cpus = 2
    v.nested = true
    v.channel :type => 'unix', :target_name => 'org.qemu.guest_agent.0', :target_type => 'virtio'
  end
end
