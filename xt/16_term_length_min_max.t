use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Requires qw/TokyoCabinet/;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my $tfidf = Lingua::JA::TFWebIDF->new(
    appid             => 'test',
    driver            => 'TokyoCabinet',
    df_file           => './df/utf8.tch',
    fetch_df          => 0,
    pos1_filter       => [],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [],
    term_length_min   => 2,
    term_length_max   => 20,
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
);


# t/16_term_length_min.t
#ok( !grep { $_ eq '表'   } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );
#ok(  grep { $_ eq '世界' } fetch_term( $tfidf->tfidf(\%tf)->list(20) ) );

ok( !grep { $_ eq '表'       } fetch_term( $tfidf->tfidf("世界さん、これは表です。")->list(20) ), 'min' );
ok(  grep { $_ eq '世界'     } fetch_term( $tfidf->tfidf("世界さん、これは表です。")->list(20) ), 'min' );
ok(  grep { $_ eq 'ア' x 20  } fetch_term( $tfidf->tfidf('ア' x 20)->list(20) ), 'max' );
ok( !grep { $_ eq 'ア' x 21  } fetch_term( $tfidf->tfidf('ア' x 21)->list(20) ), 'max' );

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
