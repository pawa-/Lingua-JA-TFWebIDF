use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Warn;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid       => 'test',
    fetch_df    => 0,
    pos1_filter => [],
    pos2_filter => [],
    pos3_filter => [],
    ng_word     => [],
);

my %tf = (
    '自然言語'     => 6,
    '自然言語処理' => 9,
    '自然言語理解' => 4,
    '処理'         => 5,
    '解析'         => 4,
    '理解'         => 7,
    '課題'         => 4,
    '意味'         => 4,
    '技術'         => 4,
    '世界'         => 3,
);


my $result;
warning_like { $result = $tfidf->tfidf->list(5) }
    qr/called without arguments/, 'called without arguments';

is(scalar @{$result}, 0, 'list size for undefined value');
is(scalar @{ $tfidf->tfidf(\%tf)->list(5) },  5,  'list size');
is(scalar @{ $tfidf->tfidf(\%tf)->list(50) }, 10, 'specified too many list size');
is(scalar @{ $tfidf->tfidf(\%tf)->list },     10, 'unspecified list size');
is(scalar @{ $tfidf->tfidf({})->list(5) },    0,  'list size for empty hash ref');
is(scalar @{ $tfidf->tfidf('')->list(5) },    0,  'list size for empty string');

my @ranking;

for my $result (@{ $tfidf->tfidf(\%tf)->list(5) })
{
    my ($word, $score) = each %{$result};

    push(@ranking, $word);

    unlike($word, qr/^[0-9\.]+$/, 'word fromat');
    like($score, qr/^[0-9\.]+$/,  'score format');
}

is($ranking[0], '自然言語処理', 'sorting');

for my $result (@{ $tfidf->tfidf("これはテストです。")->list(5) })
{
    my ($word, $score) = each %{$result};

    unlike($word, qr/^[0-9\.]+$/, 'word fromat');
    like($score, qr/^[0-9\.]+$/,  'score format');
}

is(ref ($tfidf->tfidf("これはテストです。")->dump), 'HASH', 'dump method returns HASH ref');

done_testing;
