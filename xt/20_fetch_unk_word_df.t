use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Storable ();
use Test::More;
use Test::Requires qw/Config::Pit/;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $df_file = './df.st';
Storable::nstore({}, $df_file) or die $!;

my $api_config = Config::Pit::pit_get('yahoo_premium_api') or die $!;
my %term_length_to_average_df = %Lingua::JA::TFWebIDF::TERM_LENGTH_TO_AVERAGE_DF;

my %config = (
    api               => 'Yahoo',
    appid             => 'test',
    driver            => 'Storable',
    df_file           => $df_file,
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    tf_min            => 1,
    term_length_min   => 1,
    term_length_max   => 30,
    df_min            => 0,
    concat_max        => 100,
);

my $unk  = '痔辭兒獅嗣璽';

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
    $unk           => 3,
    $unk x 3       => 5,
);

subtest 'fetch_df: 0    fetch_unk_word_df: 0    appid: test' => sub {
    $config{fetch_df}          = 0;
    $config{fetch_unk_word_df} = 0;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk     ), $term_length_to_average_df{ length $unk     } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $term_length_to_average_df{ length $unk x 3 } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ),   $term_length_to_average_df{ length '世界' }   );
};

# if fetch_df 0, never fetch df!
subtest 'fetch_df: 0    fetch_unk_word_df: 1    appid: test' => sub {
    $config{fetch_df}          = 0;
    $config{fetch_unk_word_df} = 1;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk     ), $term_length_to_average_df{ length $unk     } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $term_length_to_average_df{ length $unk x 3 } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ),   $term_length_to_average_df{ length '世界' }   );
};

subtest 'fetch_df: 1    fetch_unk_word_df: 0    appid: test' => sub {
    $config{fetch_df}          = 1;
    $config{fetch_unk_word_df} = 0;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk     ), $term_length_to_average_df{ length $unk     } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $term_length_to_average_df{ length $unk x 3 } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ),   $term_length_to_average_df{ length '世界' }   );
};

subtest 'fetch_df: 1    fetch_unk_word_df: 1    appid: test' => sub {
    $config{fetch_df}          = 1;
    $config{fetch_unk_word_df} = 1;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk     ), $term_length_to_average_df{ length $unk     } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $term_length_to_average_df{ length $unk x 3 } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ),   $term_length_to_average_df{ length '世界' }   );
};

subtest 'fetch_df: 0    fetch_unk_word_df: 0    appid: my app id' => sub {
    $config{fetch_df}          = 0;
    $config{fetch_unk_word_df} = 0;
    $config{api}     = 'YahooPremium';
    $config{appid}   = $api_config->{appid};
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk     ), $term_length_to_average_df{ length $unk     } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $term_length_to_average_df{ length $unk x 3 } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ),   $term_length_to_average_df{ length '世界' }   );
};

subtest 'fetch_df: 0    fetch_unk_word_df: 1    appid: my app id' => sub {
    $config{fetch_df}          = 0;
    $config{fetch_unk_word_df} = 1;
    $config{api}     = 'YahooPremium';
    $config{appid}   = $api_config->{appid};
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk     ), $term_length_to_average_df{ length $unk     } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, $unk x 3 ), $term_length_to_average_df{ length $unk x 3 } );
    is( fetch_df( $tfidf->tfidf(\%tf)->dump, '世界' ),   $term_length_to_average_df{ length '世界' }   );
};

$unk .= '亜';
$tf{$unk x 3} = '';
$tf{$unk}     = '';

subtest 'fetch_df: 1    fetch_unk_word_df: 0    appid: my app id' => sub {
    $config{fetch_df}          = 1;
    $config{fetch_unk_word_df} = 0;
    $config{api}     = 'YahooPremium';
    $config{appid}   = $api_config->{appid};
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    my $text = join("　", keys %tf);
    is(   fetch_df( $tfidf->tfidf($text)->dump, $unk      ), $term_length_to_average_df{ length $unk     } );
    is(   fetch_df( $tfidf->tfidf($text)->dump, $unk x 3  ), $term_length_to_average_df{ verylong        } );
    isnt( fetch_df( $tfidf->tfidf(keys %tf)->dump, '世界' ), $term_length_to_average_df{ length '世界' }   );
};

subtest 'fetch_df: 1    fetch_unk_word_df: 1    appid: my app id' => sub {
    $config{fetch_df}          = 1;
    $config{fetch_unk_word_df} = 1;
    $config{api}     = 'YahooPremium';
    $config{appid}   = $api_config->{appid};
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
    my $text = join("　", keys %tf);
    is(   fetch_df( $tfidf->tfidf($text)->dump, $unk     ), 0 );
    is(   fetch_df( $tfidf->tfidf($text)->dump, $unk x 3 ), 0 );
    isnt( fetch_df( $tfidf->tfidf($text)->dump, '世界' ),   $term_length_to_average_df{ length '世界' } );
};

unlink $df_file;

done_testing;


sub fetch_df
{
    my ($dump, $target) = @_;

    for my $word (keys %{ $dump })
    {
        return $dump->{$word}{df} if $word eq $target;
    }

    return;
}
