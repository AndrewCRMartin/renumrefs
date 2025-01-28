#!/usr/bin/perl
use strict;

my $refNum = shift @ARGV;
my $fnm = shift @ARGV;


my $maxRef = getMaxRef($fnm);
print "$maxRef\n";
#my $data = RenumRefs($fnm, $maxRef, $refNum);
#WriteData($data);

sub RenumRefs
{
    my($fnm, $maxRefNum, $refNum) = @_;
    my $data = '';

    if(open(my $fp, '<', $fnm))
    {
        while(<$fp>)
        {
            $data .= $_;
        }
        close($fp);

        for(my $ref=$maxRef; $ref>=$refNum; $ref--)
        {
            #      '[ nnn ,'   or   '[ nnn ]' ||
            #      '[ lll, nnn ]'   or  '[ lll, nnn, mmm ]'
            while($data =~ /\[\s*(\d+)\s*[\,\]]/ ||
                  $data =~ /\[[\s\d\,]+\,\s*(\d+)\s*[\,\]]/ )
            {
                my $oldNum = $1;
                if($oldNum == $ref)
                {
                    my $newNum = $oldNum+1;
                    $data =~ s/(\[[\s\d\,]*?)$oldNum([\s\d\,]*\])/$1$newNum$2/g;
                }
            }
        }
    }
    else
    {
        die "Can't open $fnm (again)";
    }
    return($data);
} 

sub RenumRefs1
{
    my($fnm, $maxRefNum, $refNum) = @_;
    my @data = ();

    if(open(my $fp, '<', $fnm))
    {
        while(<$fp>)
        {
            push @data, $_;
        }
        close($fp);

        for(my $ref=$maxRef; $ref>=$refNum; $ref--)
        {
            foreach my $line (@data)
            {
                #      '[ nnn ,'   or   '[ nnn ]' ||
                #      '[ lll, nnn ]'   or  '[ lll, nnn, mmm ]'
                while($line =~ /\[\s*(\d+)\s*[\,\]]/ ||
                      $line =~ /\[[\s\d\,]+\,\s*(\d+)\s*[\,\]]/ )
                {
                    my $oldNum = $1;
                    if($oldNum == $ref)
                    {
                        my $newNum = $oldNum+1;
                        $line =~ s/(\[[\s\d\,]*?)$oldNum([\s\d\,]*\])/$1$newNum$2/g;
                    }
                }
            }
        }
    }
    else
    {
        die "Can't open $fnm (again)";
    }

    return(@data);
} 

sub getMaxRef
{
    my ($fnm) = @_;
    my $maxRefNum = 0;

    if(open(my $fp, '<', $fnm))
    {
        my $ref;
        while(<$fp>)
        {
            my $line = $_;
            my $pattern = '(\[\s*\d+\s*\])';
            while($line =~ /$pattern/ &&
                  ($1 ne '^^^^'))
            {
                my $inBrackets = $1;
                print "$inBrackets\n";
                $line =~ s/$inBrackets/^^^^/;
                
            }

            if ($ref > $maxRefNum)
            {
                $maxRefNum = $ref;
            }
        }
        close($fp);
    }
    else
    {
        die "Can't open $fnm";
    }
    return($maxRefNum);
}
