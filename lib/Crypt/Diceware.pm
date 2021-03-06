use 5.008001;
use strict;
use warnings;

package Crypt::Diceware;
# ABSTRACT: Random passphrase generator loosely based on the Diceware algorithm
# VERSION

use Class::Load qw/load_class/;
use Crypt::Rijndael;
use Crypt::URandom;
use Data::Entropy qw/with_entropy_source/;
use Data::Entropy::Algorithms qw/pick_r/;
use Data::Entropy::RawSource::CryptCounter;
use Data::Entropy::Source;

use Sub::Exporter -setup => {
    exports => [ words   => \'_build_words' ],
    groups  => { default => [qw/words/] },
};

my $ENTROPY = Data::Entropy::Source->new(
    Data::Entropy::RawSource::CryptCounter->new(
        Crypt::Rijndael->new( Crypt::URandom::urandom(32) )
    ),
    "getc"
);

sub _build_words {
    my ( $class, $name, $arg ) = @_;
    $arg ||= {};
    my $list;
    my $entropy = $arg->{entropy} || $ENTROPY;
    if ( exists $arg->{file} ) {
        my @list = do { local (@ARGV) = $arg->{file}; <> };
        chomp(@list);
        $list = \@list;
    }
    else {
        my $word_class = $arg->{wordlist} || 'Common';
        unless ( $word_class =~ /::/ ) {
            $word_class = "Crypt::Diceware::Wordlist::$word_class";
        }
        load_class($word_class);
        $list = do {
            no strict 'refs';
            \@{"${word_class}::Words"};
        };
    }
    return sub {
        my ($n) = @_;
        return unless $n && $n > 0;
        my @w = with_entropy_source(
            $entropy,
            sub {
                map { pick_r($list) } 1 .. int($n);
            }
        );
        return wantarray ? @w : join( ' ', @w );
    };
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Crypt::Diceware;
  my @phrase = words(4); # qw/starker call recur outlaw/

  # with alternate word lists
  use Crypt::Diceware words => { wordlist => 'Original' };
  use Crypt::Diceware words => { wordlist => 'Beale' };

=head1 DESCRIPTION

This module generates a random passphrase of words based loosely on the
L<Diceware|http://world.std.com/~reinhold/diceware.html> algorithm by Arnold G.
Reinhold.

A Diceware passphrase consists of randomly selected words chosen from a list
of over seven thousand words.  A passphrase of four or five words is likely to
be stronger than typical human-generated passwords, which tend to be
too-short and over-sample common letters ("e") and numbers ("1").

Words are randomly selected using L<Data::Entropy> in AES counter mode,
seeded with L<Crypt::URandom>, which is reasonably cryptographically strong.

=head1 USAGE

By default, this module exports a single subroutine, C<words>, which uses the
L<Crypt::Diceware::Wordlist::Common> word list.

An alternate wordlist may be specified:

  use Crypt::Diceware words => { wordlist => 'Original' };

This loads the wordlist provided by
L<Crypt::Diceware::Wordlist::Original>. If the name of the wordlist
contains I<::> the name of the wordlist is not prefixed by
I<Crypt::Diceware::Wordlist>.

It is also possible to load a wordlist from a file via:

  use Crypt::Diceware words => { file => 'diceware-german.txt' };

The supplied file should contain one word per line.

You can also replace the entropy source with another L<Data::Entropy::Source>
object:

  use Crypt::Diceware words => { entropy => $entropy_source };

Exporting is done via L<Sub::Exporter> so any of its features may be used:

  use Crypt::Diceware words => { -as => 'passphrase' };
  my @phrase = passphrase(4);

=head2 words

  my @phrase = words(4);

Takes a positive numeric argument and returns a passphrase of that many
randomly-selected words. In a list context it will return a list of words, as above.
In a scalar context it will return a string with the words separated with a single space character:

  my $phrase = words(4);

Returns the empty list / string if the argument is missing or not a positive number.

=head1 SEE ALSO

Diceware and Crypt::Diceware related:

=for :list
* L<Diceware|http://world.std.com/~reinhold/diceware.html>
* L<Crypt::Diceware::Wordlist::Common>
* L<Crypt::Diceware::Wordlist::Original>
* L<Crypt::Diceware::Wordlist::Beale>

Other CPAN passphrase generators:

=for :list
* L<Crypt::PW44>
* L<Crypt::XkcdPassword>
* L<Review of CPAN password/phrase generators|http://neilb.org/reviews/passwords.html>

About password strength in general:

=for :list
* L<Password Strength (XKCD)|http://xkcd.com/936/>
* L<Password Strength (Wikipedia)|http://en.wikipedia.org/wiki/Password_strength>

=cut

# vim: ts=2 sts=2 sw=2 et:
