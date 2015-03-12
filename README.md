# Transmutable: Configurable Object Conversion

Transmutable is a great little way to simplify object conversion when rendering an object to a hash or JSON. It allows for serialization of individual objects, or objects with an association (like ActiveRecord relationships, or simple object attributes).

### How to Use It

First, install the gem!

```bash
gem install transmutable
```

Then, require the gem and include the Transmutable module in your model!

Transmutable will delegate the serialization of your Ruby objects to a Transmuter object. Transmutable::Base, the default transmuter, will pull all of the instance variable primitives off of your object and push them into a hash.

```ruby
require 'transmutable'

class Person
  attr_accessor :name, :email, :favorite_color

  include Transmutable

  # ...
end

person = Person.new(
  name: 'Jeffrey', 
  email: 'jeff@test.com', 
  favorite_color: 'Uhhh...'
)

person.serialize #=> { name: 'Jeffery', email: 'jeff@test.com', favorite_color: 'Uhh...' }
```

### Serializing Records with Associations

Any associated models that respond to serialize (through the Transmutable module or otherwise) can be serialized along with the original record by using serialize_with.

```ruby
class Person
  include Transmutable

  attr_accessor :name, :email, :favorite_color, :address
end

class Address
  include Transmutable

  attr_accessor :street, :city, :state, :zip_code
end

address = Address.new(
  street: '123 Main Street', 
  city: 'Ogden', 
  state: 'UT', 
  zip_code: 84055
)

person = Person.new(
  name: 'Jeffrey', 
  email: 'jeff@test.com', 
  favorite_color: 'Uhhh...', 
  address: address
)

person.serialize_with(:address) #=> { name: 'Jeffery', email: 'jeff@test.com', favorite_color: 'Uhh...', address: { street: '123 Main Street', city: 'Ogden', state: 'UT', zip_code: 84055 }}
```

This also works with nested associations or one-to-many relationships. As long as the model on the other side of the method responds to serialize, you're good!

```ruby
class Person
  include Transmutable

  attr_accessor :name, :email, :catchphrases
end

class Catchphrase
  include Transmutable

  attr_accessor :priority, :body
end

catchphrases = [ 
  Catchphrase.new(
    priority: 1, 
    body: 'Just roll with it!'
  ), 
  Catchphrase.new(
    priority: 2, 
    body: 'GET HYPED'
  ) 
]

person = Person.new(
  name: 'Jeffrey', 
  email: 'jeff@test.com', 
  catchphrases: catchphrases
)

person.serialize_with(:catchphrases) #=> { name: 'Jeffrey', email: 'jeff@test.com', catchphrases: [{ priority: 1, body: 'Just roll with it!' }, { priority: 2, body: 'Just roll with it!' }]}
```

### Using Custom Transmuters

You can swap out the default transmuter with your own transmuter object if you so desire! In these custom objects, you can define whether you'd like to skip some attributes or add additional properties (like computed properties or instance methods).

```ruby
class PersonTransmuter < Transmutable::Base
  add_to_transmute :first_name, :last_name
  remove_from_transmute :name, :favorite_color
end

class Person
  transmuter PersonTransmuter

  def first_name
    name.split[0]
  end

  def last_name
    name.split[1]
  end
end

person = Person.new(
  name: 'Jeffrey Throwup', 
  email: 'jeff@test.com', 
  favorite_color: 'Uhhh...'
)

person.serialize #=> { first_name: 'Jeffrey', last_name: 'Throwup', email: 'jeff@test.com' }
```

You can also define your own objects without inheriting from Transmutable::Base or using the Transmutable DSL. All you need to do is allow your object to initialize with the object being serialized, and define a transmute method!

```ruby
class MyPersonTransmuter
  attr_accessor :person

  def initialize(person)
    @person = person
  end

  def transmute
    { 
      name: person.name,
      fun_fact: 'Probably has a dog'
    }
  end
end
```