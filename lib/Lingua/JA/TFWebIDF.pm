package Lingua::JA::TFWebIDF;

use 5.008_001;
use strict;
use warnings;
use utf8;

use parent 'Lingua::JA::WebIDF';
use Carp ();
use Encode qw/decode_utf8/;
use Text::MeCab;
use Lingua::JA::Halfwidth::Katakana;
use Lingua::JA::TFWebIDF::Result;

our $VERSION = '0.36';


sub new
{
    my $class = shift;
    my %args  = (ref $_[0] eq 'HASH' ? %{$_[0]} : @_);

    my %options;

    for my $key (qw/pos2_filter pos3_filter ng_word/)
    {
        $options{$key} = delete $args{$key};
        $options{$key} = [] unless defined $options{$key};
    }

    $options{pos1_filter}
        = defined $args{pos1_filter}
        ? delete $args{pos1_filter}
        : [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 接尾/]
        ;

    $options{term_length_min}   = defined $args{term_length_min}   ? delete $args{term_length_min}   : 2;
    $options{term_length_max}   = defined $args{term_length_max}   ? delete $args{term_length_max}   : 30;
    $options{concat_max}        = defined $args{concat_max}        ? delete $args{concat_max}        : 30;
    $options{tf_min}            = defined $args{tf_min}            ? delete $args{tf_min}            : 1;
    $options{df_min}            = defined $args{df_min}            ? delete $args{df_min}            : 0;
    $options{df_max}            = defined $args{df_max}            ? delete $args{df_max}            : 250_0000_0000;
    $options{fetch_unk_word_df} = defined $args{fetch_unk_word_df} ? delete $args{fetch_unk_word_df} : 0;
    $options{db_auto}           = defined $args{db_auto}           ? delete $args{db_auto}           : 1;

    my $self = $class->SUPER::new(\%args);

    $self->{mecab} = Text::MeCab->new(
        { node_format => '%m\t%H\n', unk_format => '%m\t%H\tUNK\n' }
    );

    # from array to hash
    @{ $self->{pos1_filter} }{ @{ $options{pos1_filter} } } = ();
    @{ $self->{pos2_filter} }{ @{ $options{pos2_filter} } } = ();
    @{ $self->{pos3_filter} }{ @{ $options{pos3_filter} } } = ();
    @{ $self->{ng_word}     }{ @{ $options{ng_word}     } } = ();

    $self->{$_} = $options{$_}
        for qw/term_length_min term_length_max concat_max tf_min df_min df_max fetch_unk_word_df/;

    return $self;
}

