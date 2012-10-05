use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Fatal;
use Test::Requires qw/TokyoCabinet/;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my %config = (
    appid           => 'test',
    fetch_df        => 0,
    driver          => 'TokyoCabinet',
    df_file         => './df/utf8.tch',
    pos1_filter     => [],
    pos2_filter     => [],
    pos3_filter     => [],
    ng_word         => [],
    tf_min          => 1,
    term_length_min => 1,
    term_length_max => 30,
    df_min          => 0,
    db_auto         => 0,
);

my $text = "テスト" x 8;

my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
my $exception = exception { $tfidf->tfidf($text); };
like($exception, qr/not opened/, 'not opened');

$tfidf->db_open('read');
$exception = exception{ $tfidf->tfidf($text); };
is($exception, undef, 'opened');
$tfidf->db_close;

$config{db_auto} = 1;
$tfidf = Lingua::JA::TFWebIDF->new(\%config);
$exception = exception { $tfidf->tfidf($text); };
is($exception, undef, 'db_auto works');

$config{db_auto} = 0;
$tfidf = Lingua::JA::TFWebIDF->new(\%config);
$exception = exception { $tfidf->tfidf($text); };
like($exception, qr/not opened/, 'db_auto works');

done_testing;
