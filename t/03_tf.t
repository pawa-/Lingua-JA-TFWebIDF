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
    driver      => 'Storable',
    df_file     => './df/flagged_utf8.st',
    fetch_df    => 0,
    pos1_filter => [],
    pos2_filter => [],
    pos3_filter => [],
    ng_word     => [],
);

my $text = "これはテストです。";

for my $result (@{ $tfidf->tf($text)->list(10) })
{
    my ($word, $freq) = each %{$result};

    unlike($word, qr/^[0-9]+$/, 'word fromat');
    like($freq, qr/^[0-9]+$/,  'freq format');
}

for my $result (@{ $tfidf->tf(\$text)->list(10) })
{
    my ($word, $freq) = each %{$result};

    unlike($word, qr/^[0-9]+$/, 'word fromat for text ref');
    like($freq, qr/^[0-9]+$/,  'freq format for text ref');
}

my $result;

warnings_like { $result = $tfidf->tf->list(10) }
    qr/called without arguments/, 'called without arguments';

is(scalar @{$result}, 0, 'list size for undefined value');
is(scalar @{ $tfidf->tf('')->list(10) }, 0, 'list size for empty string');
is(ref ($tfidf->tf($text)->dump), 'HASH', 'dump method returns HASH ref');
is(ref ($tfidf->tf(\$text)->dump), 'HASH', 'dump method returns HASH ref');

done_testing;
