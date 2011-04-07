cd /home/jdc/wubfossil
err=0
for repo in tcl tk tdbc tcloo tclconfig tclws thread;
do
    ./fossil pull -R $repo.fossil
    if [ $? ]; then
	err=1
    fi
done
exit $err
