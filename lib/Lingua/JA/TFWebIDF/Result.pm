package Lingua::JA::TFWebIDF::Result;

use strict;
use warnings;


sub new
{
    my ($class, $data) = @_;
    bless { data => $data }, $class;
}

sub list
{
    my ($self, $num) = @_;

    my $data = $self->{data};

    my ($word, $ref) = each %{$data};

    my $label = 'tf';
    $label    = 'tfidf' if $ref->{tfidf};

    my @list;
    my $i = 0;

    for my $word (
        sort { $data->{$b}->{$label} <=> $data->{$a}->{$label} }
        keys %{$data}
    )
    {
        push( @list, { $word => $data->{$word}->{$label} } );

        last if $num && ++$i == $num;
    }

    return \@list;
}

sub dump { shift->{data}; }

1;
