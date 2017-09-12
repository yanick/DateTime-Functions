use strict;
use Test::More tests => 1;

use Test::Requires 'DateTime::Format::SQLite';

use DateTime;
use DateTime::Functions { formatter => 'SQLite' };

my $date = datetime( '2017-01-01' );

is "$date" => '2017-01-01 00:00:00';
