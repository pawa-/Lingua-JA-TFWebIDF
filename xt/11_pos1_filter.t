use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $text = "茨城　音楽　１　まんま　たくさん";

my $tfidf = Lingua::JA::TFWebIDF->new(
    appid             => 'test',
    fetch_df          => 0,
    pos1_filter       => [qw/固有名詞/],
    pos2_filter       => [qw//],
    pos3_filter       => [qw//],
    ng_word           => [],
    concatenation_max => 0,
);


ok( !grep { $_ eq '茨城' } fetch_term( $tfidf->tfidf($text)->list(20) ) );
ok(  grep { $_ eq '音楽' } fetch_term( $tfidf->tfidf($text)->list(20) ) );

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
