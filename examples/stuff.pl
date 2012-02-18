use TOBYINK::PerlX::A;

function uri_test ($x)
{
	say(($x ~~ Uri) ? 'it is a URI' : 'it is not');
}

my $u = q<http://www.google.com/>;

uri_test($u);
uri_test($u % Uri);
