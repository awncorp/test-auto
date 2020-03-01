package Test::Auto;

use strict;
use warnings;

use Data::Object::Class;
use Data::Object::Attributes;
use Data::Object::Data;
use Data::Object::Try;

use Exporter;
use Test::More;
use Type::Registry;

use registry 'Test::Auto::Types';
use routines;

use base 'Exporter';

our @EXPORT = 'testauto';

# VERSION

# ATTRIBUTES

has file => (
  is => 'ro',
  isa => 'Str',
  req => 1
);

has data => (
  is => 'ro',
  isa => 'Data',
  opt => 1
);

# EXPORTS

fun testauto($file) {

  return Test::Auto->new($file)->subtests;
}

# BUILDS

method BUILD($args) {
  my $data = $self->data;
  my $file = $self->file;

  $self->{data} = Data::Object::Data->new(file => $file) if !$data;

  return $self;
}

around BUILDARGS(@args) {
  @args = (file => $args[0]) if @args == 1 && !ref $args[0];

  $self->$orig(@args);
}

# METHODS

method parser() {
  require Test::Auto::Parser;

  return Test::Auto::Parser->new(
    source => $self
  );
}

method document() {
  require Test::Auto::Document;

  return Test::Auto::Document->new(
    parser => $self->parser
  );
}

method subtests() {
  require Test::Auto::Subtests;

  return Test::Auto::Subtests->new(
    parser => $self->parser
  );
}

1;
