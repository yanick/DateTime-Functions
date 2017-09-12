use Test::More tests => 2;

use Test::Requires 'DateTime::Format::SQLite', 'DateTime::Format::ICal';

use DateTime::Functions { formatter => 'SQLite' },
                        datetime => { -as => 'dt_sqlite' };

use DateTime::Functions { formatter => 'ICal' },
                        'now';

is "".dt_sqlite( '2017-09-12 01:02:03' ) => '2017-09-12 01:02:03', 'sqlite';

like "".now(), qr/^2\d{7}T\d{6}Z$/, 'ical';
