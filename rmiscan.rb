#!/usr/bin/env jruby
# emonti@matasano.com 2008
# Ghetto RMI port scanner. 
# Takes a host and either range or list of ports as arguments.
# Attempts to do an registry endpoint listing for any port that looks like RMI

include Java
import java.rmi.Naming

require 'socket'
require 'fcntl'
require 'optparse'

OPTS={ :wait_sec => 1 }

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename $0} [options] address [ports ...]"
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit 1
  end

  opts.on("-p", "--ports=PORTRANGE", "Specify a port range as nnn-NNN") do |p|
    unless (m=/^(\d+)-(\d+)$/.match(p)) and (p1=m[1].to_i) <= (p2=m[2].to_i)
      raise "Invalid port range. Use 'n-N'"
    end
    OPTS[:scanports] = (p1..p2)
  end
  opts.on("-t", "--timeout=N", Numeric, 
          "Response Timeout (Default: #{OPTS[:wait_sec]}) ") do |t|
    OPTS[:wait_sec] = t
  end
end

# Get args
begin
  opts.parse!(ARGV)
  unless (host = ARGV.shift)
    raise opts.banner
  end

  unless OPTS[:scanports]
    if not (bad=ARGV.grep(/[^0-9]/)).empty?
      raise "Invalid port specified: #{bad.join(', ')}"
    end
    OPTS[:scanports] = ARGV.map {|n| n.to_i}
  end
rescue
  STDERR.puts $!
  exit 1
end

OPTS[:scanports].each do |port|
  hit=nil
  # first check for RMI using a minimal handshake check
  begin
    next unless (cli = TCPSocket.new(host, port))
    cli.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK)
    cli.write("JRMI\x00\x02\x4b")

    r,w,e = IO.select([cli], nil, nil, OPTS[:wait_sec])
    unless r
      cli.close
      next
    end

    resp = cli.read(3)
    msg, len = resp.unpack("cn")

    unless msg == 0x4e
      cli.close
      next
    end

    rest = cli.read(len+4)
    cli.close

    if rest.size == len+4
      puts "** Found a possible RMI endpoint at //#{host}:#{port}"
      hit=true
    else
      next
    end

  rescue Errno::ECONNREFUSED
    # nop
  rescue
    STDERR.puts "Port #{port} Err: #{$!}"
  ensure
    cli.close if cli and not cli.closed?
  end

  next unless hit

  # If we've found an RMI service, check if it is a registry
  # rescue with 'next' if an exception is raised
  rmi = Naming.list("//#{host}:#{port}") rescue (next)

  puts "** Found RMI Registry at: //#{host}:#{port} (Listing Interfaces)"
  rmi.each {|x| puts "  " + x}
  puts
end

