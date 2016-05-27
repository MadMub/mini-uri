$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mini_uri'

class Foo
  include MiniUri
  attr_accessor :id
end

class Bar
  include MiniUri
  attr_accessor :id
end
