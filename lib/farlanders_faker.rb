$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'extensions/array'

module FarlandersFaker
  VERSION = '0.0.1'
  
  @@default_locale = :en
  @@name_faker = nil
  
  class << self
    # Return the current default locale. Defaults to :en
    def default_locale
      @@default_locale
    end
    
    # Return the current locale
    def locale
      defined?(I18n) ? I18n.locale : default_locale
    end
    
    # Sets the current locale
    def locale=(locale)
      @@default_locale = locale
    end
    
    # Return the current name faker
    def name_faker
      @@name_faker ||= FarlandersFaker::Name.new
    end
    
    # Generate a faked name with current local
    def name
      name_faker.name(locale)
    end
  end
  
  class Name
    
    def names
      @names ||= {}
    end
    
    def init_names
      Dir[File.dirname(__FILE__) + "/locale_names/*.yml"].each do |filename|
        load_yml(filename)
      end
      @initialized = true
    end
    
    # Loads a YAML names file. the data must have locales as
    # toplevel keys.
    def load_yml(filename)
      require 'yaml' unless defined? YAML
      data = YAML::load(IO.read(filename))
      data.each {|locale, d| merge_names(locale, d)}
    end
    
    def init_names?
      @initialized ||= false
    end
    
    # Deep merges the given name hash with the existing names
    # for the given locale
    def merge_names(locale, data)
      locale = locale.to_sym
      names[locale] ||= {}
      data = deep_symbolize_keys(data)
      
      # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      names[locale].merge!(data, &merger)
    end
    
    # Returns an array of locales for which names are available
    def available_locales
      init_names unless init_names?
      names.keys
    end
    
    def default_locale
      init_names unless init_names?
      FarlandersFaker.default_locale
    end
    
    def name(locale)
      init_names unless init_names?
      locale = locale.to_sym
      locale = default_locale unless available_locales.include?(locale)
      
      format.rand.map do |key|
        names[locale][key].rand
      end.join(' ').strip
    end
    
    def format
      [
        [:prefix, :first_name, :last_name],
        [:first_name, :last_name, :suffix],
        [:first_name, :last_name],
        [:first_name, :last_name],
        [:first_name, :last_name],
        [:first_name, :last_name],
        [:first_name, :last_name],
        [:first_name, :last_name],
        [:first_name, :last_name],
        [:first_name, :last_name]
      ]
    end
    
    # Return a new hash with all keys and nested keys converted to symbols.
    def deep_symbolize_keys(hash)
      hash.inject({}) { |result, (key, value)|
        value = deep_symbolize_keys(value) if value.is_a? Hash
        result[(key.to_sym rescue key) || key] = value
        result
      }
    end
  end
end