sub tfidf
{
    my ($self, $args, $db_auto_arg) = @_;

    if (!defined $args)
    {
        Carp::carp("tfidf method was called without arguments");
        return Lingua::JA::TFWebIDF::Result->new({});
    }


    my $tf_min  = $self->{tf_min};
    my $df_min  = $self->{df_min};
    my $df_max  = $self->{df_max};
    my $db_auto = ($self->{db_auto} || $db_auto_arg) ? 1 : 0;

    my ($df_sum, $df_num, @failed_to_fetch_df);

    my $data = {};

    if (ref $args eq 'HASH')
    {
        my $term_length_min = $self->{term_length_min};
        my $term_length_max = $self->{term_length_max};
        my $ng_word         = $self->{ng_word};

        if ($db_auto)
        {
            if ($self->{fetch_df}) { $self->db_open('write'); }
            else                   { $self->db_open('read');  }
        }

        for my $word (keys %{$args})
        {
            next if length $word < $term_length_min;
            next if length $word > $term_length_max;
            next if exists $ng_word->{$word};
            next if $args->{$word} < $tf_min;

            $data->{$word}{tf} = $args->{$word};

            my $df = $self->df($word);

            if (!defined $df)
            {
                push(@failed_to_fetch_df, $word);
                next;
            }

            if ($df < $df_min || $df > $df_max)
            {
                delete $data->{$word};
                next;
            }

            $df_sum += $df;
            $df_num++;

            $data->{$word}{df}    = $df;
            $data->{$word}{idf}   = $self->idf($data->{$word}{df}, 'df');
            $data->{$word}{tfidf} = $data->{$word}{tf} * $data->{$word}{idf};
        }
    }
    else
    {
        my @unknowns;
        $data                 = $self->_calc_tf(\$args);
        my $fetch_df          = $self->{fetch_df};
        my $fetch_unk_word_df = $self->{fetch_unk_word_df};

        if ($db_auto)
        {
            if ($fetch_df || $fetch_unk_word_df) { $self->db_open('write'); }
            else                                 { $self->db_open('read'); }
        }

        for my $word (keys %{$data})
        {
            if ($data->{$word}{tf} < $tf_min)
            {
                delete $data->{$word};
                next;
            }

            if (
               !$data->{$word}{unknown}
            || ( ref $data->{$word}{unknown} eq 'ARRAY' && scalar @{ $data->{$word}{unknown} } == 1 && $data->{$word}{unknown}[0] == 0 )
            )
            {
                my $df = $self->df($word);

                if (!defined $df)
                {
                    push(@failed_to_fetch_df, $word);
                    next;
                }

                if ($df < $df_min || $df > $df_max)
                {
                    delete $data->{$word};
                    next;
                }

                $df_sum += $df;
                $df_num++;

                $data->{$word}{df}    = $df;
                $data->{$word}{idf}   = $self->idf($data->{$word}{df}, 'df');
                $data->{$word}{tfidf} = $data->{$word}{tf} * $data->{$word}{idf};
            }
            else { push(@unknowns, $word); }
        }

        for my $word (@unknowns)
        {
            my $df;

            if ($fetch_df && $fetch_unk_word_df)
            {
                $df = $self->df($word);

                if (!defined $df)
                {
                    push(@failed_to_fetch_df, $word);
                    next;
                }
            }
            else
            {
                my $df_and_time = $self->_fetch_df($word);

                if (defined $df_and_time) { ($df) = split(/\t/, $df_and_time); }
                else
                {
                    push(@failed_to_fetch_df, $word);
                    next;
                }
            }

            if ($df < $df_min || $df > $df_max)
            {
                delete $data->{$word};
                next;
            }

            $df_sum += $df;
            $df_num++;

            $data->{$word}{df}    = $df;
            $data->{$word}{idf}   = $self->idf($data->{$word}{df}, 'df');
            $data->{$word}{tfidf} = $data->{$word}{tf} * $data->{$word}{idf};
        }
    }

    for my $word (@failed_to_fetch_df)
    {
        if ($df_num) { $data->{$word}{df} = int($df_sum / $df_num); }
        else         { $data->{$word}{df} = $df_min;                }

        $data->{$word}{idf}   = $self->idf($data->{$word}{df}, 'df');
        $data->{$word}{tfidf} = $data->{$word}{tf} * $data->{$word}{idf};
    }

    $self->db_close if $db_auto;

    return Lingua::JA::TFWebIDF::Result->new($data);
}

sub tf
{
    my ($self, $text) = @_;

    if (!defined $text)
    {
        Carp::carp("tf method was called without arguments");
        return Lingua::JA::TFWebIDF::Result->new({});
    }

    my $data = $self->_calc_tf(\$text);

    return Lingua::JA::TFWebIDF::Result->new($data);
}

