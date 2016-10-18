require 'socket'

`cd $(dirname $0)`
log "DEBUG mode".red.bold if $options[:debug]

server = TCPServer.open($options[:port])
log "Server was created on port #{$options[:port]}"

Process.daemon if $options[:daemon]
`echo #{Process.pid} > /tmp/rubyserver.pid`
$Threads = []
loop do
    tid = Thread.start(server.accept) do |client|
        head = client.gets
        log head
        buffer = ""
        loop do
            begin
                buffer << client.read_nonblock(1)
            rescue Errno::EAGAIN => e
                # puts "#{e.message}"
                # puts "#{e.backtrace}"
                break
            rescue EOFError
                puts "EOF" if $debug
                break
            rescue
                puts "Error" if $debug
                break
            end
        end
        log "request start".bold if $options[:debug]
        client.write Request.new(head, buffer).response
        log "request end".bold if $options[:debug]
        client.close
    end
    $Threads << {:instance => tid, :time => Time.now}
end
