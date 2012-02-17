use TOBYINK::PerlX::A;
use Test::More tests => 5;
use Test::Exception;

class Person
{
	has name => (is => 'rw', isa => Str);
	has age  => (is => 'rw', isa => Num);
}

my $bob;
lives_ok {
	$bob = Person->new(
		maybe name => 'Bob',
		maybe age  => undef,
		);
	};

is
	$bob->name,
	'Bob';

ok(!defined $bob->age);

ok('Bob' ~~ Str);

ok(!('Bob' ~~ Num));

1;
