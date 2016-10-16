#!/usr/bin/env ruby

require 'socket'                # Get sockets from stdlib

`cd $(dirname $0)`
`cat /tmp/rubyserver.pid && kill $(cat /tmp/rubyserver.pid) || echo 0`
`echo #{Process.pid} > /tmp/rubyserver.pid`
# puts Process.pid

$port = ARGV[0] || 2000

$debug = ARGV[1]
$ids = 0
puts "DEBUG mode" if $debug

server = TCPServer.open($port)   # Socket to listen on port 2000
loop do                         # Servers run forever
    Thread.start(server.accept) do |client|
        id = $ids += 1
        puts "Thread: #{id}" if $debug
        head = client.gets
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
            end
        end
        puts head
        puts buffer if $debug
        if head =~ /^POST/
            t = buffer.split(/\r\n\r\n/,2)
            boundary = t[1][/^----.*(?=\r\n)/]
            pieces = t[1].split(boundary)
            opt = ""
            file = ""
            ret = ""
            pieces.each do |item|
                if item[/Content-Disposition:.*$/]
                    if item[/Content-Disposition:.*$/] =~ /name=\"opt\"/
                        opt = item.lstrip.split(/\r\n\r\n/,2)[1]
                    elsif item[/Content-Disposition:.*$/] =~ /name=\"file\"/
                        file = item.lstrip.split(/\r\n\r\n/,2)[1]
                    end
                end
            end

            puts "FILE: --" if $debug
            puts file if $debug
            # texify
            IO.popen(['./texify.rb', opt], 'r+') do |pipe|
                pipe.write file
                pipe.close_write
                ret = pipe.read
            end
            ex = $?.exitstatus
            if ex == 0
                puts "success" if $debug
                client.write "HTTP/1.1 201 OK\r\n" \
                             "Content-Type: application/pdf\r\n" \
                             "Cache-Control: no-cache, no-store, must-revalidate\r\n" \
                             "Pragma: no-cache\r\n" \
                             "Expires: 0\r\n" \
                             "\r\n#{ret}"
            else
                puts "error and info" if $debug
                client.write "HTTP/1.1 200 OK\r\n" \
                             "Content-Type: text/html\r\n" \
                             "Cache-Control: no-cache, no-store, must-revalidate\r\n" \
                             "Pragma: no-cache\r\n" \
                             "Expires: 0\r\n" \
                             """
                             <meta charset='UTF-8'>
                             <title>TeXify Online</title>
                             <h1>TeXify Error</h1>
                             <pre>#{ret}</pre>
                             """
            end

            puts "end post" if $debug
        else
            client.write "HTTP/1.1 200 OK\r\n" \
                         "Content-Type: text/html; charset=utf-8\r\n\r\n" \
            """
            <meta charset='UTF-8'>
            <title>TeXify Online</title>
            <h1>TeXify Online</h1>
            Some Description here.
            <form method='post' enctype='multipart/form-data' action='#'>
                <input name='file' type='file'>
                <input name='opt' type='text'>
                <input type='submit' value='Submit'>
            </form>
            """
        end
        client.close                # Disconnect from the client
        puts "Thread: #{id} END" if $debug
    end
end
