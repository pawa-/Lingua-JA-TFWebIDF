use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my %config = (
    appid             => 'test',
    fetch_df          => 0,
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    tf_min            => 1,
    term_length_min   => 1,
    term_length_max   => 30,
    df_min            => 0,
    concat_max        => 0,
);

my $tfidf = Lingua::JA::TFWebIDF->new(\%config);
ds_check( $tfidf->tfidf('テスト')->dump, '' );
ds_check( $tfidf->tfidf({ 'テスト' => 1 })->dump, 'HASH' );

$config{concat_max} = 100;
$tfidf = Lingua::JA::TFWebIDF->new(\%config);
ds_check_concat( $tfidf->tfidf('情報統合')->dump );
ds_check_list_size( $tfidf->tfidf('情報統合')->dump, '2', '情報統合' );
ds_check_concat( $tfidf->tfidf('pa-')->dump );
ds_check_list_size( $tfidf->tfidf('pa-')->dump, '1', 'pa' );

done_testing;


sub ds_check
{
    my ($data, $type) = @_;

    for my $word (keys %{$data})
    {
        like($data->{$word}{df},      qr/^[0-9]+$/,    'df');
        like($data->{$word}{idf},     qr/^[\.0-9]+$/,  'idf');
        like($data->{$word}{info},    qr/^[^\.0-9]+$/, 'info')    unless $type eq 'HASH';
        like($data->{$word}{unknown}, qr/^[01]$/,      'unknown') unless $type eq 'HASH';
        like($data->{$word}{tf},      qr/^[0-9]+$/,    'tf');
        like($data->{$word}{tfidf},   qr/^[\.0-9]+$/,  'tfidf');
    }
}

sub ds_check_concat
{
    my $data = shift;;

    for my $word (keys %{$data})
    {
        like($data->{$word}{df},    qr/^[0-9]+$/,   'df');
        like($data->{$word}{idf},   qr/^[\.0-9]+$/, 'idf');
        is(ref $data->{$word}{info},    'ARRAY',    'info');
        is(ref $data->{$word}{unknown}, 'ARRAY',    'unknown');
        like($data->{$word}{tf},    qr/^[0-9]+$/,   'tf');
        like($data->{$word}{tfidf}, qr/^[\.0-9]+$/, 'tfidf');
    }
}

sub ds_check_list_size
{
    my ($data, $size, $surface) = @_;

    for my $word (keys %{$data})
    {
        is($word, $surface, 'surface');
        is(scalar @{ $data->{$word}{info} },    $size, 'info');
        is(scalar @{ $data->{$word}{unknown} }, $size, 'unknown');
    }
}
