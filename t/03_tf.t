use strict;
use warnings;
use Lingua::JA::TFWebIDF;
use Test::More;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid    => 'test',
    fetch_df => 0,
);

for my $result (@{ $tfidf->tf("これはテストです。")->list(10) })
{
    my ($word, $freq) = each %{$result};

    unlike($word, qr/^[0-9]+$/, 'word fromat');
    like($freq, qr/^[0-9]+$/,  'freq format');
}

is(scalar @{ $tfidf->tf('')->list(10) }, 0, 'list size for empty string');
is(ref ($tfidf->tf("これはテストです。")->dump), 'HASH', 'dump method');

done_testing;
