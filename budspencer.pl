#!usr/bin/perl
# 30th	Dec	2015
#
#	Por Bruno Cuevas
#
#	PROYECTO FINAL PROGRAMACION
#
#
#
use strict;
use DBI;
use warnings;
use constant ANCHOR => 70;
system 'clear'			;
#------------------------------------------------------------------------------#
#	Seccion	1	:	Apertura													   #
#------------------------------------------------------------------------------#
my $file	=	shift	;
our $db		=	"budspencer"	;
our $user	=	"budspencer_user";
our $pass	=	"bud_spencer_123";
our $host	=	"localhost";
our $dbh	=	DBI-> connect("DBI:mysql:$db:$host",$user, $pass)
	or die 'No conexion';
unless (open(FILE, $file)) {
	die 'Not file opened';
}
# Busqueda del patron \#\#\d{1,4}#\#
#------------------------------------------------------------------------------#
#	Seccion	2	:	Lectura													   #
#------------------------------------------------------------------------------#


my @file	=	<FILE>	;	#	Archivo
my @references 			;	#	Lista de PMID a buscar en la base de datos
my @references2			;	#	Lista de ID a buscar a en la base de datos
my @queries				;	#	Lista de queries que se van a solicitar
							#	a la base de datos utilizando el pmid
my @queries2			;	#	Lista de queries que se van a solicitar a la
							#	base de datos utilizando el id
my @results				;	#	Lista de resultados devueltos por la base de
							#	datos
my @results2			;	#	Resultados devueltos trabajando con ID
my $id	 				;	#	id con el que trabajamos en el momento
my $author				;	#	autor con el que trabajamos en el momento
my $info				;	#	Para distribuir variables
my @info_array			;	#	Para distribuir variables
my $year				;	#	agno con el que trabajamos en el momento
my @new_ids				;
my @new_ids2			;
my %queries_hash		;
my $volumen				;
my $issue				;
for (@file) {

	($_ =~ /\#\#(\d{1,10})\#\#/) and (push(@references, $1));
	($_ =~ /\¿\¿(\d{1,5})\?\?/) and (push(@references2, $1));

}
#------------------------------------------------------------------------------#
#	Seccion	3	:	Búsqueda en base de datos								   #
#------------------------------------------------------------------------------#

for (@references) {

	push(@queries, "SELECT autor_principal, year FROM articulos WHERE pubmed_id = \"$_\"");
}
for (@references2) {
	push(@queries2, "SELECT autor_principal, year FROM articulos WHERE id = \"$_\"");
}
@results	=	&sql_entries(@queries)	;
@results2	=	&sql_entries(@queries2)	;
#------------------------------------------------------------------------------#
#	Seccion	4	:	Sustitución												   #
#------------------------------------------------------------------------------#

while (@results) {

	$id	=	pop(@references)	;
	$info =	pop(@results)		;
	push(@new_ids, $id)			;
	@info_array	=	split("\t", $info);
	$author		=	shift(@info_array);
	$year		=	shift(@info_array);
	$id = '##'.$id.'##'			;
	$author =~ s/\s\w$//g		;
	$author	=	'('.$author.' et Al, '.$year.')'	;

	for (@file) {
		($_ =~ s/$id/$author/e)	;
	}

}

while (@results2) {

	$id	=	pop(@references2)	;
	$info =	pop(@results2)		;
	push(@new_ids2, $id)			;
	@info_array	=	split("\t", $info);
	$author		=	shift(@info_array);
	$year		=	shift(@info_array);
	$id = '\¿\¿'.$id.'\?\?'			;

	$author =~ s/\s\w$//g		;
	$author	=	'('.$author.' et Al, '.$year.')'	;


	for (@file) {

		($_ =~ s/$id/$author/ge)	;

	}

}
#------------------------------------------------------------------------------#
#	Seccion	4	:	Segunda consulta en la base de datos					   #
#------------------------------------------------------------------------------#

@queries	=	()	;
for (@new_ids) {

	push	(@{$queries_hash{'PMID'.$_}}, "SELECT R.year, R.titulo, R.fuente, R.pubmed_id, R.volumen, R.issue FROM articulos R WHERE R.pubmed_id = \"$_\"")							;
	push	(@{$queries_hash{'PMID'.$_}}, "SELECT E.autor, R.pubmed_id FROM escrito_por E, articulos R WHERE R.pubmed_id = \"$_\" AND E.pubmed = R.pubmed_id")	;

}
for (@new_ids2) {
	push	(@{$queries_hash{'ID'.$_}}, "SELECT R.year, R.titulo, R.fuente, R.pubmed_id, R.volumen, R.issue FROM articulos R WHERE R.id = \"$_\"")							;
	push	(@{$queries_hash{'ID'.$_}}, "SELECT E.autor, R.pubmed_id FROM escrito_por E, articulos R WHERE R.id = \"$_\" AND E.pubmed = R.pubmed_id")	;

}


my $titulo ;
my $fuente ;
my $authors;
my @new_results;
my $last_author;

#------------------------------------------------------------------------------#
#	Seccion	6	:	Creación de las citas bibliográficas					   #
#------------------------------------------------------------------------------#

for (keys %queries_hash) {




	@new_results=	&sql_entries(@{$queries_hash{$_}}) 	;

	$info		=	shift(@new_results)					;
	@info_array	=	split("\t", $info)					;

		$year	=	$info_array[0]						;
		$titulo	=	$info_array[1]						;
			$titulo	=~	s/\.$//g						;
		$fuente	=	$info_array[2]						;
		$id		=	$info_array[3]						;
		$volumen=	$info_array[4]						;
		$issue	=	$info_array[5]						;
	$last_author=	pop(@new_results)					;
	$authors	=	join(", ", @new_results)			;
	$authors	=	$authors." and $last_author"		;
	$authors	=~	s/\t\d{1,10}//g						;
	push(@file, "$authors. $year. $titulo. $fuente $volumen;$issue\n")	;


}
for (@file) {
	print "$_";
}

print "_" x ANCHOR, "\n";
print "\n>>\tPrint 2 file ? \ty/* :\t";
my $answer ;
$answer  = <STDIN>;
if ($answer =~ /^y/i) {
	print "file path : \t";
	$answer = <STDIN>;
	unless (open(OUTFILE, ">$answer")) {
		die "No Outfile found\n";
	}else {
		for (@file) {
			print OUTFILE "$_";
		}
	}
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
