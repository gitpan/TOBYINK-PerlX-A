use TOBYINK::PerlX::A;
use Data::Dumper;

class Person
{
	has name => (is => 'rw', isa => Str);
	has age  => (is => 'rw', isa => Num);
}

my $bob = Person->new(
	maybe name => 'Bob',
	maybe age  => undef,
	);

print Dumper $bob;

1;