sub _calc_tf
{
    my ($self, $text_ref) = @_;

    my $data             = {};
    my $mecab            = $self->{mecab};
    my $pos1_filter      = $self->{pos1_filter};
    my $pos2_filter      = $self->{pos2_filter};
    my $pos3_filter      = $self->{pos3_filter};
    my $ng_word          = $self->{ng_word};
    my $concat_max       = $self->{concat_max};
    my $term_length_min  = $self->{term_length_min};
    my $term_length_max  = $self->{term_length_max};

    my ($concatenated_word, @concatenated_infos, @concatenated_unknowns);
    my $concat_cnt = 0;

    for (my $node = $mecab->parse($$text_ref); $node; $node = $node->next)
    {
        my $record = decode_utf8( $node->format($mecab) );

        chomp $record;

        my ($word, $info, $unknown) = split(/\t/, $record, 3);

        if ( ! $concat_max )
        {
            next unless $info;
            my ($pos, $pos1, $pos2, $pos3) = split(/,/, $info, 5);

            if ($pos eq '名詞')
            {
                next if exists $pos1_filter->{$pos1};
                next if exists $pos2_filter->{$pos2};
                next if exists $pos3_filter->{$pos3};
                next if exists $ng_word->{$word};
                next if $unknown && $pos1 eq 'サ変接続';
                next if length $word < $term_length_min;
                next if length $word > $term_length_max;
                next if length $word == 1 && $word =~ /[\p{InHiragana}\p{InKatakana}\p{InHalfwidthKatakana}]/;

                $data->{$word}{tf}++;
                $data->{$word}{info} = $info;

                if ($unknown) { $data->{$word}{unknown} = 1; }
                else          { $data->{$word}{unknown} = 0; }
            }
        }
        else
        {
            my $next;
            $next = decode_utf8($node->next->surface) if $node->next;

            my ($pos, $pos1, $pos2, $pos3);
            my $is_ng_word = 0;

            if ($info)
            {
                ($pos, $pos1, $pos2, $pos3) = split(/,/, $info, 5);

                if (
                     exists $pos1_filter->{$pos1}
                  || exists $pos2_filter->{$pos2}
                  || exists $pos3_filter->{$pos3}
                  || exists $ng_word->{$word}
                )
                {
                    $is_ng_word = 1;
                }
            }

            if (
                $info

                &&

                (

                    ( length $concatenated_word && ($word eq '-' || $word eq '・') )

                    ||

                    (
                        ($pos eq '名詞')

                        &&

                        (
                            (!$is_ng_word && defined $next && $next eq '-')

                            ||

                            (!exists $ng_word->{$word} && $pos1 eq 'サ変接続' && !$unknown)

                            ||

                            (
                                   !$is_ng_word
                                && !($unknown && $pos1 eq 'サ変接続')
                                && !(length $word < $term_length_min && !length $concatenated_word)
                                && !(length $word > $term_length_max)
                                && !(length $word == 1 && $word =~ /[\p{InHiragana}\p{InKatakana}\p{InHalfwidthKatakana}]/)
                                && $concat_cnt <= $concat_max
                            )
                        )
                    )
                )
            )
            {
                $concatenated_word .= $word;
                push(@concatenated_infos, $info);

                if ($unknown) { push(@concatenated_unknowns, 1); }
                else          { push(@concatenated_unknowns, 0); }

                $concat_cnt++;
            }
            elsif (length $concatenated_word)
            {
                my $last = substr($concatenated_word, (length $concatenated_word) - 1, 1);

                if (length $concatenated_word >= $term_length_min && length $concatenated_word <= $term_length_max)
                {
                    if ($last eq '-' || $last eq '・')
                    {
                        if (length $concatenated_word > $term_length_min)
                        {
                            chop $concatenated_word;
                            pop @concatenated_unknowns;
                            pop @concatenated_infos;

                            $data->{$concatenated_word}{tf}++;
                            @{ $data->{$concatenated_word}->{unknown} } = @concatenated_unknowns;
                            @{ $data->{$concatenated_word}->{info}    } = @concatenated_infos;
                        }
                    }
                    else
                    {
                        unless (
                                exists $pos1_filter->{'サ変接続'}
                             && scalar @concatenated_infos == 1
                             && (split(/,/, $concatenated_infos[0]))[1] eq 'サ変接続'
                        )
                        {
                            $data->{$concatenated_word}{tf}++;
                            @{ $data->{$concatenated_word}->{unknown} } = @concatenated_unknowns;
                            @{ $data->{$concatenated_word}->{info}    } = @concatenated_infos;
                        }
                    }
                }

                $concatenated_word     = '';
                @concatenated_infos    = ();
                @concatenated_unknowns = ();
                $concat_cnt = 0;
            }
        }
    }

    return $data;
}

1;

__END__

=encoding utf8

=head1 NAME

Lingua::JA::TFWebIDF - TF*WebIDF calculator

