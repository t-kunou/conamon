require "conamon/version"
require "conamon/threading_macro"

class Proc
  attr_reader :binding_args

  def |(arg)
    @binding_args = @binding_args || []
    @binding_args << arg

    self
  end

  def &(arg)
    @binding_args = @binding_args || []
    @binding_args << BindMarker.new(arg)

    self
  end

  def bind(arguments = @binding_args)
    (arguments || []).inject(self) {|proc, arg|
      proc.curry[arg]
    }
  end

  def has_binding_args?
    !!@binding_args
  end
end

module Conamon
  include ThreadingMacro
end

