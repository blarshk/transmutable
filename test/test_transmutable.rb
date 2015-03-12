require 'test_helper'

class TestTransmutable < MiniTest::Test
  def test_that_transmutable_exists
    assert_kind_of Module, Transmutable
  end

  def test_defines_serialize
    person = Person.new('Jeff')
    assert_equal({ name: 'Jeff' }, person.serialize)
  end

  def test_blank_model
    person = BlankPerson.new
    assert_equal({}, person.serialize)
  end

  def test_model_with_singular_relationships
    address = Address.new(
      street1: '123 Main Street',
      city: 'Ogden',
      state: 'UT',
      zip_code: '84052'
    )

    person = PersonWithAddress.new('Jeff', address)
    assert_equal({ 
      name: 'Jeff', 
      address: { 
        street1: '123 Main Street',
        city: 'Ogden',
        state: 'UT',
        zip_code: '84052' 
      } 
    }, person.serialize_with(:address))
  end

  def test_model_with_one_to_many_relationship
    phones = [
      Phone.new('801-111-1111'),
      Phone.new('801-111-1112')
    ]

    person = PersonWithPhones.new('Jeff', phones)
    assert_equal({
      name: 'Jeff',
      phones: [
        { number: '801-111-1111' },
        { number: '801-111-1112' }
      ]
    }, person.serialize_with(:phones))
  end

  def test_model_with_nested_relationships
    person = PersonWithThingsAndStuff.new('Jeff', Thing.new('baz', Stuff.new('bok')))
    assert_equal({
      name: 'Jeff',
      thing: {
        foo: 'baz',
        stuff: {
          bar: 'bok'
        }
      }
    }, person.serialize_with(thing: [ :stuff ]))
  end

  def test_replacing_the_base_transmuter
    person = PersonWithDifferentTransmuter.new('Jeff')
    assert_equal({
      lulz: 'dork'
    }, person.serialize)
  end

  def test_transmute_removal
    city = City.new('Ogden', :desert, 'This place is a toilet')
    assert_equal({
      name: 'Ogden',
      biome: :desert
    }, city.serialize)
  end

  def test_transmute_addition
    wallet = Wallet.new('Billy', Array.new(5, Dollar.new))

    assert_equal({
      name: 'Billy',
      total_value: 5,
      value_per_dollar: 1
    }, wallet.serialize)
  end

  def test_railsy_model_transmutation
    user = RailsyUser.new('Jeff')
    assert_equal({
      name: 'Jeff'
    }, user.serialize)
  end

  def test_legacy_attrs_support
    person = LegacyAttrsPerson.new('Jeff', 'I can get that for feel elsewhere')
    assert_equal({
      name: 'Jeff',
      catchphrase: 'I can get that for feel elsewhere'
    }, person.serialize)
  end
end