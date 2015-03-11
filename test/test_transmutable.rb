require 'test_helper'
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

class TestTransmutable < MiniTest::Test
  def test_that_transmutable_exists
    assert_kind_of Module, Transmutable
  end

  def test_defines_serialize
    person = Person.new('Jeff')
    assert_equal person.serialize, { name: 'Jeff' }
  end

  def test_blank_model
    person = BlankPerson.new
    assert_equal person.serialize, { }
  end

  def test_model_with_singular_relationships
    address = Address.new(
      street1: '123 Main Street',
      city: 'Ogden',
      state: 'UT',
      zip_code: '84052'
    )

    person = PersonWithAddress.new('Jeff', address)
    assert_equal person.serialize_with(:address), { 
      name: 'Jeff', 
      address: { 
        street1: '123 Main Street',
        city: 'Ogden',
        state: 'UT',
        zip_code: '84052' 
      } 
    }
  end

  def test_model_with_one_to_many_relationship
    phones = [
      Phone.new('801-111-1111'),
      Phone.new('801-111-1112')
    ]

    person = PersonWithPhones.new('Jeff', phones)
    assert_equal person.serialize_with(:phones), {
      name: 'Jeff',
      phones: [
        { number: '801-111-1111' },
        { number: '801-111-1112' }
      ]
    }
  end

  def test_model_with_nested_relationships
    person = PersonWithThingsAndStuff.new('Jeff', Thing.new('baz', Stuff.new('bok')))
    assert_equal person.serialize_with(thing: [ :stuff ]), {
      name: 'Jeff',
      thing: {
        foo: 'baz',
        stuff: {
          bar: 'bok'
        }
      }
    }
  end

  def test_replacing_the_base_transmuter
    person = PersonWithDifferentTransmuter.new('Jeff')
    assert_equal person.serialize, {
      lulz: 'dork'
    }
  end

  def test_transmute_removal
    city = City.new('Ogden', :desert, 'This place is a toilet')
    assert_equal city.serialize, {
      name: 'Ogden',
      biome: :desert
    }
  end

  def test_transmute_addition
    wallet = Wallet.new('Billy', Array.new(5, Dollar.new))

    assert_equal wallet.serialize, {
      name: 'Billy',
      total_value: 5,
      value_per_dollar: 1
    }
  end
end