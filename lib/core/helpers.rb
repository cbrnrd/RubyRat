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
        #t.add_row ['build_client', 'Build an executable of the client (EXPERIMANTAL)']
        t << :separator
        t.add_row ['Client Actions', '']
        #t.add_row ['execute <command>', 'Execute the given command on the client']
        t.add_row ['sysinfo', 'Gather information about the client']
        t.add_row ['getpid', 'Show the sessions current pid']
        t.add_row ['wget <url>', 'Download a remote file on the client']
        t.add_row ['ifconfig', 'View network interface information']
        t.add_row ['pwd', 'Show the currend directory on the client']
        #t.add_row ['scan <host>', 'Perform a port scan on a host on the client network']
      end
    end

    def self.prompt(*args)
        print(*args)
        STDIN.gets
    end

  end
end
