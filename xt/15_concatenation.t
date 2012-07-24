use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $text = '言語処理学会';

my %config = (
    appid             => 'test',
    fetch_df          => 0,
    pos1_filter       => [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [qw/編集 消去/],
    term_length_min   => 2,
    term_length_max   => 9,
    concatenation_max => 0,
);

my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
my @terms = fetch_term($tfidf->tfidf($text)->list);
is($terms[0], '言語処理', 'concatenation: 0');

@terms = fetch_term($tfidf->tfidf('p-model')->list);
is($terms[0], 'model', 'concatenation: 0    p-model');

$config{concatenation_max} = 100;
$tfidf = Lingua::JA::TFWebIDF->new(\%config);
@terms = fetch_term($tfidf->tfidf($text)->list);
is($terms[0], '言語処理学会', 'concatenation: 100');

@terms = fetch_term($tfidf->tfidf('p-model')->list);
is($terms[0], 'p-model', 'concatenation: 100    p-model');

@terms = fetch_term($tfidf->tfidf('p-')->list);
is(scalar @terms, '0', 'concatenation: 100    p-');

@terms = fetch_term($tfidf->tfidf('pp-')->list);
is($terms[0], 'pp', 'concatenation: 100    pp-');

@terms = fetch_term($tfidf->tfidf('pa')->list);
is($terms[0], 'pa', 'concatenation: 100    pa');

@terms = fetch_term($tfidf->tfidf('ザ・キムチ')->list);
is($terms[0], 'ザ・キムチ', 'concatenation: 100    ザ・キムチ');

@terms = fetch_term($tfidf->tfidf('ザザ・')->list);
is($terms[0], 'ザザ', 'concatenation: 100    ザザ・');

@terms = fetch_term($tfidf->tfidf('ザ・')->list);
is(scalar @terms, '0', 'concatenation: 100    ザ・');

@terms = fetch_term($tfidf->tfidf('スーパー・ラーメン')->list);
is($terms[0], 'スーパー・ラーメン', 'concatenation: 100    スーパー・ラーメン');

@terms = fetch_term($tfidf->tfidf('スーパー・スペシャル')->list);
is(scalar @terms, 0, 'concatenation: 100    スーパー・スペシャル');

@terms = fetch_term($tfidf->tfidf('情報統合思念体')->list);
is($terms[0], '情報統合思念体', 'concatenation: 100    情報統合思念体');

@terms = fetch_term($tfidf->tfidf('閉鎖空間')->list);
is($terms[0], '閉鎖空間', 'concatenation: 100    閉鎖空間');

@terms = fetch_term($tfidf->tfidf('編集空間')->list);
is($terms[0], '空間', 'concatenation: 100    編集空間');

@terms = fetch_term($tfidf->tfidf('閉鎖')->list);
is($terms[0], undef, 'concatenation: 100    閉鎖');

@terms = fetch_term($tfidf->tfidf('編集-削除')->list);
is($terms[0], undef, 'concatenation: 100    編集-削除');

@terms = fetch_term($tfidf->tfidf('編集・削除')->list);
is($terms[0], undef, 'concatenation: 100    編集・削除');

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
