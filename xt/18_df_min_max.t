use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Storable ();
use Test::More;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $df_file = './df.st';
unlink $df_file;

my %data = (
    '99'          => "99\t1",
    '100'         => "100\t1",
    '101'         => "101\t1",
    '12499999999' => "12499999999\t1",
    '12500000000' => "12500000000\t1",
    '12500000001' => "12500000001\t1",
);

Storable::nstore(\%data, $df_file) or die $!;

my %tf = (
    '99'          => 1,
    '100'         => 1,
    '101'         => 1,
    '12499999999' => 1,
    '12500000000' => 1,
    '12500000001' => 1,
);

my $tfidf = Lingua::JA::TFWebIDF->new(
    appid             => 'test',
    driver            => 'Storable',
    df_file           => $df_file,
    fetch_df          => 0,
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    df_min            => 100,
    df_max            => 125_0000_0000,
    term_length_min   => 1,
    concat_max        => 0,
);


# t/18_df_min_max.t
#ok( !grep { $_ eq '99'          } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
#ok(  grep { $_ eq '100'         } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
#ok(  grep { $_ eq '101'         } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
#ok(  grep { $_ eq '12499999999' } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
#ok(  grep { $_ eq '12500000000' } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
#ok( !grep { $_ eq '12500000001' } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );

my @text = keys %tf;
ok( !grep { $_ eq '99'          } fetch_term( $tfidf->tfidf("@text")->list(20) ) );
ok(  grep { $_ eq '100'         } fetch_term( $tfidf->tfidf("@text")->list(20) ) );
ok(  grep { $_ eq '101'         } fetch_term( $tfidf->tfidf("@text")->list(20) ) );
ok(  grep { $_ eq '12499999999' } fetch_term( $tfidf->tfidf("@text")->list(20) ) );
ok(  grep { $_ eq '12500000000' } fetch_term( $tfidf->tfidf("@text")->list(20) ) );
ok( !grep { $_ eq '12500000001' } fetch_term( $tfidf->tfidf("@text")->list(20) ) );

unlink $df_file;

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
