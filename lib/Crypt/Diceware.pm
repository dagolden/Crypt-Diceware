use 5.008001;
use strict;
use warnings;

package Crypt::Diceware;
# ABSTRACT: Random passphrase generator loosely based on the Diceware algorithm
# VERSION

use Class::Load qw/load_class/;
use Data::Entropy::Algorithms qw/pick_r/;

use Sub::Exporter -setup => {
  exports => [ words   => \'_build_words' ],
  groups  => { default => [qw/words/] },
};

sub _build_words {
  my ( $class, $name, $arg ) = @_;
  $arg ||= {};
  my $word_class = $arg->{wordlist} || 'Common';
  unless ( $word_class =~ /::/ ) {
    $word_class = "Crypt::Diceware::Wordlist::$word_class";
  }
  load_class($word_class);
  my $list = do {
    no strict 'refs';
    \@{"${word_class}::Words"};
  };
  return sub {
    my ($n) = @_;
    return unless $n && $n > 0;
    return map { pick_r($list) } 1 .. int($n);
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

A Diceware passphrase consists of a randomly selected words chosen from a list
of over seven thousand words.  A passphrase of four or five words is likely to
be stronger than typical human-generated passwords, which tend to be
too-short and over-sample common letters ("e") and numbers ("1").

Words are selected by randomly using L<Data::Entropy>, which is reasonably
cryptographically strong.

=head1 USAGE

By default, this module exports a single subroutine, C<words>, which uses the
L<Crypt::Diceware::Wordlist::Common> word list.

An alternate wordlist may be specified:

  use Crypt::Diceware words => { wordlist => 'Original' };

Exporting is done via L<Sub::Exporter> so any of its features may be used:

  use Crypt::Diceware words => { -as => 'passphrase' };
  my @phrase = passphrase(4);

=head2 words

  my @phrase = words(4);

Takes a positive numeric argument and returns a list of that many
randomly-selected words.  Returns the empty list if the argument is missing or
not a positive number.

=head1 SEE ALSO

=for :list
* L<Diceware|http://world.std.com/~reinhold/diceware.html>
* L<Crypt::Diceware::Wordlist::Common>
* L<Crypt::Diceware::Wordlist::Original>
* L<Crypt::Diceware::Wordlist::Beale>

Other CPAN passphrase generators:

=for :list
* L<Crypt::PW44>
* L<Crypt::XkcdPassword>

About password strength in general:

=for :list
* L<Password Strength (XKCD)|http://xkcd.com/936/>
* L<Password Strength (Wikipedia)|http://en.wikipedia.org/wiki/Password_strength>

=cut

# vim: ts=2 sts=2 sw=2 et:
