requires "Moo" => "2.003006";
requires "Try::Tiny" => "0.30";
requires "Type::Tiny" => "1.010001";
requires "perl" => "v5.14.0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Moo" => "2.003006";
  requires "Try::Tiny" => "0.30";
  requires "Type::Tiny" => "1.010001";
  requires "perl" => "v5.14.0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};
