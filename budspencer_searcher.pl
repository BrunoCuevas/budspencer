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
use constant ANCHOR => 100	;
my $argument		=	shift;
my $flag					;
if ($argument =~ /\-(\w)/) {
	$flag	=	$1			;
	$argument = shift or die "No argument\n"	;
	if ($flag eq "T") {
		my $bool = 1 	;
		my $new_word	;
		while ($bool == 1) {
			($new_word = shift) or $bool = 0	;
			($bool == 1) and $argument=$argument.' '.$new_word;
		}

	}
} else {
	die "No flag\n"			;
}
system 'clear'				;
print "BSpencer Searcher\n"	;
print "por Bruno Cuevas Zuviría\n";
print "2016\n"				;
our $db		=	"budspencer"	;
our $user	=	"budspencer_user";
our $pass	=	"bud_spencer_123";
our $host	=	"localhost";
our $dbh	=	DBI-> connect("DBI:mysql:$db:$host",$user, $pass)
	or die 'No conexion';

my $query					;
my %search_dictionary = (
	"A" => ("SELECT A.titulo, A.id, A.pubmed_id, A.autor_principal, A.year FROM articulos A, escrito_por R WHERE R.pubmed = A.pubmed_id AND R.autor LIKE \"%?%\""),
	"R" => ("SELECT A.titulo, A.id, A.pubmed_id, A.autor_principal, A.year FROM articulos A WHERE A.autor_principal LIKE \"%?%\""),
	"Y" => ("SELECT A.titulo, A.id, A.pubmed_id, A.autor_principal, A.year FROM articulos A WHERE A.year = ?"),
	"J" => ("SELECT A.titulo, A.id, A.pubmed_id, A.autor_principal, A.year FROM articulos A WHERE A.fuente LIKE \"%?%\""),
	"T" => ("SELECT A.titulo, A.id, A.pubmed_id, A.autor_principal, A.year FROM articulos A WHERE A.titulo LIKE \"%?%\"")
);

if (exists $search_dictionary{$flag}) {
	$query = $search_dictionary{$flag};

} else {
	print $flag, "\n";
	die "Not correct flag: Use A, J, Y, R or T\n";
}
my $line			;
my @line			;
my $refill			;
my $word			;
my $iter	=	0	;
$query =~ s/\?/$argument/g;
my $sqlQuery = $dbh-> prepare($query)
		or die "Not possible query\n"			;

	$sqlQuery ->	execute
		or die "Not executing query\n"			;
	print "\tX\tTITULO\t\t\tID\t\tPMID\t\tAUTOR PRINCIPAL\tAÑO\n";
	print "_"x ANCHOR, "\n"		;
	while (my @row = $sqlQuery -> fetchrow_array) {
		$word = shift(@row)						;
		$word =~ /(^.{1,23})/					;
		$refill = 23 - length($1)				;
		print "\t[$iter]\t"					;
		print "$1".(" "x $refill), "\t"			;
		foreach $word (@row) {
			$word		=~ /(^.{1,15})/			;
			$refill =  15 - length($1)			;
			print "$1".(" "x $refill),"\t"		;

		}
		print "\n"				;
		$iter ++				;
	}
	$sqlQuery ->	finish		;

	print "_" x ANCHOR, "\n"	;
