use TOBYINK::PerlX::A;
my $page = web(http://www.example.com/);
io('out.html') < $page->content;

