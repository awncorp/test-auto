package Test::Auto::Plugin;

use Data::Object::Class;
use Data::Object::ClassHas;
use Data::Object::Signatures;

# VERSION

# ATTRIBUTES

has subtests => (
  is => 'ro',
  isa => 'InstanceOf["Test::Auto::Subtests"]',
  req => 1
);

# METHODS

method tests(%args) {

  return $self;
}

1;
