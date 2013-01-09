use 5.010;
use strict;
use warnings;
use Test::More 0.96;

use Crypt::Diceware;
use Crypt::Diceware words => { -as => 'words_common',   wordlist => 'Common' };
use Crypt::Diceware words => { -as => 'words_original', wordlist => 'Original' };
use Crypt::Diceware words => { -as => 'words_beale',    wordlist => 'Beale' };

my $count;

is( $count = () = words(),   0, "words() without args returns empty list" );
is( $count = () = words(-1), 0, "words() with negative arg returns empty list" );

for my $n ( 1 .. 4 ) {
  is( $count = () = words($n), $n, "words($n) returns list of $n words" );
}

is( $count = () = words(3.14), 3, "words(3.14) returns list of 3 words" );

isnt(
  join( " ", words(5) ),
  join( " ", words(5) ),
  "words(N) != words(N) (default)"
);

isnt(
  join( " ", words_common(5) ),
  join( " ", words_common(5) ),
  "words_common(N) != words_common(N))"
);
isnt(
  join( " ", words_original(5) ),
  join( " ", words_original(5) ),
  "words_original(N) != words_original(N)"
);
isnt(
  join( " ", words_beale(5) ),
  join( " ", words_beale(5) ),
  "words_beale(N) != words_beale(N)"
);

done_testing;
# COPYRIGHT
