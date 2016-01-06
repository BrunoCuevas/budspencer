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
my @references 			;	#	Lista de IDs a buscar en internet
my @queries				;	#	Lista de queries que se van a solicitar
							#	a la base de datos
my @results				;	#	Lista de resultados devueltos por la base de
							#	datos
my $id	 				;	#	id con el que trabajamos en el momento
my $author				;	#	autor con el que trabajamos en el momento
my $info				;	#	Para distribuir variables
my @info_array			;	#	Para distribuir variables
my $year				;	#	agno con el que trabajamos en el momento
my @new_ids				;
my %queries_hash		;
for (@file) {

	($_ =~ /\#\#(\d{1,4})\#\#/) and (push(@references, $1));
}
#------------------------------------------------------------------------------#
#	Seccion	3	:	Búsqueda en base de datos								   #
#------------------------------------------------------------------------------#

for (@references) {
	push(@queries, "SELECT autor_principal, year FROM articulos WHERE id = $_");
}
@results	=	&sql_entries(@queries)	;
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
#------------------------------------------------------------------------------#
#	Seccion	4	:	Segunda consulta en la base de datos					   #
#------------------------------------------------------------------------------#

@queries	=	()	;
for (@new_ids) {

	push	(@{$queries_hash{$_}}, "SELECT R.year, R.titulo, R.fuente, R.id FROM articulos R WHERE R.pubmed_id = $_")							;
	push	(@{$queries_hash{$_}}, "SELECT E.autor, R.id FROM escrito_por E, articulos R WHERE R.pubmed_id = $_ AND E.pubmed = R.pubmed_id")	;

}


my $titulo ;
my $fuente ;
my $authors;
my @new_results;

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
	$authors	=	join(", ", @new_results)			;
	$authors	=~	s/\t\d{1,4}//g						;
	push(@file, "$authors. $year. $titulo. $fuente\n")	;


}
for (@file) {
	print "$_";
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
