begin
  require 'awesome_print'
rescue LoadError
  # no worries if not installed
end

# This file is loaded from ~/.pryrc, too.
if defined?(IRB)
  IRB.conf[:PROMPT_MODE] = :SIMPLE
  AwesomePrint.irb! if defined?(AwesomePrint)
end

REPL_MODEL_CACHE = Hash.new do |h, table|
  h[table] = Class.new(ActiveRecord::Base).tap { |m| m.table_name = table }
end

def model(table)
  REPL_MODEL_CACHE[table.to_sym]
end

def mgee
  @mgee ||= User.where(email: 'mgee@covermymeds.com').first
  @mgee ||= User.where(username: %w[mgee mgee_internal]).first
end

def pbcopy(str)
  IO.popen('pbcopy', 'w') { |pb| pb.write str }
end

def pbpaste
  IO.popen('pbpaste', 'r') { |pb| pb.read }
end
