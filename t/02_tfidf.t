use strict;
use warnings;
use Lingua::JA::TFWebIDF;
use Test::More;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid    => 'test',
    fetch_df => 0,
);

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
);


is(scalar @{ $tfidf->tfidf(\%tf)->list(5) }, 5, 'list size');
is(scalar @{ $tfidf->tfidf({})->list(5) },   0, 'list size for empty hash ref');
is(scalar @{ $tfidf->tfidf('')->list(5) },   0, 'list size for empty string');

for my $result (@{ $tfidf->tfidf(\%tf)->list(5) })
{
    my ($word, $score) = each %{$result};

    unlike($word, qr/^[0-9\.]+$/, 'word fromat');
    like($score, qr/^[0-9\.]+$/,  'score format');
}

for my $result (@{ $tfidf->tfidf("これはテストです。")->list(5) })
{
    my ($word, $score) = each %{$result};

    unlike($word, qr/^[0-9\.]+$/, 'word fromat');
    like($score, qr/^[0-9\.]+$/,  'score format');
}

is(ref ($tfidf->tfidf("これはテストです。")->dump), 'HASH', 'dump method');

done_testing;
