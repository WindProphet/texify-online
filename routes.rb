require 'uri'
class Request

    def head_proc(h)
        log "head_proc" if $options[:debug]
        ans = {}
        h.split(/\r\n|\r/).each do |a|
            b = a.split(':',2)
            ans[b[0]] = b[1].lstrip
        end
        ans
    end

    def form_post
        log "form_post" if $options[:debug]
        boundary = @content[/^----.*(?=\r\n)/]
        pieces = @content.split(boundary)
        opt = ""
        file = ""
        pieces.each do |item|
            if item[/Content-Disposition:.*$/]
                if item[/Content-Disposition:.*$/] =~ /name=\"opt\"/
                    opt = item.lstrip.split(/\r\n\r\n/,2)[1]
                elsif item[/Content-Disposition:.*$/] =~ /name=\"file\"/
                    file = item.lstrip.split(/\r\n\r\n/,2)[1] if item.lstrip.split(/\r\n\r\n/,2)[1]
                end
            end
        end
        @file = file
        o = head_proc opt
        o = o.merge @query
        {:opt => o, :file => file}
    end

    def operate
        case @method
        when 'POST'
            opt = form_post
            log opt if $options[:debug]
            t = texify(opt, @file)
            unless t
                @type = 'html'
                @status = "403 Forbidden"
                @return = Pages.reject
                return
            end
            @type = t.outtype
            @return = t.output
        when 'GET'
            if @url == '/'
                @return = Pages.mainpage
            end
        end
    end

    def initialize(h,b)
        he = h.split(' ')
        @method = he[0]
        @url = he[1].gsub(/\?.*$/,'')
        @query = {}
        he[1][/(?<=\?).*$/].split('&').each do |a|
            t = a.split('=',2)
            t[1] = "" unless t[1]
            @query[URI::unescape t[0]] = URI::unescape t[1]
        end if he[1][/(?<=\?).*$/]
        log "#{@query}" if $options[:debug]
        c = b.split(/\r\n\r\n/,2)
        @head = head_proc c[0]
        @content = ''
        @content = c[1] if c[1]
        @status = 200
        @type = 'html'
        @return = ''
    end

    def response
        operate
        log "response #{@url}" if $options[:debug]
        if @status.to_s =~ /^20\d$/
            res = "HTTP/1.1 #{@status} OK\r\n"
            case @type
            when 'html'
                res << "Content-Type: text/html; charset=utf-8\r\n"
            when 'pdf'
                res << "Content-Type: application/pdf\r\n"
            end
            res <<  "Cache-Control: no-cache, no-store, must-revalidate\r\n" \
                    "Pragma: no-cache\r\n" \
                    "Expires: 0\r\n" if @nocache
        else
            res = "HTTP/1.1 #{@status}\r\n"
        end
        res << "\r\n"
        res << @return
    end
end
