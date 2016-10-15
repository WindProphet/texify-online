#!/usr/bin/env ruby

require 'socket'                # Get sockets from stdlib
require './texify'

`cat /tmp/rubyserver.pid && kill $(cat /tmp/rubyserver.pid) || echo 0`
`echo #{Process.pid} > /tmp/rubyserver.pid`
puts Process.pid



server = TCPServer.open(2000)   # Socket to listen on port 2000
loop do                         # Servers run forever
    Thread.start(server.accept) do |client|
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
                puts "EOF"
                break
            end
        end
        puts head
        if head =~ /^POST/
            t = buffer.split(/\r\n\r\n/,2)
            # `echo "#{t[1]}" > ~/hello.tmp`
            # puts buffer
            # boundary = "--" + t[0][/^Content-Type: multipart\/form-data;.*$/][/(?<=boundary=).*$/]
            boundary = t[1][/^----.*(?=\r\n)/]
            pieces = t[1].split(boundary)
            # puts boundary
            opt = ""
            file = ""
            pieces.each do |item|
                if item[/Content-Disposition:.*$/]
                    if item[/Content-Disposition:.*$/] =~ /name=\"opt\"/
                        opt = item.lstrip.split(/\r\n\r\n/,2)[1]
                    elsif item[/Content-Disposition:.*$/] =~ /name=\"file\"/
                        file = item.lstrip.split(/\r\n\r\n/,2)[1]
                    end
                end
            end
        
            # texify
            begin
                t = Texify.new(file,nil,opt)
                t.gets
                client.write "HTTP/1.1 201 OK\r\n" \
                             "Content-Type: application/pdf\r\n\r\n" \
                             "#{t.output}"
            rescue Exception => e
                client.write "HTTP/1.1 200 OK\r\n" \
                             "Content-Type: text/html\r\n" \
                             """
                             <meta charset='UTF-8'>
                             <title>TeXify Online</title>
                             <h1>TeXify Error</h1>
                             <p>#{e}</p>
                             <pre>#{t.log}</pre>
                             """
            end
            # client.write "HTTP/1.1 404 OK\r\n"
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
    end
end