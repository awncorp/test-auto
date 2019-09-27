use 5.014;

use Do;
use Test::Auto;
use Test::More;

=name

Test::Auto::Document

=abstract

Documentation Generator

=includes

method: render

=synopsis

  package main;

  use Test::Auto;
  use Test::Auto::Parser;
  use Test::Auto::Document;

  my $test = Test::Auto->new(
    't/Test_Auto.t'
  );

  my $parser = Test::Auto::Parser->new(
    source => $test
  );

  my $doc = Test::Auto::Document->new(
    parser => $parser
  );

  # render documentation

  # $doc->render

=description

This package use the L<Test::Auto::Parser> object to generate a valid Perl 5
POD document.

=libraries

Data::Object::Library

=attributes

content: ro, opt, ArrayRef[Str]
template: ro, opt, Maybe[Str]
parser: ro, req, InstanceOf["Test::Auto::Parser"]

=method render

This method returns a string representation of a valid POD document. You can
also provide a template to wrap the generated document by passing it to the
constructor or specifying it in the C<TEST_AUTO_TEMPLATE> environment variable.

=signature render

render() : Str

=example-1 render

  # given: synopsis

  my $rendered = $doc->render;

=example-2 render

  # given: synopsis

  $ENV{TEST_AUTO_TEMPLATE} = './TEMPLATE';

  # where ./TEMPLATE has a {content} placeholder

  my $rendered = $doc->render;

  undef $ENV{TEST_AUTO_TEMPLATE};

  $rendered;

=example-3 render

  # given: synopsis

  my $tmpl = Test::Auto::Document->new(
    parser => $parser,
    template => './TEMPLATE'
  );

  my $rendered = $tmpl->render;

=cut

package main;

my $test = Test::Auto->new(__FILE__);

my $subs = $test->subtests->standard;

$subs->synopsis(fun($tryable) {
  ok my $result = $tryable->result, 'result ok';
  is ref($result), 'Test::Auto::Document', 'isa ok';

  $result;
});

$subs->example(-1, 'render', 'method', fun($tryable) {
  ok my $result = $tryable->result, 'result ok';
  like $result, qr/=head1 NAME/, 'has =head1 name';
  like $result, qr/=head1 ABSTRACT/, 'has =head1 abstract';
  like $result, qr/=head1 SYNOPSIS/, 'has =head1 synopsis';
  like $result, qr/=head1 DESCRIPTION/, 'has =head1 description';
  unlike $result, qr/=head1 AUTHOR/, 'no =head1 author';
  unlike $result, qr/=head1 LICENSE/, 'no =head1 license';

  $result;
});

$subs->example(-2, 'render', 'method', fun($tryable) {
  ok my $result = $tryable->result, 'result ok';
  like $result, qr/=head1 NAME/, 'has =head1 name';
  like $result, qr/=head1 ABSTRACT/, 'has =head1 abstract';
  like $result, qr/=head1 SYNOPSIS/, 'has =head1 synopsis';
  like $result, qr/=head1 DESCRIPTION/, 'has =head1 description';
  like $result, qr/=head1 AUTHOR/, 'no =head1 author';
  like $result, qr/=head1 LICENSE/, 'no =head1 license';

  $result;
});

$subs->example(-3, 'render', 'method', fun($tryable) {
  ok my $result = $tryable->result, 'result ok';
  like $result, qr/=head1 NAME/, 'has =head1 name';
  like $result, qr/=head1 ABSTRACT/, 'has =head1 abstract';
  like $result, qr/=head1 SYNOPSIS/, 'has =head1 synopsis';
  like $result, qr/=head1 DESCRIPTION/, 'has =head1 description';
  like $result, qr/=head1 AUTHOR/, 'has =head1 author';
  like $result, qr/=head1 LICENSE/, 'has =head1 license';

  $result;
});

ok 1 and done_testing;
