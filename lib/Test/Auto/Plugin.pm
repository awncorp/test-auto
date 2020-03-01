package Test::Auto::Plugin;

use strict;
use warnings;

use Data::Object::Class;
use Data::Object::Attributes;

use registry 'Test::Auto::Types';
use routines;

# VERSION

# ATTRIBUTES

has subtests => (
  is => 'ro',
  isa => 'Subtests',
  req => 1
);

# METHODS

method tests(%args) {

  return $self;
}

1;
