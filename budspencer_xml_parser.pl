#!usr/bin/perl
# 6th Jun 2015
# Por Bruno Cuevas
# Descripción
#	El objeto de este programa es leer ficheros xml para poder incorporar
#	todos los datos necesarios para la citación, puesto que los .csv incorporan
#	diferentes formatos para establecer el número de volumen.
use strict;
use warnings;
use DBI;
use XML::Simple;
use Data::Dumper;
use constant ANCHOR=>75	;
system 'clear'			;
print "_"x ANCHOR		;
print "\n"				;
print "PUBMED XML PARSER\n";
print "Por Bruno Cuevas Zuviría, 2016\n";
#------------------------------------------------------------------------------#
#	Seccion	1	:	Conexion a la base de datos
#------------------------------------------------------------------------------#
our $db		=	"budspencer"	;
our $user	=	"budspencer_user";
our $pass	=	"bud_spencer_123";
				
our $host	=	"localhost";
our $dbh	=	DBI-> connect("DBI:mysql:$db:$host",$user, $pass)
	or die 'No conexion';
#------------------------------------------------------------------------------#
#	Seccion	1	:	Lectura del archivo xml
#------------------------------------------------------------------------------#
my $xml		=	new XML::Simple;
my $xml_data=	$xml->XMLin(shift) or die "Not XML Found!\n";


my $ele;
my $iter = 0;
print scalar(@{$xml_data->{PubmedArticle}}), "\n";
foreach $ele (@{$xml_data->{PubmedArticle}}){
	print "We Are in $iter\n";
	my $pmid	=	$ele->{MedlineCitation}->{PMID}->{content}										;
	my $title	=	$ele->{MedlineCitation}->{Article}->{ArticleTitle}								;
	my $journal =	$ele->{MedlineCitation}->{Article}->{Journal}->{ISOAbbreviation}					;
	my $issue	=	$ele->{MedlineCitation}->{Article}->{Journal}->{JournalIssue}->{Issue}			;
	my $volume	=	$ele->{MedlineCitation}->{Article}->{Journal}->{JournalIssue}->{Volume}			;
	my $year	=	$ele->{MedlineCitation}->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Year}	;
	print "ESTAMOS TRABAJANDO EN = $pmid\n";
	my @authors	;
	my $author_iter;
	if (ref($ele->{MedlineCitation}->{Article}->{AuthorList}->{Author}) eq "ARRAY"){
		foreach $author_iter (@{$ele->{MedlineCitation}->{Article}->{AuthorList}->{Author}}){
			push(@authors, $author_iter->{LastName}.' '.$author_iter->{Initials});
		}
	} else {
		push(@authors, $ele->{MedlineCitation}->{Article}->{AuthorList}->{Author})
	}
	print "_"x ANCHOR, "\n" ;
	print "PMID = $pmid\tTITULO = $title\n";
	print "JOURNAL = $journal\tISSUE = $issue\tVOLUME = $volume\tAÑO = $year\n";
	foreach $author_iter (@authors) {
		print "AUTOR = $author_iter\n";
	}
	my @query;
	push(@query, "INSERT INTO articulos(titulo, year, pubmed_id, fuente, issue, volumen, autor_principal) VALUES (\"$title\",\"$year\",\"$pmid\", \"$journal\",\"$issue\", \"$volume\",	 \"$authors[0]\")");
	foreach $author_iter (@authors){
		push(@query, "INSERT INTO autores(nombre) VALUES (\"$author_iter\")");
		push(@query, "INSERT INTO escrito_por(pubmed, autor) VALUES (\"$pmid\",\"$author_iter\" )");
	}
	$iter ++;
	for (@query) {
		print "$_\n";
	}
	print "_"x ANCHOR, "\n" ;
	&connectsql(@query) and print "QUERY COMPLETED!\n";

}
sub connectsql {
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
	} else {
		die 'No arguments';
	}
}
