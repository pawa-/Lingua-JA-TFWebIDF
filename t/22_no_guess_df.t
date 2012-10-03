use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid             => 'test',
    driver            => 'Storable',
    df_file           => './df/flagged_utf8.st',
    fetch_df          => 0,
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    concat_max        => 100,
    guess_df          => 0,
);

my %tf1 = (
    'アブラカダブラアブラオイル' => 1,
    'オイル'                     => 2,
);

my %tf2 = (
    'ショック' => 1,
    'オイル'   => 2,
);

is(scalar fetch_term( $tfidf->tfidf(\%tf1)->list(20) ), 1);
is(scalar fetch_term( $tfidf->tfidf(\%tf2)->list(20) ), 2);

done_testing;


sub fetch_term
{
    my $results = shift;

    my @terms;

    for my $result (@{$results})
    {
        my ($word, $score) = each %{$result};

        push(@terms, $word);
    }

    return @terms;
}
