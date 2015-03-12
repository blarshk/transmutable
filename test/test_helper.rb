require 'minitest/autorun'
require 'transmutable'

class Person
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  include Transmutable
end

class Address
  attr_accessor :street1, :city, :state, :zip_code

  def initialize(opts)
    @street1 = opts[:street1]
    @city = opts[:city]
    @state = opts[:state]
    @zip_code = opts[:zip_code]
  end

  include Transmutable
end

class BlankPerson
  include Transmutable
end

class PersonWithAddress
  attr_accessor :name, :address

  def initialize(name, address)
    @name = name
    @address = address
  end

  include Transmutable
end

class Phone
  include Transmutable
  attr_accessor :number

  def initialize(number)
    @number = number
  end
end

class PersonWithPhones
  include Transmutable

  attr_accessor :name, :phones

  def initialize(name, phones)
    @name = name
    @phones = phones
  end
end

class PersonWithThingsAndStuff
  include Transmutable

  attr_accessor :name, :thing

  def initialize(name, thing)
    @name = name
    @thing = thing
  end
end

class Thing
  include Transmutable

  attr_accessor :foo, :stuff

  def initialize(foo, stuff)
    @foo = foo
    @stuff = stuff
  end
end

class Stuff
  include Transmutable

  attr_accessor :bar

  def initialize(bar)
    @bar = bar
  end
end

class TrollTransmuter < Transmutable::Base
  def transmute
    {lulz: 'dork'}
  end
end

class PersonWithDifferentTransmuter < Person
  transmuter TrollTransmuter
end

class CityTransmuter < Transmutable::Base
  remove_from_transmute :secret_data
end

class City
  include Transmutable

  transmuter CityTransmuter

  attr_accessor :name, :biome, :secret_data

  def initialize(name, biome, secret_data)
    @name = name
    @biome = biome
    @secret_data = secret_data
  end
end

class WalletTransmuter < Transmutable::Base
  remove_from_transmute :dollars
  add_to_transmute :total_value, :value_per_dollar
end

class Wallet
  include Transmutable

  transmuter WalletTransmuter

  attr_accessor :name, :dollars

  def initialize(name, dollars)
    @name = name
    @dollars = dollars
  end

  def total_value
    dollars.map(&:value).reduce(&:+)
  end

  def value_per_dollar
    total_value / dollars.size
  end
end

class Dollar
  def value
    1
  end
end

class RailsyUser
  include Transmutable

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def attributes
    {
      name: name
    }
  end

  def instance_variables
    []
  end
end

class LegacyAttrsPersonTransmuter < Transmutable::Base
  serialize_attrs :name, :catchphrase
end

class LegacyAttrsPerson
  include Transmutable

  transmuter LegacyAttrsPersonTransmuter

  attr_accessor :name, :catchphrase

  def initialize(name, catchphrase)
    @name = name
    @catchphrase = catchphrase
  end
end