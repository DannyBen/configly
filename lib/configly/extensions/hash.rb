class Hash
  def to_configly
    return self if self.is_a? Configly

    configly = Configly.new
    each { |key, val| configly[key] = val }
    configly
  end
end
