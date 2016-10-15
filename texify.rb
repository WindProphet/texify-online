#!/usr/bin/env ruby

class Texify
    def initialize(file=nil, type=nil, opt=nil)
        @RANDIR = (0...31).map { (65 + rand(26)).chr }.join
        @DIR = "/tmp/texify_#{@RANDIR}"
        @FILES = file if file
        @TYPE = type if type
        @OPTS = opt if opt
        # puts @FILES
    end
    
    def file(f)
        @FILES = f
    end
    
    def type(t)
        @TYPE = t
    end
    
    def opt(o)
        @OPTS = o
    end
    
    private def file_type
        IO.popen(["file", "-"], "r+") do |pipe|
            pipe.write @FILES
            pipe.close_write
            @TYPE = pipe.read
        end
        raise  "file command error" if $?.exitstatus != 0
    end
    
    private def type_tex
        Dir.chdir "#{@DIR}" do
            File.open("main.tex", "w") do |file|
                file.write(@FILES)
            end
            IO.popen([
                "xelatex",
                "-halt-on-error",
                "main.tex"]) do |pipe|
                @TEXLOG = pipe.read
            end
            raise "TeXify error" if $?.exitstatus != 0
        end
        @OUT = "#{@DIR}/main.pdf"
    end
    
    private def type_zip
        File.open("#{@DIR}/archive.zip", "w") do |file|
            file.write(@FILES)
        end
        IO.popen(["unzip", "#{@DIR}/archive.zip", "-d", "#{@DIR}/archive"]) do |pipe|
            @ZIPLOG = pipe.read
        end
        raise "zip archive error" if $?.exitstatus != 0
        x = "" # texfile name
        d = "" # directory name
        Dir.foreach("#{@DIR}/archive") do |entry|
            if entry =~ /\.tex$/
                x = entry
                d = "#{@DIR}/archive"
            end
            if File::directory?("#{@DIR}/archive/#{entry}")
                if (entry =~ /^[_\.]/) == nil
                    d = "#{@DIR}/archive/#{entry}"
                    Dir.foreach(d) do |entry|
                        if entry =~ /\.tex$/
                            x = entry
                        end
                    end
                end
            end
        end

        
        raise 'No TeX file found in zip pack' if x.empty?
        
        Dir.chdir d do
            IO.popen([
                "xelatex",
                "-halt-on-error",
                x]) do |pipe|
                @TEXLOG = pipe.read
            end
            raise "TeXify error" if $?.exitstatus != 0
        end
        @OUT = "#{d}/#{x.gsub(/\.tex$/, '.pdf')}"
    end
    
    def gets
        raise 'No file input' unless @FILES
        file_type unless @TYPE
        `mkdir #{@DIR}`
        # `open #{@DIR}`
        if @TYPE =~ /Zip archive data/
            @MODE = 'ZIP'
            type_zip
        elsif @TYPE =~ /application\/zip/
            @MODE = 'ZIP'
            type_zip
        else
            # tex source file
            @MODE = 'TEX'
            type_tex
        end
        File.open(@OUT, "r") do |file|
            @OUTPUT = file.read
        end
        `rm -rf #{@DIR}` # del tmpfile
        @OUTPUT
    end
    
    def log
        return @TEXLOG if @TEXLOG
        return @ZIPLOG if @ZIPLOG
    end
    
    def mode
        @MODE
    end
    
    def output
        @OUTPUT
    end
end
