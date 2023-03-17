require 'yaml'
require 'erb'
require 'configly/extensions/hash'

class Configly < Hash
  def []=(key, value)
    raise KeyError, "Reserved key: #{key}" if respond_to? key

    super key.to_sym, coerce_value(value)
  end

  def [](key)
    super key.to_sym
  end

  def <<(source)
    source = "#{source}.yml" unless /\.ya?ml$/.match?(source)
    content = File.read source
    content = YAML.load(ERB.new(content).result).to_configly

    merge! content if content
  end
  alias load <<

  def method_missing(method, *args)
    key = method
    string_key = key.to_s
    return self[key] if has_key? key

    suffix = nil

    if string_key.end_with?('=', '!', '?')
      suffix = string_key[-1]
      key = string_key[0..-2].to_sym
    end

    case suffix
    when '='
      val = args.first
      val = val.to_configly if val.is_a? Hash
      self[key] = val

    when '?'
      has_key?(key) && !(self[key].is_a?(Configly) && self[key].empty?)

    when '!'
      if has_key?(key) && !(self[key].is_a?(Configly) && self[key].empty?)
        self[key]
      end

    else
      self[key] = self.class.new

    end
  end

protected

  def coerce_value(value)
    case value
    when Hash then value.to_configly
    when Array then value.map { |v| coerce_value v }
    else
      value
    end
  end
end
