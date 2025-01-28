#!/usr/bin/perl

use strict;

my $refNum = shift @ARGV;
my $fnm    = shift @ARGV;

my @data   = ReadData($fnm);
my $maxRef = FindMaxRef(\@data);
print "$maxRef\n";

RenumRefs(\@data, $maxRef, $refNum);
print "@data";

sub RenumRefs
{
    my($aData, $maxRef, $refNum) = @_;

    for(my $ref=$maxRef; $ref>=$refNum; $ref--)
    {
        foreach my $line (@$aData)
        {
            my $lineCopy = $line;
            while(1)
            {
                my @refs = ();
                ($lineCopy, @refs) = FindNextRefsOnLine($lineCopy);
                last if(scalar(@refs) == 0);

                foreach my $oldRef (@refs)
                {
                    if($oldRef == $ref)
                    {
                        my $newRef = $oldRef+1;
                        # [nnn]
                        $line =~ s/\[\s*$oldRef\s*\]/\[$newRef\]/;
                        # [nnn,
                        $line =~ s/\[\s*$oldRef\s*\,/\[$newRef\,/;
                        # ,nnn]
                        $line =~ s/\,\s*$oldRef\s*\]/\,$newRef\]/;
                        # [... ,nnn, ...]
                        if($line =~ m/(\[[\d\s\,]+\,\s*)$oldRef\s*\,([\d\s\,]+)\]/)
                        {
                            my $pre  = $1;
                            my $post = $2;
                            $line =~ s/$pre$oldRef$post]/$pre$newRef\,$post/;
                        }
                    }
                }
            }
        }
    }

    
}

sub ReadData
{
    my($fnm) = @_;
    my @data = ();
    
    if(open(my $fp, '<', $fnm))
    {
        while(<$fp>)
        {
            push(@data, $_);
        }
        close $fp;
    }
    else
    {
        die "Can't read $fnm";
    }
    return(@data);
}

sub FindNextRefsOnLine
{
    my($line) = @_;

    my $remaining = '';

    $line =~ m/\[([\d\,]+?)\](.*)/;
    my $ref       = $1;
    my $remaining = $2;

    my @refs = split(/\s*\,\s*/, $ref);

    return($remaining, @refs);
}

sub FindMaxRef
{
    my($aData) = @_;
    my $maxRef = 0;

    foreach my $line (@$aData)
    {
        my $lineCopy = $line;
        while(1)
        {
            my @refs = ();
            ($lineCopy, @refs) = FindNextRefsOnLine($lineCopy);
            last if(scalar(@refs) == 0);
            
            # print "Remaining data:\n$lineCopy\n";

            foreach my $ref (@refs)
            {
                $maxRef = $ref if($ref > $maxRef);
            }
        }
    }

    return($maxRef);
}
