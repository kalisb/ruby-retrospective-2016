class CommandParser
  def initialize(command_name)
    @command_name = command_name
    @arguments = []
    @options = []
  end

  def argument(argument_name, &block)
    @arguments << Argument.new(argument_name, &block)
  end

  def option(*arguments, &block)
    @options << Option.new(*arguments, &block)
  end

  def option_with_parameter(*arguments, &block)
    @options << OptionWithParameter.new(*arguments, &block)
  end

  def parse(command_runner, argv)
    options = argv.select { |arg| arg.start_with?("-") }
    arguments = argv - options

    options.each do |option| 
      collect_known(option).each do |known_opt|
        known_opt.handle(command_runner, option)
      end
    end

    @arguments.each_with_index do |argument, index|
      argument.handle(command_runner, arguments[index])
    end
  end

  def collect_known(send_option)
    @options.select do |option| 
      send_option =~ /^(#{option.short_name}|#{option.long_name})/
    end
  end

  def help
    banner = "Usage: #{@command_name} "
    @arguments.each { |argument| banner << argument.text }
    banner.strip + generate_help_body
  end

  def generate_help_body
    body = ""
    @options.each do |option|
      body << option.text  
    end
    body = "\n" + body unless body == ""
    body
  end
end

class Argument
  attr_accessor :name, :action

  def initialize(name, &block)
    @name = name
    @action = block
  end

  def handle(command_runner, argument) 
    action.call(command_runner, argument)
  end

  def text
    "[#{@name}] "
  end
end

class Option
  attr_accessor :short_name, :long_name, :help, :action
  
  def initialize(short_name, long_name, help, &block)
    @short_name = "-#{short_name}" 
    @long_name = "--#{long_name}"
    @help = help
    @action = block
  end

  def handle(command_runner, _)
    action.call(command_runner, true)
  end

  def text
    "    #{@short_name}, #{@long_name} #{@help}\n"
  end
end

class OptionWithParameter < Option
  attr_accessor :parameter

  def initialize(short_name, long_name, help, parameter, &block)
    super(short_name, long_name, help, &block)
    @parameter = parameter
  end

  def handle(command_runner, option)
    option = option.sub!(/^(#{@short_name}|#{@long_name}=)/, "")
    action.call(command_runner, option)
  end

  def text
    "    #{@short_name}, #{@long_name}=#{@parameter} #{@help}\n" 
  end
end