=for test_synopsis
my ($appid, $word, @ng_words, $text);

=head1 SYNOPSIS

  use Lingua::JA::TFWebIDF;
  use utf8;
  use feature qw/say/;
  use Data::Printer;

  my $tfidf = Lingua::JA::TFWebIDF->new(
      api               => 'YahooPremium',
      appid             => $appid,
      fetch_df          => 1,
      Furl_HTTP         => { timeout => 3 },
      driver            => 'TokyoCabinet',
      df_file           => './yahoo.tch',
      pos1_filter       => [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
      term_length_min   => 2,
      tf_min            => 2,
      df_min            => 1_0000,
      df_max            => 500_0000,
      ng_word           => [qw/編集 本人 自身 自分 たち さん/],
      fetch_unk_word_df => 0,
      concat_max        => 100,
  );

  my %tf = (
      '自然言語処理' => 9,
      '自然言語'     => 6,
      '自然言語理解' => 4,
      '処理'         => 5,
      '解析'         => 4,
  );

  p $tfidf->tfidf(\%tf)->dump;

  p $tfidf->tfidf($text)->dump;
  p $tfidf->tf($text)->dump;

  for my $result (@{ $tfidf->tfidf($text)->list(20) })
  {
      my ($word, $score) = each %{$result};

      say "$word: $score";
  }


=head1 DESCRIPTION

Lingua::JA::TFWebIDF calculates TF*WebIDF scores.

Compared with L<Lingua::JA::TFIDF>, this module has the following advantages.

=over 4

=item * supports Tokyo Cabinet, Bing API and many options.

=item * tfidf function accepts \%tf. (This eases the use of other morphological analyzers.)

=back

=head1 METHODS

=head2 new( %config || \%config )

Creates a new Lingua::JA::TFWebIDF instance.

The following configuration is used if you don't set %config.

  KEY                 DEFAULT VALUE
  -----------         ---------------
  pos1_filter         [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 接尾/]
  pos2_filter         []
  pos3_filter         []
  ng_word             []
  term_length_min     2
  term_length_max     30
  concat_max          30
  tf_min              1
  df_min              0
  df_max              250_0000_0000
  fetch_unk_word_df   0
  db_auto             1

  idf_type            1
  api                 'Yahoo'
  appid               undef
  driver              'Storable'
  df_file             undef
  fetch_df            1
  expires_in          365
  documents           250_0000_0000
  Furl_HTTP           undef

=over 4

=item pos(1|2|3)_filter => \@pos

The filters of '品詞細分類'.

=item concat_max => $num

The maximum value of the number of term concatenations.

If 2 is specified, 2 consecutive nouns are concatenated.
I recommend that you specify a large value or 0.

If half width spaces or tabs are ignored,
you need to replace them with full width spaces.

=item fetch_df => 0 || 1

1: Fetches the DF score of a word which exists in the
dictionary of MeCab if DF score of its word is not fetched yet.

0: The average DF score is used.

=item fetch_unk_word_df => 0 || 1

'unk word' is a word which not exists in the dictionary of MeCab.

1: If fetch_df is 1, fetches DF score of unk word.

0: The average DF score is used.

=item db_auto => 0 || 1

If 1 is specified, (open|close)s the DF(Document Frequency) database automatically.

=item idf_type, api, appid, driver, df_file, expires_in, documents, Furl_HTTP

See L<Lingua::JA::WebIDF>.

=back

=head2 tfidf( $text || \%tf )

Calculates TF*WebIDF score.
If scalar value is set, MeCab separates the value into appropriate morphemes.
If you want to use other morphological analyzers, you have to set
a hash reference which contains terms and their TF scores.

=head2 tf($text)

Calculates TF score via MeCab.

=head2 idf, df, purge, db_open, db_close

See L<Lingua::JA::WebIDF>.

=head1 AUTHOR

pawa E<lt>pawapawa@cpan.orgE<gt>

=head1 SEE ALSO

L<Lingua::JA::WebIDF>

L<Lingua::JA::WebIDF::Driver::TokyoTyrant>

L<Lingua::JA::TermExtractor>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
