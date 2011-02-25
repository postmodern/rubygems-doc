require 'rubygems/doc_manager'

module Gem
  module Doc
    class Manager < Gem::DocManager

      attr_reader :doc_dir

    end
  end
end
