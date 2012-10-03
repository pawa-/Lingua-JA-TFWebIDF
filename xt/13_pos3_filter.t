use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Requires qw/TokyoCabinet/;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $text = "長久保　ミヤコ";

my $tfidf = Lingua::JA::TFWebIDF->new(
    appid             => 'test',
    driver            => 'TokyoCabinet',
    df_file           => './df/utf8.tch',
    fetch_df          => 0,
    pos1_filter       => [qw//],
    pos2_filter       => [qw//],
    pos3_filter       => [qw/姓/],
    ng_word           => [],
    concat_max        => 0,
);


ok(  grep { $_ eq 'ミヤコ' } fetch_term( $tfidf->tfidf($text)->list(20) ) );
ok( !grep { $_ eq '長久保' } fetch_term( $tfidf->tfidf($text)->list(20) ) );

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
