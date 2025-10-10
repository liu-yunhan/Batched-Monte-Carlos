edit: 
template.do
create_replications.py

no need to edit:
1.run_do_files
MP
SE

Notes:
The shell script expects that the output from each generated DO file is a dta file with the same name.

In this example, the generated DO files are named mean_r1.do, mean_r2.do, ...

The shell script will move mean_r1.do from generated_dofiles to done_dofiles after it 'sees' mean_r1.dta 
has been created.

***************************************
cd ~/Dropbox/Monte_Carlo/conference
chmod 700 1.run_do_files.sh
./1.run_do_files.sh
***************************************