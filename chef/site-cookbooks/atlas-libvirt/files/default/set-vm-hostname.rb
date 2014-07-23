#!/usr/bin/env ruby

require 'guestfs'

disk = ARGV[0]
name = ARGV[1]

g = Guestfs::Guestfs.new() 
g.add_drive_opts(disk) 
g.launch() 
roots = g.inspect_os() 
g.mount(roots[0], "/") 
g.write("/etc/hostname", name) 
g.write("/etc/salt/minion_id", name) 
g.umount("/") 
g.shutdown() 
g.close() 

