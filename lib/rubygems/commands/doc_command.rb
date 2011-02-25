require 'rubygems/command'
require 'rubygems/doc/manager'

require 'launchy'

class Gem::Commands::DocCommand < Gem::Command

  def initialize
    defaults = {
      :version => Gem::Requirement.default,
      :remote => false
    }

    super('doc','Generate documentation for a Gem',defaults)

    add_option(
      :Options,
      '-v', '--version',
      'Specify the version of the gem'
    ) { |value,options| options[:version] = value }

    add_option(
      :Options,
      '-r', '--remote',
      'Display remote documentation'
    ) { |value,options| options[:remote] = true }
  end

  def arguments
    "GEMNAME       name of gem to generate documentation for"
  end

  def defaults_str # :nodoc:
    "--version '#{Gem::Requirement.default}'"
  end

  def description
%{
Generates documentation for an installed gem and displays the documentation
in the current browser.
}
  end

  def usage
    "#{program_name} GEMNAME [GEMNAME ...] [options]"
  end

  def execute
    exit_code = 0

    get_all_gem_names.each do |gem_name|
      dep = Gem::Dependency.new(gem_name,options[:version])
      spec = Gem.source_index.search(dep).last

      unless spec
        alert_error "Could not find #{gem_name} #{options[:version]}"
        exit_code |= 1
        next
      end

      doc_manager = Gem::Doc::Manager.new(spec)
      ri_dir = File.join(doc_manager.doc_dir,'ri')

      unless File.directory?(ri_dir)
        # generate RI / YRI documentation
        doc_manager.generate_ri
        doc_manager.class.update_ri_cache
      end

      rdoc_dir = File.join(doc_manager.doc_dir,'rdoc')

      unless File.directory?(rdoc_dir)
        # generate RDoc / YARD documentation
        doc_manager.generate_rdoc
      end

      index = Dir[File.join(rdoc_dir,'index.{x,}htm{l,}')].first

      if index
        Launchy.open("file://#{index}")
      else
        alert_error "Could not find documentation in #{doc_root}"
        exit_code |= 1
      end
    end

    raise(Gem::SystemExitException,exit_code)
  end

end
