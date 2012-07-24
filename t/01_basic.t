use strict;
use warnings;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Fatal;

can_ok('Lingua::JA::TFWebIDF', qw/new idf df tfidf tf db_open db_close purge/);

my $tfidf = Lingua::JA::TFWebIDF->new({ appid => 'test' });
isa_ok($tfidf, 'Lingua::JA::TFWebIDF');

my $exception = exception{ Lingua::JA::TFWebIDF->new( pos4_filter => [] ) };
like($exception, qr/Unknown/, 'Unknown option');

done_testing;
