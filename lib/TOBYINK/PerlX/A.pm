package TOBYINK::PerlX::A;

###
### Preamble
###
use 5.010;
use common::sense 3.4;

BEGIN
{
	$TOBYINK::PerlX::A::AUTHORITY = 'cpan:TOBYINK';
	$TOBYINK::PerlX::A::VERSION   = '0.000_002';
}

###
### Additional code that will be run after TOBYINK::PerlX::A->import
###
sub IMPORT
{
	my @EXPORT = (
		qw{ xml },
		MooseX::Types::DateTime->type_names,
		MooseX::Types::Moose->type_names,
		MooseX::Types::Path::Class->type_names,
		MooseX::Types::URI->type_names,
		);
	my $caller = caller;
	
	foreach my $sub (@EXPORT)
	{
		*{"$caller\::$sub"} = \&{$sub};
	}

	# This needs to be done *AFTER* Syntax::Collector, as one
	# of the 'use' lines (MooseX::Declare probably) enables
	# strict and warnings in their entirity.
	strict->unimport;
	warnings->unimport;
	common::sense->import;
}

###
### Load modules expected by our caller.
###
use IO::All::LWP 0 qw//;
use IO::Handle 0;
use Object::Tap 0 -package => 'UNIVERSAL';

###
### Inject these "use" lines into our caller.
###
use Syntax::Collector 0.002 -collect => q/
use Carp 0 qw(carp croak confess);
use DateTimeX::Auto 0 qw(dt) ;
use Moose::Util 0 qw(apply_all_roles);
use MooseX::Declare 0 ;
use Scalar::Util 0 'blessed' ;
use Syntax::Feature::Function 0 options => { -as => 'function' } ;
use Syntax::Feature::Io 0 ;
use Syntax::Feature::Maybe 0 ;
use Syntax::Feature::Perform 0 ;
use Syntax::Feature::Ql 0 ;
use TryCatch 0 ;
use Web::Magic 0.006 -quotelike => 'web' ;
/;

###
### Load modules needed directly by TOBYINK::PerlX::A
###
use MooseX::Types::DateTime 0 qw(:all);
use MooseX::Types::Moose 0 qw(:all);
use MooseX::Types::Path::Class 0 qw(Dir File);
use MooseX::Types::URI 0 qw(:all);
use Scalar::Util 0 qw(blessed) ;
use XML::LibXML 1.90 qw();

###
### Overload MooseX::Types types
###
{
	package MooseX::Types::TypeDecorator;
	use overload
		'~~' => sub
		{
			my ($self, $val) = @_;
			$self->__type_constraint->check($val);
		},
		'%' => sub
		{
			my ($self, $val) = @_;
			$self->__type_constraint->assert_coerce($val);
		};
}

###
### This code applies TOBYINK::PerlX::A to all classes and roles
### declared using MooseX::Declare.
###
BEGIN {
	use Moose::Util 0 qw();
	use MooseX::Declare 0;
	
	my $use_this = sub {
		my ($self, $ctx, $package) = @_;
		$ctx->add_preamble_code_parts('use TOBYINK::PerlX::A');
	};

	foreach my $kw (qw/
		MooseX::Declare::Syntax::Keyword::Class
		MooseX::Declare::Syntax::Keyword::Role
		/)
	{
		$kw->meta->add_before_method_modifier(
			add_namespace_customizations => $use_this,
			);
	}
}
	
###
### Declare some extra types for use with the xml() function.
###
{
	package TOBYINK::PerlX::A::TypeLib;
	use MooseX::Types 0 -declare => [qw/
		IOAll
		IOHandle
		/];
	BEGIN {
		class_type IOAll    => { class => 'IO::All' };
		class_type IOHandle => { class => 'IO::Handle' };
	}
}
BEGIN { TOBYINK::PerlX::A::TypeLib->import(':all'); }

