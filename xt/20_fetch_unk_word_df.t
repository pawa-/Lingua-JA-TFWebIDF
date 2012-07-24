use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;
use File::ShareDir qw/dist_file/;
use Config::Pit    qw/pit_get/;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $df_file = 'yahoo_flagged_utf8.st';
unlink $df_file;

my $api_config = pit_get('yahoo_premium_api') or die $!;

my %config = (
    appid             => 'test',
    df_file           => dist_file('Lingua-JA-WebIDF', $df_file),
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    tf_min            => 1,
    term_length_min   => 1,
    term_length_max   => 20,
    df_min            => 0,
    concatenation_max => 0,
);

my $unk  = '痔辭兒獅嗣璽';
my $unk2 = '痔辭兒獅嗣餌';

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
    $unk x 3       => 5,
);

subtest 'fetch_df: 0    fetch_unk_word_df: 0' => sub {
    $config{fetch_df}          = 0;
    $config{fetch_unk_word_df} = 0;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    my $avg   = fetch_average_df( $tfidf->tfidf(\%tf)->dump );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $avg );
    isnt( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ), $avg );
};

subtest 'fetch_df: 0    fetch_unk_word_df: 1' => sub {
    $config{fetch_df}          = 0;
    $config{fetch_unk_word_df} = 1;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    my $avg   = fetch_average_df( $tfidf->tfidf(\%tf)->dump );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $avg );
    isnt( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ), $avg );
};

subtest 'fetch_df: 1    fetch_unk_word_df: 0' => sub {
    $config{fetch_df}          = 1;
    $config{fetch_unk_word_df} = 0;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    my $avg   = fetch_average_df( $tfidf->tfidf(\%tf)->dump );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $avg );
    isnt( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ), $avg );
};

subtest 'fetch_df: 1    fetch_unk_word_df: 1    appid: test' => sub {
    $config{fetch_df}          = 1;
    $config{fetch_unk_word_df} = 1;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    my $avg   = fetch_average_df( $tfidf->tfidf(\%tf)->dump );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $avg );
    isnt( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ), $avg );
};

subtest 'fetch_df: 1    fetch_unk_word_df: 1    appid: my app id' => sub {
    $config{fetch_df}          = 1;
    $config{fetch_unk_word_df} = 1;
    $config{api}     = 'YahooPremium';
    $config{appid}   = $api_config->{appid};
    $config{df_file} = $df_file;
    delete $tf{$unk x 3};
    $tf{$unk2 x 3} = 5;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    my $avg   = fetch_average_df( $tfidf->tfidf(\%tf)->dump );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk2 x 3 ), 0 );
    isnt( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ), $avg );
};

unlink $df_file;

done_testing;


sub fetch_average_df
{
    my $dump = shift;

    my ($df_sum, $df_num);

    for my $word (keys %{ $dump })
    {
        $df_sum += $dump->{$word}{df};
        $df_num++;
    }

    return int($df_sum / $df_num);
}

sub fetch_df
{
    my ($dump, $target) = @_;

    for my $word (keys %{ $dump })
    {
        return $dump->{$word}{df} if $word eq $target;
    }

    return;
}
