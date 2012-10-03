use strict;
use warnings;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Fatal;

can_ok('Lingua::JA::TFWebIDF', qw/new idf df tfidf tf db_open db_close purge/);

my $df_file = './df/flagged_utf8.st';

my $tfidf = Lingua::JA::TFWebIDF->new(appid => 'test', df_file => $df_file);
isa_ok($tfidf, 'Lingua::JA::TFWebIDF');

$tfidf = Lingua::JA::TFWebIDF->new({ appid => 'test', df_file => $df_file });
isa_ok($tfidf, 'Lingua::JA::TFWebIDF');

my $exception = exception{ Lingua::JA::TFWebIDF->new( pos4_filter => [], df_file => $df_file ) };
like($exception, qr/Unknown/, 'Unknown option');

done_testing;