###
### Define the xml() function.
###
sub xml ($)
{
	my ($in, $type) = @_;
	
	given ($in)
	{
		when (blessed $_ and $_->isa('Web::Magic'))
			{ return $_->to_dom }
		
		when (Uri)            { $type = 'location' }
		when (File)           { $type = 'IO'; $in = $in->open }
		when (IOAll)          { $type = 'IO'; $in->tie }
		when (IOHandle)       { $type = 'IO' }
		when (ref eq 'IO')    { $type = 'IO' }
		when (!ref && -f $_)  { $type = 'location' }
		when (!ref)           { $type = 'string' }
		default               { $type = 'string' }
	}
	
	XML::LibXML->load_xml($type, $in);
}

__FILE__
__END__

=head1 NAME

TOBYINK::PerlX::A - an awesome collection of syntax extensions

=head1 SYNOPSIS

 use TOBYINK::PerlX::A;
 my $page = web(http://www.example.com/);
 io('out.html') < $page->content;

=head1 DESCRIPTION

Using this module, enables all of the following:

	use Carp 0 qw(carp croak confess) ;
	require DateTime 0 ;
	use DateTimeX::Auto 0 qw(dt) ;
	require IO::All::LWP 0 ;
	use Moose::Util 0 qw(apply_all_roles) ;
	use MooseX::Declare 0 ;
	use Scalar::Util 0 'blessed' ;
	use Syntax::Feature::Function 0 options => { -as => 'function' } ;
	use Syntax::Feature::Io 0 ;
	use Syntax::Feature::Maybe 0 ;
	use Syntax::Feature::Perform 0 ;
	use Syntax::Feature::Ql 0 ;
	use TryCatch 0 ;
	use Web::Magic 0.006 -quotelike => 'web' ;
	require XML::LibXML 1.90 ;

It also enables L<common::sense> 3.4, which selectively enables strict and
warnings, and also enables utf8, and the say, state and switch features.

It exports the following additional functions to your namespace:

=over

=item * C<< xml $input >>

Parses C<< $input >> as XML, returning an L<XML::LibXML::Document> object.
C<< $input >> can be an L<IO::All> handle, an L<IO::Handle>, a filehandle,
a L<URI>, a L<Web::Magic> object, a L<Path::Class::File>, a string path to
an existing file, or a string of well-formed XML.

=back

A C<tap> method (see L<Object::Tap>) is installed into UNIVERSAL.

It exports the types from the following MooseX::Type libraries:

	use MooseX::Types::DateTime 0 qw(:all) ;
	use MooseX::Types::Moose 0 qw(:all) ;
	use MooseX::Types::Path::Class 0 qw(Dir File) ;
	use MooseX::Types::URI 0 qw(:all) ;

But does not export the corresponding C<is_Foo> and C<to_Foo> functions
provided by MooseX::Types.

Lastly, it overloads C<~~> (smart match) on the L<MooseX::Types::TypeDecorator>
class to perform a type check, and overloads C<< % >> to coerce values into
the given type.

  my $uri = 'http://www.google.com/' % Uri;
  # $uri is now blessed into the URI class.

A lot of modules are loaded, so TOBYINK::PerlX::A probably adds quite a
lot to your script's memory usage and start-up time. However, it provides
a number of useful features to your script, so it may be worth taking the
performance hit for those projects where the programmer's performance
is more of a bottleneck than the program's performance.

=head1 CAVEATS

Remember that switching package introduces a new scope...

  use TOBYINK::PerlX::A;
  
  class Example::Class1
  {
    # new scope
  }

Because TOBYINK::PerlX::A would normally fall out of scope within the
class definition, it performs a little trickery with MooseX::Declare to
ensure that it is automatically re-imported inside the class definition.

However, this trickery is global. So if you use TOBYINK::PerlX::A, then
all classes and roles defined via MooseX::Declare will use
TOBYINK::PerlX::A too.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=TOBYINK-PerlX-A>.

=head1 SEE ALSO

L<common::sense>, L<syntax>, L<MooseX::Declare>, L<MooseX::Types>,
L<IO::All>, L<Web::Magic>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=begin private

=item C<IMPORT>

=end private
