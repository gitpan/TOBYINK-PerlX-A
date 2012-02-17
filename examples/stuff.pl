use TOBYINK::PerlX::A;
use Data::Dumper;

my $u = q<http://www.google.com/> % Uri;
print Dumper($u);

say(($u ~~ Uri) ? 'it is a URI' : 'it is not');

my $x;