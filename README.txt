Budspencer 1.0
Bibliography manager for plain-text documents
By Bruno Cuevas Zuviría
2016
FAQ:
	b.cuevas@alumnos.upm.es
	brunocuevaszuviria@gmail.com

................................................................................
Installation
	This program needs:
	-MySQL running in the computer
	-A folder "usr/local"
	-Perl Installed
	-XML:Simple Perl Module installed. See instructions in
	http://www.techrepublic.com/article/parsing-xml-documents-with-perls-xmlsimple/#

For installing, just run the budspencerinstaller.sh
	bash budspencerinstaller.sh

................................................................................
Running the program
	Just type in shell

	budspencer -flag arg1 arg2 etc

	Possible flags:
	None	Show help
	-k		budspencer database searcher
		arg1	:	second flag
			-A	author
			-R	principal author
			-T	title
			-J	journal
			-Y	year
		arg2	:	query
			when using -T, you can type as many arguments as needed
	-x		budspencer database parsing and uploading
		arg1	:	.xml file to parse
		no arg2
	-t		budspencer citation manager
		arg1	:	file to parse
	
