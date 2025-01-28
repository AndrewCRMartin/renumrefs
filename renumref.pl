#!/usr/bin/perl

use strict;

my $refNum = shift @ARGV;
my $fnm    = shift @ARGV;

my $data   = ReadData($fnm);
my $maxRef = FindMaxRef($data);
print "$maxRef\n";



sub ReadData
{
    my($fnm) = @_;
    my $data = '';
    
    if(open(my $fp, '<', $fnm))
    {
        local $/ = undef;

        $data = <$fp>;
        close $fp;
    }
    else
    {
        die "Can't read $fnm";
    }
    return($data);
}

sub FindNextRefs
{
    my($data) = @_;

    local $/ = undef;
    my $remaining = '';

    $data =~ m/\[([\d\,]+?)\](.*)/;
    my $ref = $1;
    my $remaining = $2;

    my @refs = split(/\s*\,\s*/, $ref);

    return($remaining, @refs);
}

sub FindMaxRef
{
    my($data) = @_;
    my $maxRef = 0;
    
    while(1)
    {
        my @refs = ();
        ($data, @refs) = FindNextRefs($data);

        print "Remaining data:\n$data\n";
        
        last if(scalar(@refs) == 0);

        foreach my $ref (@refs)
        {
            $maxRef = $ref if($ref > $maxRef);
        }
    }

    return($maxRef);
}
