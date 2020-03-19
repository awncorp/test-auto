package Test::Auto::Subtests;

use strict;
use warnings;

use feature 'state';

use Moo;
use Test::Auto::Try;
use Test::Auto::Types ();
use Test::More;
use Type::Registry;

require Carp;

# VERSION

# ATTRIBUTES

has parser => (
  is => 'ro',
  isa => Test::Auto::Types::Parser(),
  required => 1
);

# METHODS

sub standard {
  my ($self) = @_;

  $self->package;
  $self->document;
  $self->libraries;
  $self->inherits;
  $self->attributes;
  $self->methods;
  $self->routines;
  $self->functions;
  $self->types;

  return $self;
}

sub package {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing package", sub {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    require_ok $package; # use_ok can't test roles
  };
}

sub plugin {
  my ($self, $name) = @_;

  my $package = join '::', map ucfirst, (
    'test', 'auto', 'plugin', $name
  );

  subtest "testing plugin ($name)", sub {
    use_ok $package
      or plan skip_all => "$package not loaded";

    ok $package->isa('Test::Auto::Plugin'), 'isa Test::Auto::Plugin';
  };

  my $instance = $package->new(subtests => $self);

  return $instance;
}

sub libraries {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing libraries", sub {
    my $packages = $parser->libraries
      or plan skip_all => "no libraries";

    map +(use_ok $_), @$packages;
  };
}

sub inherits {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing inherited", sub {
    my $inherited = $parser->inherits
      or plan skip_all => "no inherited";

    map +(use_ok $_), @$inherited;
  };
}

sub document {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing document", sub {
    ok $parser->render($_), "pod $_" for qw(
      name
      abstract
      synopsis
      abstract
      description
    );
  };
}

sub attributes {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing attributes", sub {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $attributes = $parser->stash('attributes');
    plan skip_all => 'no attributes' if !$attributes || !%$attributes;

    for my $name (sort keys %$attributes) {
      subtest "testing attribute $name", sub {
        my $attribute = $attributes->{$name};

        ok $package->can($name), 'can ok';
        ok $attribute->{is}, 'has $is';
        ok $attribute->{presence}, 'has $presence';
        ok $attribute->{type}, 'has $type';

        my $registry = $self->registry;
        ok !!$registry->lookup($attribute->{type}), 'valid $type';
      };
    }
  };
}

sub methods {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing methods", sub {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $methods = $parser->methods;
    plan skip_all => 'no methods' if !$methods || !%$methods;

    for my $name (sort keys %$methods) {
      subtest "testing method $name", sub {
        my $method = $methods->{$name};

        ok $package->can($name), 'can ok';
        ok $method->{usage}, 'pod description';
        ok $method->{signature}, 'pod signature';
        ok $method->{examples}{1}, 'pod example-1';
      };
    }
  };
}

sub routines {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing routines", sub {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $routines = $parser->routines;
    plan skip_all => 'no routines' if !$routines || !%$routines;

    for my $name (sort keys %$routines) {
      subtest "testing routine $name", sub {
        my $routine = $routines->{$name};

        ok $package->can($name), 'can ok';
        ok $routine->{usage}, 'pod description';
        ok $routine->{signature}, 'pod signature';
        ok $routine->{examples}{1}, 'pod example-1';
      };
    }
  };
}

sub functions {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing functions", sub {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $functions = $parser->functions;
    plan skip_all => 'no functions' if !$functions || !%$functions;

    for my $name (sort keys %$functions) {
      subtest "testing function $name", sub {
        my $function = $functions->{$name};

        ok $package->can($name), 'can ok';
        ok $function->{usage}, 'pod description';
        ok $function->{signature}, 'pod signature';
        ok $function->{examples}{1}, 'pod example-1';
      };
    }
  };
}

