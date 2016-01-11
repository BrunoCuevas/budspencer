#!usr/bin/perl
# 8th Jun 2015
# Por Bruno Cuevas
use strict;
if (my $flag = shift ){
	if ($flag =~ /\-(k|x|i)/) {
		if ($flag =~ /\-k/){
				$flag = shift	;
				my $bool = 1 	;
				my $new_word	;
				my $argument	;
				while ($bool == 1) {
					($new_word = shift) or $bool = 0	;
					($bool == 1) and $argument=$argument.' '.$new_word;
				}


			system "perl /usr/local/budspencer/budspencer_searcher.pl $flag $argument";
		} elsif ($flag =~ /\-i/){
			my $file = shift	;
			system "perl  /usr/local/budspencer/budspencer.pl $file";
		} elsif ($flag =~ /\-x/){
			my $file = shift;
			system "perl  /usr/local/budspencer/budspencer_xml_parser.pl $file";

		}
	} else {
		system 'perl  /usr/local/budspencer/budspencer_help.pl';
	}

} else {
	system 'perl /usr/local/budspencer/budspencer_help.pl';
}
