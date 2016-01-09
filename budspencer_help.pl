#!usr/bin/perl
use strict;
use warnings;
use constant ANCHOR => 70;
print "_"x ANCHOR, "\n"				;
print "\tBruno Cuevas, 2016\n"		;
print "BUDSPENCER\n"				;
print "Bibliography Manager For Plain Text Documents\n";
print "ARGUMENTS\n"				;
print "\t-t document\t\t\tBudSpencer to file\n";
print "\t-x xml\t\t\t\txml to Budspencer Database\n";
print "\t-k -A autorname\t\t\tQuery Autor to Database\n";
print "\t-k -R principal autorname\tQuery Principal Autor to Database\n";
print "\t-k -J journal\t\t\tQuery Journal to Database\n";
print "\t-k -T words\t\t\tQuery Title to Database\n";
print "\t-k -Y autorname\t\t\tQuery Pub Year to Database\n";
