#!usr/bin/perl
# 21st Dec 2015
# Por Bruno Cuevas
# Descripcion
#	En este programa leemos un fichero de texto correspondiente a un fichero de
#	resumen de pubmed y generamos una lista de variables que podremos enviar a
#	una base de datos.

use strict	;
use warnings;
use DBI		;
use constant ANCHOR => 75;
system 'clear';
#------------------------------------------------------------------------------#
#	Seccion	1	:	Apertura de archivos									   #
#------------------------------------------------------------------------------#

my $file = shift							;

if (open(FILE, $file)) {
	print "SUCCESS IN OPENING OPERATION\n"	;
} else {
	print "ERROR 1	: No file\n"			;
}

my @filesummary	=	<FILE>					;
our $db		=	"budspencer"	;
our $user	=	"budspencer_user";
our $pass	=	"bud_spencer_123";
our $host	=	"localhost";
our $dbh	=	DBI-> connect("DBI:mysql:$db:$host",$user, $pass)
	or die 'No conexion';

#------------------------------------------------------------------------------#
#	Seccion	2	:	Parsing													   #
#------------------------------------------------------------------------------#
my $line			;
my $linesummary		;
my @entry			;
my @summary			;
my $iter = 1 		;
my @authors			;
my @titles			;
my @journals		;
my @years			;
my @pubmed_id		;
my @date			;
my @principal_authors;
my @localauthors	;
my $author			;
my %authors_hash	;
my $current_pubmedid;

pop(@filesummary)	;

while (@filesummary) {

	$line	=	pop @filesummary	;

	($line	=~ /\"(.*)\"\,\"\/pubmed\/\d{6,9}\"\,\"(.*)\"\,\".*\"\,\"(.*)\.\s*(\d{4})\"\,\"PubMed\"\,\"citation\"\,\"PMID\:(\d{6,9})\"\,\"pubmed\"\,\"\d{8}\"\,\"create date\:(\d{4}\/\d{1,2}\/\d{1,2})\s\|\sfirst author\:(.*)\"\,/ )
		or ($line =~/"(.*)\"\,\"\/pubmed\/\d{6,9}\"\,\"(.*)\"\,\".*\"\,\"(.*)\.\s*(\d{4})\"\,\"PubMed\"\,\"citation\"\,\"PMID\:(\d{6,9})\s?\|?\s?P?M?C?I?D?\:?P?M?C?\d{5,7}?\"\,\"pubmed\"\,\"\d{8}\"\,\"create date\:(\d{4}\/\d{1,2}\/\d{1,2})\s\|\sfirst author\:(.*)\"\,/);

		push(@titles, $1);
		push(@authors, $2);
		push(@journals, $3);
		push(@pubmed_id, $5);
		push(@date, $4);
		push(@years, $6);
		push(@principal_authors, $7);
	($iter > 15000) and last;

}
close(FILE);
my @title_query		;
$iter		=	0	;
for (@pubmed_id) {

	$current_pubmedid	=	$_	;
	push(@title_query, "INSERT INTO articulos(titulo, year, pubmed_id, fecha, fuente, autor_principal) VALUES (\"$titles[$iter]\", \"$date[$iter]\", \"$_\", \"$years[$iter]\", \"$journals[$iter]\", \"$principal_authors[$iter]\")");
	$authors[$iter] =~ s/\.$//g;
	@localauthors	=	split(", ",$authors[$iter])				;

	while (@localauthors) {

		$author = pop(@localauthors);
		push(@{$authors_hash{$author}}, $current_pubmedid);

	}

	$iter ++ 		;

}
for (keys %authors_hash) {
	$author =	$_	;
	$iter	=	0	;
	push(@title_query, "INSERT INTO autores(nombre) VALUES (\"$author\")");
	for (@{$authors_hash{$author}}) {
		$current_pubmedid = ${$authors_hash{$author}}[$iter];


		$iter ++ ;
		push(@title_query, "INSERT INTO escrito_por(pubmed,autor) VALUES ($current_pubmedid, \"$author\")");

	}
}

&sql_entries(@title_query);
sub sql_entries {
	if (@_) {

		my @query		=	@_			;
		my $sqlQuery					;
		my $query_line					;
		my $iter_sql					;
		while (@query)	{
			print "QUERY = $iter_sql\t\t";

			$query_line =	shift(@query);


			$sqlQuery	=	$dbh -> prepare($query_line)	;
			$sqlQuery -> execute
				or ((next) and (print 'Not possible query!')) 	;
			$sqlQuery -> finish
				or  ((next) and (print 'Not completed query!')) 	;
			print "NEXT QUERY\n";
			$iter_sql	++	;

		}
	}
}
