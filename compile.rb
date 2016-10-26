require 'WEBrick'
$Works = {}
class TeXify
    # constant

    @@texcompiler = ["xelatex","latex","tex","xetex","luatex"]

    def initialize(opt, file=nil)
        @RANDIR = (0...31).map { (65 + rand(26)).chr }.join
        @DIR = "/tmp/texify_#{@RANDIR}"
        @LOG = []
        @ADDFILETIME = 0
        @compiler = "xelatex"
        IO.popen(["mkdir", @DIR])
        setopts(opt)
        unless @multiple
            @LOG << {
                :name => "upload_mode",
                :text => "upload file by once"
            }
        else
            @LOG << {
                :name => "upload_mode",
                :text => "upload file by multiple"
            }
        end
        begin
            addfile(file)
        rescue Exception => e
            @LOG << {
                :name => "error",
                :text => e.to_s
            }
            errorpage
            return
        end
        run unless @multiple
    end

    def setopts(opt)
        @compiler = opt["compiler"] if @@texcompiler.index(opt["compiler"])
        @multiple = true if opt["multiple"] # multiple prop can only be set for the first time and readonly
        @main = opt["main"].gsub(/^.*\//,'') if opt["main"]
    end

    def addfile(file)
        unless @multiple
            # file type test
            type = ''
            IO.popen(["file", "-"], "r+") do |pipe|
                pipe.write file
                pipe.close_write
                type = pipe.read
            end
            raise "ERROR: file command error" if $?.exitstatus != 0

            mode = ''
            if (type =~ /Zip archive data/) || (type =~ /application\/zip/)
                mode = 'ZIP'
                @LOG << {
                    :name => "file_type",
                    :text => "ZIP archive provided"
                }
            else
                # tex source file
                mode = 'TEX'
                @LOG << {
                    :name => "file_type",
                    :text => "TeX source code provided"
                }
            end

            case mode
            when 'TEX'
                File.open("#{@DIR}/main.tex", "w") do |f|
                    f.write(file)
                end
                @directory = @DIR
                @sourcefile = "main.tex"
                @outputfile = "#{@DIR}/main.pdf"
            when 'ZIP'
                File.open("#{@DIR}/archive.zip", "w") do |f|
                    f.write(@FILES)
                end
                IO.popen(["mkdir", "#{@DIR}/files"])
                IO.popen(["unzip", "#{@DIR}/archive.zip", "-d", "#{@DIR}/files"], {:err => [:child, :out]}) do |pipe|
                    @LOG << {
                        :name => "unarchive",
                        :text => "unarchive program log: \n\n#{pipe.read}\n\n"
                    }
                end
                raise "ERROR: zip archive error" if $?.exitstatus != 0

                testreg = @main ? Regexp.new("^#{@main.gsub(".","\\.")}$") : /\.tex$/ # escape bug
                Dir.foreach("#{@DIR}/files") do |entry|
                    if entry =~ testreg
                        @sourcefile = entry
                        @directory = "#{@DIR}/files"
                        break
                    end
                    if File::directory?("#{@DIR}/files/#{entry}")
                        if (entry =~ /^[_\.]/) == nil
                            @directory = "#{@DIR}/files/#{entry}"
                            Dir.foreach(d) do |entry|
                                if entry =~ testreg
                                    @sourcefile = entry
                                    break
                                end
                            end
                        end
                    end
                end
                @outputfile = "#{@directory}/#{@sourcefile.gsub(/\.tex$/, '.pdf')}"

            end
        end
    end

    def continuous # return ID if the work is continuous
        @RANDIR if @multiple
    end

    def errorpage
        log "errorpage #{@LOG}" if $options[:debug]
        @TYPE = 'html'
        html = @LOG.map do |a|
            "<pre id='#{a[:name]}'>#{WEBrick::HTMLUtils.escape a[:text]}</pre>"
        end.join ''
        @output = Pages.log html
        log @output if $options[:debug]
        return @output
    end

    def run
        begin
            raise "no compiler chosen" unless @compiler
            raise "no texfile" unless @sourcefile
            IO.popen([
                "./run",
                @directory,
                @compiler,
                "-halt-on-error",
                @sourcefile]) do |pipe|
                @LOG << {
                    :name => "tex_log",
                    :text => "tex program log: \n\n#{pipe.read}"
                }
            end
            raise "TeXify error" if $?.exitstatus != 0
            File.open(@outputfile, "r") do |file|
                @output = file.read
            end
            @TYPE = 'pdf'
        rescue Exception => e
            @LOG << {
                :name => "error",
                :text => e.to_s
            }
            errorpage
            return
        end
    end

    def outtype
        @TYPE
    end

    def output
        @output
    end
end

def texify(opt, file)
    unless opt["id"]
        t = TeXify.new(opt, file)
        $Works[t.continuous] = t if t.continuous
        return t
    else
        if $Works[opt["id"]]
            t = $Works[opt["id"]]

            return t
        else
            return nil
        end
    end
end
