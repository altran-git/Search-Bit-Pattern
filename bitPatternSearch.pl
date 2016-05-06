#!/usr/bin/perl
use POSIX;
$| = 1;

$filesize = -s $ARGV[0];
$splitCnt = $ARGV[1];

if($splitCnt == 0){
$splitCnt = 1;
}

$subfilesize = ceil(($filesize)/($splitCnt));


open INFILE, $ARGV[0] or die $!;
binmode INFILE;

for($n=1; $n < $splitCnt + 1; $n++){
read INFILE, $buffer, $subfilesize;
open TEMPFILE, ">", 'C:\temp'.$n.'.dat' or die $!;
binmode TEMPFILE;
print TEMPFILE $buffer;
undef($buffer);
close TEMPFILE
}


$found = 0;

for($n=1; $n < $splitCnt + 1; $n++){
open TEMPFILE, "<", 'C:\temp'.$n.'.dat' or die $!;
binmode TEMPFILE;
push(@files, 'C:\temp'.$n.'.dat');
read TEMPFILE, $buffer, $subfilesize;
$unpackdata = unpack('B*', $buffer);

if($found == 0){
#if($unpackdata =~ m/1101111010010010.{40}00000001.{131008}1101111010010010.{40}00000010.{131008}1101111010010010.{40}00000011/){
if($unpackdata =~ m/11011000110110111100111101110/){
$fileaddr = $-[0];
$found = 1;
$newfile = substr($unpackdata, $fileaddr);
}
}
else{
$newfile = $newfile.$unpackdata;
}

undef($buffer);
undef($unpackdata);
close TEMPFILE;
}



$packedfile = pack 'B*', $newfile;
undef($newfile);

open OUTFILE, ">", 'C:\out.dat' or die $!;
binmode OUTFILE;
print OUTFILE $packedfile;
undef($packedfile);
close OUTFILE;
close INFILE;

foreach $file (@files) {
    unlink($file);
}





#m/1101111010010010.{40}00000001.{131008}1101111010010010.{40}00000010.{131008}1101111010010010.{40}00000011/


#1.  Open original file and store all into a buffer.
#2.  Split buffer into X separate buffers and write them to X temp files. ceiling(filesize / X);
#3.  Close X files.  Clear X buffers.

#4.  Open 1st split file and unpack to a string.   $unpk = unpack('B*', $data);
#5.  Search for the wanted string.
#6.  If found, then calculate location.
#7.  If not found, then repeat steps 4-7 with the other X files.
#8.  From the calculated position, remove the leading data that is not needed.
#9.  Concatenate any trailing files.

#10. Print to new file.
#11. Delete temp files.