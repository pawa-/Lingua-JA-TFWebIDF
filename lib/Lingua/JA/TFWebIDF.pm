package Lingua::JA::TFWebIDF;

use 5.008_001;
use strict;
use warnings;

use parent 'Lingua::JA::WebIDF';
use Carp ();
use Lingua::JA::TFIDF;
use Lingua::JA::TFIDF::Result;
use List::MoreUtils ();

our $VERSION = '0.03';


sub tfidf
{
    my ($self, $args) = @_;

    if (ref $args eq 'HASH')
    {
        my $num = shift;

        my $data = {};

        for my $word (keys %{$args})
        {
            next if List::MoreUtils::any { $word eq $_ } @{ $self->_ng_word };

            $data->{$word}->{tf}    = $args->{$word};
            $data->{$word}->{tfidf} = $data->{$word}->{tf} * $self->idf($word);

            # give priority to speed
            #$data->{$word}->{df} = $self->df($word);
        }

        return Lingua::JA::TFIDF::Result->new($data);
    }
    else
    {
        my $data = $self->_calc_tf(\$args);

        for my $word (keys %{$data})
        {
            $data->{$word}->{tfidf} = $data->{$word}->{tf} * $self->idf($word);

            # give priority to speed
            #$data->{$word}->{df} = $self->df($word);
        }

        return Lingua::JA::TFIDF::Result->new($data);
    }
}

sub tf
{
    my ($self, $text) = @_;
    return Lingua::JA::TFIDF::tf($self, $text);
}

sub _calc_tf
{
    my ($self, $text_ref) = @_;
    return Lingua::JA::TFIDF::_calc_tf($self, $text_ref);
}

sub mecab
{
    my $self = shift;
    return Lingua::JA::TFIDF::mecab($self);
}

sub _mecab
{
    my ($self, $mecab) = @_;

    $self->{mecab} = $mecab if $mecab;
    return $self->{mecab};
}

sub ng_word
{
    my ($self, $ng_word) = @_;

    $self->{ng_word} = $ng_word if $ng_word;
    return $self->{ng_word};
}

sub _ng_word
{
    my $self = shift;
    return Lingua::JA::TFIDF::_ng_word($self);
}

sub config { shift; }

1;

__END__

=encoding utf8

=head1 NAME

Lingua::JA::TFWebIDF - TF*WebIDF calculator

=for test_synopsis
my ($appid, $word, @ng_words, $text);

=head1 SYNOPSIS

  use Lingua::JA::TFWebIDF;
  use feature qw/say/;
  use Data::Dumper;

  my $tfidf = Lingua::JA::TFWebIDF->new(
      appid     => $appid,
      fetch_df  => 1,
      Furl_HTTP => { timeout => 3 },
  );

  say $tfidf->idf($word);
  say $tfidf->df($word);

  my %tf = (
      '自然言語処理' => 9,
      '自然言語'     => 6,
      '自然言語理解' => 4,
      '処理'         => 5,
      '解析'         => 4,
  );

  $tfidf->ng_word(\@ng_words);

  say Dumper $tfidf->tfidf($text)->dump;
  say Dumper $tfidf->tfidf(\%tf)->dump;
  say Dumper $tfidf->tf($text)->dump;

  for my $result (@{ $tfidf->tfidf(\%tf)->list(5) })
  {
      my ($word, $score) = each %{$result};

      say "$word: $score";
  }

  for my $result (@{ $tfidf->tf($text)->list(5) })
  {
      my ($word, $frequency) = each %{$result};

      say "$word: $frequency";
  }


=head1 DESCRIPTION

Lingua::JA::TFWebIDF calculates TF*WebIDF scores.

Compared with Lingua::JA::TFIDF, this module has the following advantages.

=over 4

=item supports Tokyo Cabinet, Bing API, idf_type option, expires_in option and so on.

=item tfidf function accepts \%tf. (This eases the use of other morphological analyzers.)

=back

=head1 METHODS

=head2 new(%config)

See L<Lingua::JA::WebIDF>.

=head2 tfidf( $text || \%tf )

Calculates TF*WebIDF score.
If scalar value is set, MeCab separates the value into appropriate morphemes.
If you want to use other morphological analyzers, you have to set
a hash reference which contains terms and their TF scores.

=head2 tf($text)

Calculates TF score.

=head2 ng_word(\@ng_words)

Sets NG words.

=head2 idf($word)

See L<Lingua::JA::WebIDF>.

=head2 df($word)

See L<Lingua::JA::WebIDF>.

=head1 AUTHOR

pawa E<lt>pawapawa@cpan.orgE<gt>

=head1 SEE ALSO

L<Lingua::JA::WebIDF>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
