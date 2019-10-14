Configly - Minimal Settings Library
==================================================

[![Gem Version](https://badge.fury.io/rb/configly.svg)](https://badge.fury.io/rb/configly)

Configly is a lightweight ruby Hash object with dot notation access.

It is designed for loading and using YAML configuration files.

---

Installation
--------------------------------------------------

    $ gem install configly


Usage
--------------------------------------------------

### Initialization

Initialize a Configly object from Hash:

```ruby
# Initialize from hash
require 'configly'
hash = {server: {host: 'localhost', port: 3000}}
configly = hash.to_configly
```

or by loading one or more YAML files:

```ruby
# Initialize by merging in YAML files
config = Configly.new
config << 'spec/fixtures/settings.yml'
puts config.imported.settings.also
#=> work
```

You can append additional YAML files by using either `#<<` or `#load`. 
The '.yml' extension is optional.

In addition, you may load YAML files to nested keys:

```ruby
# Loading nested YAMLs
config = Configly.new
config << 'spec/fixtures/settings'

p config.imported.settings
#=> {:also=>"work"}

config.nested.settings.load 'spec/fixtures/settings'

p config.nested.settings
#=> {:imported=>{:settings=>{:also=>"work"}}}
```

Configly objects inherit from Hash:

```ruby
puts configly.is_a? Configly  #=> true
puts configly.is_a? Hash      #=> true
```

### Dot notation read access

Read values using dot notation:

```ruby
# Dot notation access
puts configly.server.host
#=> localhost
```

Reading nonexistent deep values will not raise an error:

```ruby
# Deep dot notation access
p configly.some.deeply.nested_value
#=> {}
```

To check if a key exists, use `?`

```ruby
# Check if a key exists
p configly.some.deeply.nested_value?
#=> false

p configly.server.port?
#=> true
```

To get the value or `nil` if it does not exist, use `!`:


```ruby
# Get value or nil
p configly.some.deeply.nested_value!
#=> nil

p configly.server.port!
#=> 3000
```


### Dot notation write access

Writing values is just as easy:

```ruby
# Dot notation write access
configly.production.server.port = 4000
puts configly.production.server.port
#=> 4000
```

Arrays with hashes as values, will also work (as the nested hashes will be
coerced into Configly objects):

```ruby
# Arrays of hashes
configly.servers = [
  { host: 'prod1.example.com', port: 3000 },
  { host: 'prod2.example.com', port: 4000 },
]

puts configly.servers.first.host
#=> prod1.example.com

puts configly.servers.first.is_a? Configly
#=> true
```

### Array-like access

Configly allows read/write access using the usual array/hash syntax `#[]` using
either a string a symbol key:

```ruby
# Array access
puts configly.server.port     #=> 3000
puts configly.server[:port]   #=> 3000
puts configly.server['port']  #=> 3000

configly.server[:port] = 4000
puts configly.server.port     #=> 4000
```


Limitations
--------------------------------------------------

Due to the fact that Configly is inheriting from Hash, and using 
`method_missing` to allow dot notation access, your settings hashes cannot
use keys that are defined as methods in the Hash object. 

When this case is identified, a `KeyError` will be raised.

```ruby
# Reserved keys
configly.api.key = '53cr3t'
#=> #<KeyError: Reserved key: key>
```

