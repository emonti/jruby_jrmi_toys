#!/usr/bin/env jruby
# emonti@matasano.com - 2008
#
# This script will attempt to enumerate RMI interfaces and their exposed 
# methods using JRuby.
#
# The script takes one argument, which is the URL for a remote RMI registry.
# Example:
#
# rmiquery.rb //127.0.0.1:1099
#
# Method names and prototypes are only available if RMI application stubs are 
# included. You can include them by dropping their JAR or class files into 
# the same directory that you run this script from and they will be 
# automatically loaded.
#
# For info on RMI:
#
# java.rmi.Naming @
# http://java.sun.com/j2se/1.5/docs/api/java/rmi/Naming.html
#
# java.rmi.registry.LocateRegistry @
# http://java.sun.com/j2se/1.5/docs/api/java/rmi/registry/LocateRegistry.html

include Java
import java.rmi.Naming

require 'pp'

unless (regurl = ARGV[0]) 
  STDERR.puts "need a rmiregistry url i.e. //127.0.0.1:1099"
  exit 1
end

# load all jar files in the current dir
Dir.foreach(".") do |x| 
  if x =~ /\.jar$/
    STDERR.puts "Importing #{x}"
    require x
  end
end

STDERR.puts
registry = Naming.lookup(regurl)
registry.list.each do |remote_name| 
  puts "RMI Interface Found: #{remote_name}"
  begin
    remote = registry.lookup(remote_name)
    puts "  #{remote}"
    remote.java_class.declared_instance_methods.each do |meth|
      puts "    #{meth.to_s}"
    end
  rescue
    puts "     **ERROR** #{$!}"
  end
  puts
end
