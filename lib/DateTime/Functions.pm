package DateTime::Functions;

use 5.006;
use strict;
use warnings;

use parent 'Exporter::Tiny';

use DateTime ();

our @EXPORT = qw(
    datetime from_epoch now today from_object
    last_day_of_month from_day_of_year default_locale
    compare compare_ignore_floating duration
);

=encoding utf8

=head1 NAME

DateTime::Functions - Procedural interface to DateTime functions

=head1 SYNOPSIS

    use DateTime::Functions;
    print today->year;
    print now->strftime("%Y-%m-%d %H:%M:%S");

=head1 DESCRIPTION

This module simply exports all class methods of L<DateTime> into the
caller's namespace. The exporting is done via L<Exporter::Tiny>.

=head1 METHODS

Unless otherwise noted, all methods correspond to the same-named class
method in L<DateTime>.  Please see L<DateTime> for which parameters are
supported.

It is also possible to specify a DateTime formatter to be used.

    use DateTime::Functions { formatter => 'ISO8601' };

    my $date = datetime( '2017-01-01' );

If a formatter is provided, the exported C<datetime> function will 
be a call for the formatter's C<parse_datetime>, and every
exported function creating a L<DateTime> object will pass it the 
additional argument C< formatter => $formatter >. By default C<DateTime::Format::>
is preprended to the formatter name. If the formatter isn't part of that namespace,
use a C<+> prefix.

    use DateTime::Functions { formatter => '+My::Formatter' };

Note that since C<DateTime::Functions> uses L<Exporter::Tiny>, its exporting 
abilities can be used to do things like

    use DateTime::Functions { formatter => 'SQLite' },
                            datetime => { -as => 'dt_sqlite' };

    use DateTime::Functions { formatter => 'ICal' }, 'now';

    print "".dt_sqlite( '2017-09-12 01:02:03' ); 
    # => '2017-09-12 01:02:03'

    print "".now();  
    # => '20170912T203633Z'


=head2 Constructors

All constructors can die when invalid parameters are given.  They all
return C<DateTime> objects, except for C<duration()> which returns
a C<DateTime::Duration> object.

=over 4

=item * datetime( ... )

Equivalent to C<< DateTime->new( ... ) >>.

=item * duration( ... )

Equivalent to C<< DateTime::Duration->new( ... ) >>.

=item * from_epoch( epoch => $epoch, ... )

=item * now( ... )

=item * today( ... )

=item * from_object( object => $object, ... )

=item * last_day_of_month( ... )

=item * from_day_of_year( ... )

=back

=head2 Utility Functions

=over 4

=item * default_locale( $locale )

Equivalent to C<< DateTime->DefaultLocale( $locale ) >>.

=item * compare

=item * compare_ignore_floating

=back

=cut

sub _exporter_expand_sub {
    my ($self, $name, $args, $globals) = @_;

    die "'$name' is not exported by $self" 
        unless grep { $_ eq $name } @EXPORT;

    return ( duration => \&duration ) if $name eq 'duration';

    my $method = $name;

    my $formatter = $globals->{formatter};
    if ( $formatter ) {
        $formatter = 'DateTime::Format::'.$formatter
            unless $formatter =~ s/\+//;

        require Module::Runtime;
        Module::Runtime::use_module($formatter);
    }

    if ( $name eq 'datetime' ) {
        return ( datetime => $formatter 
            ?  sub { my $dt = $formatter->parse_datetime(@_); $dt->set_formatter($formatter); $dt; }
            :  sub { DateTime->new(@_) }
        );
    }

    $method = 'DefaultLocale' if $name eq 'default_locale';

    return ( $name => sub { 
            DateTime->can($method)->('DateTime', 
                ( formatter => $formatter ) x !!$formatter,
                @_
            )
        } );
}

sub duration {
    require DateTime::Duration;
    return DateTime::Duration->new(@_);
}

1;

=head1 SEE ALSO

L<DateTime>

=head1 AUTHOR

唐鳳 E<lt>cpan@audreyt.orgE<gt>

=head1 COPYRIGHT AND LICENSE

唐鳳 has dedicated the work to the Commons by waiving all of his or her rights to the work worldwide under copyright law and all related or neighboring legal rights he or she had in the work, to the extent allowable by law.

Works under CC0 do not require attribution. When citing the work, you should not imply endorsement by the author.

This work is published from Taiwan.

L<http://creativecommons.org/publicdomain/zero/1.0>

=cut

