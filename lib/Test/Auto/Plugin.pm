package Test::Auto::Plugin;

use strict;
use warnings;

use Moo;
use Test::Auto::Types ();

# VERSION

# ATTRIBUTES

has subtests => (
  is => 'ro',
  isa => Test::Auto::Types::Subtests(),
  required => 1
);

# METHODS

sub tests {
  my ($self, %args) = @_;

  return $self;
}

1;
