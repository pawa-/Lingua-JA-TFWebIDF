use strict;
use warnings;
use Lingua::JA::TFWebIDF;
use Test::More;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid    => 'test',
    fetch_df => 0,
);

my @ng_words = qw/表/;

$tfidf->ng_word(\@ng_words);

my %tf = (
    '自然言語処理' => 9,
    '自然言語'     => 6,
    '自然言語理解' => 4,
    '処理'         => 5,
    '解析'         => 4,
    '理解'         => 7,
    '課題'         => 4,
    '意味'         => 4,
    '技術'         => 4,
    '世界'         => 3,
    '表'           => 5,
);

ok( !grep { $_ eq '表'   } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
ok(  grep { $_ eq '世界' } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
ok( !grep { $_ eq '表'   } fetch_term( $tfidf->tfidf("世界さん、これは表です。")->list(20) ) );
ok(  grep { $_ eq '世界' } fetch_term( $tfidf->tfidf("世界さん、これは表です。")->list(20) ) );

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
