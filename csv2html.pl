#!/usr/bin/perl 
use CGI qw(:standard);
use strict;
use warnings;
 
my $line;
my $file;
 
# there are 10 columns in the CSV file, you can add or decrease as needed below
my ($f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$f10,$f11,$f12,$f13,$f14,$f15);
$file='11-20-2018-13-11-results.csv';
open(F,$ARGV[0])||die("Could not open $file");
 
print "<HTML>";
print "<head>";
print "</head>";
print "<body bgcolor='#4682B4'>";
print "<title>HTML Report</title>";
print "<div align='left'>";
print "<table border='1' cellpadding='5' cellspacing='0' width='100%' height='100%'>";
 
while ($line=<F>) {
    chomp $line;
 
($f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$f10,$f11,$f12,$f13,$f14)= split '\t',$line;
 
print "<TR>";
print "<TD bgcolor='#99CC99'><font size='3'>$f1</TD>";
print "<TD bgcolor='#99CC99'><font size='3'>$f2</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f3</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f4</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f5</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f6</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f7</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f8</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f9</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f10</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f11</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f12</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f13</TD>";
print "<TD bgcolor='#ADD8E6'><font size='3'>$f14</TD>";
#print "<TD bgcolor='#ADD8E6'><font size='3'>$f15</TD>";
print "</tr>";
 
}
 
print "</table>";
print "</body>";
print "</html>";
 
close(F);
