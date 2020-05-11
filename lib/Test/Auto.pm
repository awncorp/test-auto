# ABSTRACT: Test Automation, Docs Generation
package Test::Auto;

use strict;
use warnings;

use Moo;

use Exporter;
use Test::Auto::Data;
use Test::Auto::Try;
use Test::Auto::Types ();
use Test::More;
use Type::Registry;

use base 'Exporter';

our @EXPORT = 'testauto';

# VERSION

# ATTRIBUTES

has file => (
  is => 'ro',
  isa => Test::Auto::Types::Str(),
  required => 1
);

has data => (
  is => 'ro',
  isa => Test::Auto::Types::Data(),
  required => 0
);

# EXPORTS

sub testauto {
  my ($file) = @_;

  return Test::Auto->new($file)->subtests;
}

# BUILDS

sub BUILD {
  my ($self, $args) = @_;

  my $data = $self->data;
  my $file = $self->file;

  $self->{data} = Test::Auto::Data->new(file => $file) if !$data;

  return $self;
}

around BUILDARGS => sub {
  my ($orig, $self, @args) = @_;

  @args = (file => $args[0]) if @args == 1 && !ref $args[0];

  $self->$orig(@args);
};

# METHODS

sub parser {
  my ($self) = @_;

  require Test::Auto::Parser;

  return Test::Auto::Parser->new(
    source => $self
  );
}

sub document {
  my ($self) = @_;

  require Test::Auto::Document;

  return Test::Auto::Document->new(
    parser => $self->parser
  );
}

sub subtests {
  my ($self) = @_;

  require Test::Auto::Subtests;

  return Test::Auto::Subtests->new(
    parser => $self->parser
  );
}

1;