sub types {
  my ($self) = @_;

  my $parser = $self->parser;

  subtest "testing types", sub {
    my $types = $parser->types;
    plan skip_all => 'no types' if !$types || !%$types;

    for my $name (sort keys %$types) {
      subtest "testing type $name", sub {
        my $type = $types->{$name};

        my $library = $type->{library}[0][0]
          or plan skip_all => "no library";

        use_ok $library;
        ok $library->isa('Type::Library'), 'isa Type::Library';

        my $constraint = $library->get_type($name);
        ok $constraint, 'has constraint';

        if ($constraint) {
          ok $constraint->isa('Type::Tiny'), 'isa Type::Tiny constraint';

          for my $number (sort keys %{$type->{examples}}) {
            my $example = $type->{examples}{$number};
            my $context = join "\n", @{$example->[0]};

            subtest "testing example-$number ($name)", sub {
              my $tryable = $self->tryable($context)->call('evaluator');
              my $result = $tryable->result;

              ok $constraint->check($result), 'passed constraint check';
            };
          }

          for my $number (sort keys %{$type->{coercions}}) {
            my $coercion = $type->{coercions}{$number};
            my $context = join "\n", @{$coercion->[0]};

            subtest "testing coercion-$number ($name)", sub {
              my $tryable = $self->tryable($context)->call('evaluator');
              my $result = $tryable->result;

              ok $constraint->check($constraint->coerce($result)),
                'passed constraint coercion';
            };
          }
        }
      };
    }
  };
}

sub synopsis {
  my ($self, $callback) = @_;

  my $parser = $self->parser;

  my $context = $parser->render('synopsis');
  my $tryable = $self->tryable($context);

  subtest "testing synopsis", sub {
    my @results = $callback->($tryable->call('evaluator'));

    ok scalar(@results), 'called ok';
  };
}

sub scenario {
  my ($self, $name, $callback) = @_;

  my $parser = $self->parser;

  my @results;

  my $example = $parser->scenarios($name, 'example');
  my @content = $example ? @{$example->[0]} : ();

  unshift @content,
    (map $parser->render(split /\s/),
      (map +(/# given:\s*([\w\s-]+)/g), @content));

  my $tryable = $self->tryable(join "\n", @content);

  subtest "testing scenario ($name)", sub {
    unless (@content) {
      BAIL_OUT "unknown scenario $name";

      return;
    }
    @results = $callback->($tryable->call('evaluator'));

    ok scalar(@results), 'called ok';
  };
}

sub example {
  my ($self, $number, $name, $type, $callback) = @_;

  my $parser = $self->parser;

  my $context;
  my $signature;
  my @results;

  if ($type eq 'method') {
    $context = $parser->methods($name, 'examples');
    $signature = $parser->methods($name, 'signature');
    $signature = join "\n", @{$signature->[0]} if $signature;
  }
  elsif ($type eq 'function') {
    $context = $parser->functions($name, 'examples');
    $signature = $parser->functions($name, 'signature');
    $signature = join "\n", @{$signature->[0]} if $signature;
  }
  elsif ($type eq 'routine') {
    $context = $parser->routines($name, 'examples');
    $signature = $parser->routines($name, 'signature');
    $signature = join "\n", @{$signature->[0]} if $signature;
  }
  else {
    Carp::confess "$type is not a valid example type";
  }

  $number = abs $number;

  my $example = $context->{$number}[0] || [];
  my @content = @$example;

  unshift @content,
    (map $parser->render($_),
      (map +(/# given:\s*(\w+)/g), @content));

  my $tryable = $self->tryable(join "\n", @content);

  subtest "testing example-$number ($name)", sub {
    unless (@content) {
      BAIL_OUT "unknown $type $name for example-$number";

      return;
    }
    @results = $callback->($tryable->call('evaluator'));

    ok scalar(@results), 'called ok';
  };

  subtest "testing example-$number ($name) results", sub {
    unless (@content) {
      BAIL_OUT "unknown $type $name for example-$number";

      return;
    }
    my ($input, $output) = $signature =~ /(.*) : (.*)/;

    my $registry = $self->registry;

    ok my $type = $registry->lookup($output), 'return type ok';

    map +(ok $type ? $type->check($_) : (), 'return value(s) ok'), @results;
  };
}

sub evaluator {
  my ($self, $context) = @_;

  local $@;

  my $returned = eval "$context";
  my $failures = $@;

  if ($failures) {
    Carp::confess $failures
  }

  return $returned;
}

sub tryable {
  my ($self, @passed) = @_;

  my @arguments = (invocant => $self);

  push @arguments, arguments => [@passed] if @passed;

  return Test::Auto::Try->new(@arguments);
}

sub registry {
  my ($self) = @_;

  my $parser = $self->parser;
  my $libraries = $parser->libraries;
  my $package = $parser->name;

  $libraries = ['Types::Standard'] if !$libraries || !@$libraries;

  state $populate = 0;
  state $registry = Type::Registry->for_class($package);

  map $registry->add_types($_), @$libraries if !$populate++;

  return $registry;
}

1;
