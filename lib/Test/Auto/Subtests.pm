package Test::Auto::Subtests;

use Data::Object 'Class';

use Type::Registry;
use Test::More;

# VERSION

has parser => (
  is => 'ro',
  isa => 'InstanceOf["Test::Auto::Parser"]',
  req => 1
);

# METHODS

method standard() {
  $self->package;
  $self->document;
  $self->libraries;
  $self->inherits;
  $self->attributes;
  $self->methods;
  $self->routines;
  $self->functions;

  return $self;
}

method package() {
  my $parser = $self->parser;

  subtest "testing package", fun () {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    use_ok $package;
  };
}

method libraries() {
  my $parser = $self->parser;

  subtest "testing libraries", fun () {
    my $packages = $parser->libraries
      or plan skip_all => "no libraries";

    map +(use_ok $_), @$packages;
  };
}

method inherits() {
  my $parser = $self->parser;

  subtest "testing inherited", fun () {
    my $inherited = $parser->inherits
      or plan skip_all => "no inherited";

    map +(use_ok $_), @$inherited;
  };
}

method document() {
  my $parser = $self->parser;

  subtest "testing document", fun () {
    ok $parser->render($_), "pod $_" for qw(
      name
      abstract
      synopsis
      abstract
      description
    );
  };
}

method attributes() {
  my $parser = $self->parser;

  subtest "testing attributes", fun () {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $attributes = $parser->stash('attributes');
    plan skip_all => 'no attributes' if !$attributes || !%$attributes;

    for my $name (sort keys %$attributes) {
      subtest "testing attribute $name", fun () {
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

method methods() {
  my $parser = $self->parser;

  subtest "testing methods", fun () {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $methods = $parser->methods;
    plan skip_all => 'no methods' if !$methods || !%$methods;

    for my $name (sort keys %$methods) {
      subtest "testing method $name", fun () {
        my $method = $methods->{$name};

        ok $package->can($name), 'can ok';
        ok $method->{usage}, 'pod description';
        ok $method->{signature}, 'pod signature';
        ok $method->{examples}{1}, 'pod example-1';
      };
    }
  };
}

method routines() {
  my $parser = $self->parser;

  subtest "testing routines", fun () {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $routines = $parser->routines;
    plan skip_all => 'no routines' if !$routines || !%$routines;

    for my $name (sort keys %$routines) {
      subtest "testing routine $name", fun () {
        my $routine = $routines->{$name};

        ok $package->can($name), 'can ok';
        ok $routine->{usage}, 'pod description';
        ok $routine->{signature}, 'pod signature';
        ok $routine->{examples}{1}, 'pod example-1';
      };
    }
  };
}

method functions() {
  my $parser = $self->parser;

  subtest "testing functions", fun () {
    my $package = $parser->render('name')
      or plan skip_all => "no package";

    my $functions = $parser->functions;
    plan skip_all => 'no functions' if !$functions || !%$functions;

    for my $name (sort keys %$functions) {
      subtest "testing function $name", fun () {
        my $function = $functions->{$name};

        ok $package->can($name), 'can ok';
        ok $function->{usage}, 'pod description';
        ok $function->{signature}, 'pod signature';
        ok $function->{examples}{1}, 'pod example-1';
      };
    }
  };
}

method synopsis($callback) {
  my $parser = $self->parser;

  my $context = $parser->render('synopsis');
  my $tryable = $self->tryable($context);

  subtest "testing synopsis", fun () {
    my @results = $callback->($tryable->call('evaluator'));

    ok scalar(@results), 'called ok';
  };
}

method scenario($name, $callback) {
  my $parser = $self->parser;

  my @results;

  my $example = $parser->scenarios($name, 'example');
  my @content = $example ? @{$example->[0]} : ();

  unshift @content,
    (map $parser->render($_),
      (map +(/# given:\s*(\w+)/g), @content));

  my $tryable = $self->tryable(join "\n", @content);

  subtest "testing scenario ($name)", fun () {
    unless (@content) {
      BAIL_OUT "unknown scenario $name";

      return;
    }
    @results = $callback->($tryable->call('evaluator'));

    ok scalar(@results), 'called ok';
  };
}

method example($number, $name, $type, $callback) {
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
    raise "$type is not a valid example type";
  }

  $number = abs $number;

  my $example = $context->{$number}[0] || [];
  my @content = @$example;

  unshift @content,
    (map $parser->render($_),
      (map +(/# given:\s*(\w+)/g), @content));

  my $tryable = $self->tryable(join "\n", @content);

  subtest "testing example-$number ($name)", fun () {
    unless (@content) {
      BAIL_OUT "unknown $type $name for example-$number";

      return;
    }
    @results = $callback->($tryable->call('evaluator'));

    ok scalar(@results), 'called ok';
  };

  subtest "testing example-$number ($name) results", fun () {
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

method evaluator($context) {
  local $@;

  my $returned = eval "$context";
  my $failures = $@;

  die $failures if $failures;

  return $returned;
}

method tryable(@passed) {
  my @arguments = (invocant => $self);

  push @arguments, arguments => [@passed] if @passed;

  return Data::Object::Try->new(@arguments);
}

method registry() {
  my $parser = $self->parser;
  my $libraries = $parser->libraries;

  $libraries = ['Types::Standard'] if !$libraries || !@$libraries;

  state $populate = 0;
  state $registry = Type::Registry->for_me;

  map $registry->add_types($_), @$libraries if !$populate++;

  return $registry;
}

1;
