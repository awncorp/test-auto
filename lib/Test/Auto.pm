package Test::Auto;

use Data::Object 'Class';

use Data::Object::Data;
use Data::Object::Try;

use Type::Registry;
use Test::More;

# VERSION

has file => (
  is => 'ro',
  isa => 'Str',
  req => 1
);

has data => (
  is => 'ro',
  isa => 'DataObject',
  opt => 1
);

# BUILD

method BUILD($args) {
  my $data = $self->data;
  my $file = $self->file;

  # build data-model from podish
  $self->{data} = Data::Object::Data->new(file => $file) if !$data;

  return $self;
}

around BUILDARGS(@args) {
  # convert single args to proper pair
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
