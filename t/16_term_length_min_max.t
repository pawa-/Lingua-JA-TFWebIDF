use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid             => 'test',
    driver            => 'Storable',
    df_file           => './df/flagged_utf8.st',
    fetch_df          => 0,
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    term_length_min   => 2,
    term_length_max   => 30,
    concat_max        => 0,
);

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
    '表'           => 5,
    'ア' x 30      => 3,
    'ア' x 31      => 3,
);


ok( !grep { $_ eq '表'      } fetch_term( $tfidf->tfidf(\%tf)->list(20) ), 'min' );
ok(  grep { $_ eq '世界'    } fetch_term( $tfidf->tfidf(\%tf)->list(20) ), 'min' );
ok(  grep { $_ eq 'ア' x 30 } fetch_term( $tfidf->tfidf(\%tf)->list(20) ), 'max' );
ok( !grep { $_ eq 'ア' x 31 } fetch_term( $tfidf->tfidf(\%tf)->list(20) ), 'max' );


# xt/16_term_length_min.t
#ok( !grep { $_ eq '表'   } fetch_term( $tfidf->tfidf("世界さん、これは表です。")->list(20) ) );
#ok(  grep { $_ eq '世界' } fetch_term( $tfidf->tfidf("世界さん、これは表です。")->list(20) ) );

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
