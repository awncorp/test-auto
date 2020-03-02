requires "Data::Object::Attributes" => "0.04";
requires "Data::Object::Class" => "2.02";
requires "Data::Object::Data" => "2.00";
requires "Data::Object::Role::Stashable" => "2.01";
requires "Data::Object::Try" => "2.01";
requires "Type::Tiny" => "1.010000";
requires "perl" => "v5.14.0";
requires "routines" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Data::Object::Attributes" => "0.04";
  requires "Data::Object::Class" => "2.02";
  requires "Data::Object::Data" => "2.00";
  requires "Data::Object::Role::Stashable" => "2.01";
  requires "Data::Object::Try" => "2.01";
  requires "Type::Tiny" => "1.010000";
  requires "perl" => "v5.14.0";
  requires "routines" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};
