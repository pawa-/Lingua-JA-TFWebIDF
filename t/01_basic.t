use strict;
use warnings;
use Lingua::JA::TFWebIDF;
use Test::More;

can_ok('Lingua::JA::TFWebIDF', qw/new idf df tfidf tf ng_word/);

my $tfidf = Lingua::JA::TFWebIDF->new(appid => 'test');
isa_ok($tfidf, 'Lingua::JA::TFWebIDF');

done_testing;
