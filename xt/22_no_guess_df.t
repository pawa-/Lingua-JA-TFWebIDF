use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Requires qw/TokyoCabinet/;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid             => 'test',
    driver            => 'TokyoCabinet',
    df_file           => './df/utf8.tch',
    fetch_df          => 0,
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    concat_max        => 100,
    guess_df          => 0,
);

is(scalar fetch_term( $tfidf->tfidf("アブラカダブラアブラオイル")->list(20) ), 0);
is(scalar fetch_term( $tfidf->tfidf("オイル")->list(20) ), 1);

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
