echo -e "Bruno Cuevas Zuviria, 2016"
echo -e "_______________________________________________"
echo -e "BudSpencer Installer"
echo -e "Bibliography Manager for plain text documents"
echo -e "FAQ: brunocuevaszuviria@gmai.com"
echo -e "_______________________________________________"
ls /usr/local/budspencer || sudo mkdir /usr/local/budspencer/
sudo cp budspencer_searcher.pl /usr/local/budspencer
sudo cp budspencer.pl /usr/local/budspencer
sudo cp budspencer_sql_creation.sql /usr/local/budspencer
sudo cp budspencer_xml_parser.pl /usr/local/budspencer
sudo cp budspencer_start.pl /usr/local/budspencer
sudo cp budspencer_help.pl /usr/local/budspencer
mysql -u root < "budspencer_sql_creation.sql"
sudo sh -c "cat budspencer.sh>>/etc/bash.bashrc"
echo -e "INSTALACION COMPLETADA"
exit 1
