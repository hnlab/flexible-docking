#!/bin/csh -f
# to build the protein-ligands complexes, and to construct the .con files
# and generate the .que file and submit to queue.
# usage : super_submit.csh root_name charge_model(opls/amsol/current) opls_version(1999/200*) queue_name(all.q/mars/...) cofactor_name(if have)
# niu, dec, 2005

echo $#argv
if ($#argv == 5) then
    setenv root $1
    setenv charge $2
	set v_opls = $3
	set queue = $4
    setenv cofactor $5
else if ($#argv == 4) then
    setenv root $1
    setenv charge $2
	set v_opls = $3
	set queue = $4
    setenv cofactor false
else 
    echo "Please enter a jobname, a charge model (opls/amsol/current), opls_version(1999/200*), queue_name(all.q/mars/...) and the cofactor name if has one"
    exit(1)
endif

if($v_opls == 1999) then
	setenv template oldtemplate
else
	setenv template template
endif

if ( -e rec.site ) then 
   setenv rec_model flex 
else 
   setenv rec_model rigid
endif

echo "cofactor is $cofactor, charge_model is $charge and protein is using $rec_model model"

setenv script_dir /net/n022/pubhome/yzhou02/Software/zhouyu_rescore/rescore/rescore2009

echo "current directory is $PWD"
setenv current_dir $PWD

foreach i (*)
   if ( -d $i ) then
     echo "enter $i"
     cd $i

     foreach j ( * )
       if ( -d $j ) then 
          setenv quename $root.$j.que
          if ( -e $quename ) then 
             echo " $quename already generated and submitted"
             goto jloop 
          else 
             echo "enter $i/$j"
             cd $j
             if ( -d log_files ) \rm -r log_files
             if ( -d data) \rm -r data
             if ( -d out_files ) \rm -r out_files
             mkdir log_files
             mkdir data
             mkdir out_files

             if ( $charge == "opls" ) then
               echo "opls, woops! Do nothing"
             else if ( $charge == "current" ) then
               echo "whatever, do nothing"
             else if ( $charge == "amsol" ) then
               echo "amsol, wow, got to generate charge files from xpdb file!"
             else 
               echo "man, you got to give a charge model"
               exit (1)
             endif
          endif
 
          cd .. 

          $script_dir/nwdock_qgen_2009 $root $current_dir $j $charge $cofactor $rec_model
          setenv quename "$root.$j.que"
          if ( $queue == "null") then
             qsub $quename
          else
             qsub -q $queue $quename
          endif
 
          echo "finished and exit $i/$j"   
       else 
          echo "$i/$j is not directory, give up!"
       endif
jloop: 
     end      # end of $j loop

     cd ..
      
   else 
     echo "$i is not directory, give up!"
   endif

end           # end of $i loop

