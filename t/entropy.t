use 5.008001;
use strict;
use warnings;
use Test::More 0.96;

use lib 't/lib';

use BadRandomSource;

use Crypt::Diceware words => { entropy => BadRandomSource::source() };

is(
    join( " ", words(5) ),
    join( " ", ("abacus") x 5 ),
    "alternate entropy source gives predictable (degenerate) order"
);

done_testing;
# COPYRIGHT
