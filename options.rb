require 'optparse'

$options = {:port => 2000, :color => true}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-p", "--port [port=2000]", Integer, "server port") do |port|
      $options[:port] = port if port
  end

  opts.on("-d", "--[no-]daemon", "run server as daemon") do |dae|
      $options[:daemon] = dae
  end

  opts.on("-c", "--[no-]color", "show color output") do |color|
      $options[:color] = color
  end

  opts.on("-D", "--[no-]debug-mode", "open debug mode") do |debug|
      $options[:debug] = debug
  end

  opts.on("-l", "--logfile logfile", "set log file path") do |log|
      $options[:log] = log
  end

  opts.on("--javascript js", "add additional javascript file after webpage") do |js|
      $options[:javascript] = js
  end

  opts.on("--stylesheet css", "add additional stylesheet file after webpage") do |css|
      $options[:stylesheet] = css
  end
end.parse!

def log(l)
    STDOUT.puts l
end
