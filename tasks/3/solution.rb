class CommandParser
  def initialize(command_name)
    @command_name = command_name
    @argument_map = {}
    @option_map = {}
  end

  def argument(argument_name, &block)
    @argument_map[argument_name] = block
  end

  def option(*option_name, &block)
    option_name[0] = '-' + option_name[0] 
    option_name[1] = '--' + option_name[1] 
    @option_map[option_name] = block
  end

  def option_with_parameter(*option_name, &block)
    option(*option_name, &block)
  end

  def parse(command_runner, argv)
    options = argv.select { |arg| arg.start_with?("-", "--") }
    arguments = argv.reject { |arg| options.include?(arg) }
    parse_options(command_runner, options)
    @argument_map.each_with_index do |(_, block), index|
      block.call(command_runner, arguments[index])
    end
  end

  def parse_options(command_runner, options)
    @option_map.each do |(opt, block)|
      if (options.include? opt[0]) || (options.include? opt[1])
        block.call(command_runner, true)
      else
        parse_option_parameter(command_runner, options, opt, block)
      end
    end 
  end

  def parse_option_parameter(command_runner, options, opt, block)
    options.select { |option| option =~ /^(#{opt[0]}|#{opt[1]}=)/ }
      .map do |option|
        option.sub!(/^(#{opt[0]}|#{opt[1]}=)/, "")
        block.call(command_runner, option)  
      end
  end

  def help
    banner = "Usage: #{@command_name} "
    @argument_map.each { |key, _| banner << "[#{key}] " }
    banner.strip + generate_help_body
  end

  def generate_help_body
    body = ""
    @option_map.each do |key, _|
      body << "\n    #{key[0]}, #{key[1]}=#{key[3]} #{key[2]}" if key[3] 
      body << "\n    #{key[0]}, #{key[1]} #{key[2]}" unless key[3] 
    end
    body
  end
end
