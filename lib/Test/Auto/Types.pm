package Test::Auto::Types;

use strict;
use warnings;

use Type::Library -base;
use Type::Utils -all;

BEGIN {
  extends 'Types::Standard';
}

# VERSION

declare 'Data',
  as InstanceOf['Test::Auto::Data'];

declare 'Document',
  as InstanceOf['Test::Auto::Document'];

declare 'Parser',
  as InstanceOf['Test::Auto::Parser'];

declare 'Plugin',
  as InstanceOf['Test::Auto::Plugin'];

declare 'Source',
  as InstanceOf['Test::Auto'];

declare 'Strings',
  as ArrayRef[Str];

declare 'Subtests',
  as InstanceOf['Test::Auto::Subtests'];

1;
