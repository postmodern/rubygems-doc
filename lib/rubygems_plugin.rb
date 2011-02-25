require 'rubygems/command_manager'

if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.3.1')
  Gem::CommandManager.instance.register_command :doc
end
