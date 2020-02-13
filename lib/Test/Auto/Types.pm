package Test::Auto::Types;

use Data::Object 'Library';

# VERSION

declare 'Parser',
  as InstanceOf['Test::Auto::Parser'];

declare 'Source',
  as InstanceOf['Test::Auto'];

declare 'Strings',
  as ArrayRef[Str];

declare 'Subtests',
  as InstanceOf['Test::Auto::Subtests'];

1;
