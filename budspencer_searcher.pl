#!usr/bin/perl
# 6th Jun 2015
# Por Bruno Cuevas
# Descripción
#	El objetivo de este programa es permitir realizar búsquedas
#	en la base de datos local que hemos instalado para posteriormente
#	realizar búsquedas bibliográficas
use strict					;
use DBI						;
use warnings				;
use constant ANCHOR => 70	;
system 'clear'				;
print "BSpencer Searcher\n"	;
print "por Bruno Cuevas Zuviría\n";
print "2016\n"				;
print "_"x ANCHOR, "\n"		;
our $db		=	"budspencer"	;
our $user	=	"budspencer_user";
our $pass	=	"bud_spencer_123";
our $host	=	"localhost";
our $dbh	=	DBI-> connect("DBI:mysql:$db:$host",$user, $pass)
	or die 'No conexion';
print "NUEVA QUERY\n\t"	;
my $question = <STDIN>		;
my $line;
my @line;
my $refill;

while (not($question =~ /^c/i)) {
	chomp($question);
	print "results for $question\n";
	print "_" x ANCHOR, "\n"	;
	my @query					;
	push(@query, $question)		;
	my @results = &sql_entries(@query) ;
	my $iter	= 0				;
	my $word					;
	foreach $line  (@results) {
		@line = split("\t", $line);
		print "\t[$iter]\t";
		$word = shift (@line) ;
		$word =~ /(^.{1,23})/;
		$refill = 23 - length($1);
		print "$1".(" "x $refill), "\t";
		while (@line) {
			$word		= shift(@line);
			$word		=~ /(^.{1,15})/;
			$refill =  15 - length($1);
			print "$1".(" "x $refill),"\t";
		}
		print "\n";
		$iter ++;
	}
	print "NUEVA QUERY \n\t";
	$question  = <STDIN>;

}
sub sql_entries {
	if (@_) {


		my @query		=	@_			;
		my $sqlQuery					;
		my $query_line					;
		my $line						;
		my @results						;

		while (@query)	{

			$query_line =	shift(@query);

			$sqlQuery	=	$dbh -> prepare($query_line)	;
			$sqlQuery -> execute
				or ((next) and (print 'Not possible query!')) 	;
			while (my @row = $sqlQuery -> fetchrow_array()) {
				$line	=	join("\t", @row)			;
				push (@results, $line)					;

			}
			$sqlQuery -> finish
				or  ((next) and (print 'Not completed query!')) 	;

		}
		return @results;
	}
}
