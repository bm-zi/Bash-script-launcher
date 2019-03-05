#!/usr/bin/env bash

# Author: Bahram Z.
# script name: scriptLauncher.sh
# This script lists scripts ( .sh files) from the current directory and
# will show them in a menu, like a rotating list. Using keys and numbers,
# we can create, delete, view, edit and executes all scripts within this program.
# It is a very handy script, just try it! 


# Define a temp file
tmpfile='/tmp/tmplist'


# Value of canonical file name
ScriptLock=$(readlink -f "$0")


# Testing if the current directory contains .sh files
# In if condition the stdout and stderr outputs is suppressed
 
if  ls -1 *.sh &>/dev/null ; then
   ls -1 *.sh > $tmpfile
else
	echo "No script found in \"$PWD\" !!"
fi

chmod u+x *.sh

# if you run the script up to here, the
# return value is 0 even if the if condition
# is evaluated as non zero value.

# Saving output of a command in variable, with command substitute
wl=$(wc -l < $tmpfile)

# create a an array from lines of file tmpfile
scriptArray=(`cat $tmpfile`)


# Function: print a message and waiting for user input
function waiting () {
	local message="$@"
	[[ -z ${message} ]] && message="   Go back to main menu? [Enter] "
	read -p "$message" inputKey
}


# Function: scrolling list of scripts in current directory,
# and edit/execute selected script
#
function scrollLines () {

# An exec <filename command redirects stdin to a file. From that point on, all stdin comes from that file,
# rather than its normal source (usually keyboard input).

exec 5<> $tmpfile  # Create new file handle 5
                   # open file for read and write, 
                   # and links the file to descripter 5


i=0
while read line1 <&5 ; do   # Reading 9 lines at a time from file , use "<&5" to read from this file 
      read line2 <&5
      read line3 <&5
      read line4 <&5
      read line5 <&5
      read line6 <&5
      read line7 <&5
      read line8 <&5
      read line9 <&5
      
		clear
		logo		
	
echo -e "
$((++i)). $line1
$((++i)). $line2
$((++i)). $line3 
$((++i)). $line4
$((++i)). $line5
$((++i)). $line6
$((++i)). $line7  
$((++i)). $line8
$((++i)). $line9"

      
     	echo    '________________________________________'
      echo -e "Enter a number [1 to $wl] or [h] for help" 
		read -p "Scroll down the list by pressing [Enter]: " n
      
      # Define conditions based on user input
		#
      if [ "$n" == "q" ]; then exit 0

		elif [ "$n" == "h" ]; then
			clear
			logo
			echo ""
			echo "Help Page"
			echo "_________"
			echo ""
			echo "   Mapped keys are as following: "	
			echo "   h - showing this help page  "
			echo "   e - executing a script"
			echo "   c - creates a new script file, then will open it for editing"
			echo "   d - deleting a script"
			echo "   y - confirm any question"
			echo "   [Enter] - continues without taking any action on any interactive case" 
         echo "   [Enter] - while in main menu, to roll over scripts in list of scripts"
			echo "   [1..$wl] - select number from 1 to $wl for edit or executing respective script"
			echo "   0 - exits program"         
			echo ""
			waiting 
         exec "$ScriptLock"

		
      elif [ "$n" == "e" ]; then
			clear
			logo
			echo ""
		 	read -p "Enter number of script to be executed: " nr
			nr=$(($nr-1))
			name="${scriptArray[$nr]}"
         echo -e "\nscript $name has been started up!\n"
         ( exec $PWD/$name )
		   waiting
			exec "$ScriptLock"
          
			
      elif [ "$n" == "d" ]; then
			clear
			logo
		 	read -p "Enter the number of script to be deleted: " nr
			nr=$(($nr-1))
			name="${scriptArray[$nr]}"
			echo "Script $name will be deleted!"

			if [ -f "$name" ]; then
         	read -p "[y] to confirm: " n
		   	if [ "$n" = "y" ]; then 
					rm -f $name
					read -p "\"$name\" deleted! - Go to main menu? [Enter]: " n
					exec "$ScriptLock"
				fi
				
			fi
         
		elif [ "$n" == c ]; then
		 	read -p "Enter a name for new script: " name
			gedit $name.sh &
			chmod u+x $name.sh
			read -p "[y] to execute - [Enter] to skip: " n
				if [ "$n" == "y" ]; then
					clear
					logo
					echo -e "\n---- Script Output Start ----\n"
					$PWD/$name.sh
					echo "---- Script Output End ----"
					echo "__________________________"
					read -p "Press [Enter] to continue: " n	
					exec "$ScriptLock"
				else
					exec "$ScriptLock"	
				fi

		elif [[ "$n" -ge 1 && "$n" -le "$wl" ]] ; then
			runscript $n
         exec "$ScriptLock"

		elif [[ "$i" -ge "$wl" ]] ; then exec "$ScriptLock"

		fi


done

# Close file handle 5
exec 5<&-

}


function logo () {
echo " _______________"
echo "|               | $(date)"
echo "|Script Launcher| \"$wl\" scripts found in current directory:" 
echo "|_______________| \"`pwd -P`\""
}


# Function: use an index number as argument for selecting a script
# from the file tmpfile and then edit/execute selected script
# under current directory
#
function runscript () { 
	scno=$(($1-1))
	
	gedit "$PWD/${scriptArray[$scno]}" &
	echo -e "Script: \"$PWD/${scriptArray[$scno]}\" \n"   
	read -p "[y] to execute or [other keys] to skip: " n
	if [ "$n" == "y" ]; then
		clear
		logo
		echo -e "\n---- Script Output Start ----\n"
		$PWD/${scriptArray[$scno]}
      echo -e "\n---- Script Output End ----"
		echo "__________________________"
		read -p "Press [Enter] to continue: " n		
		exec "$ScriptLock"
	else
		exec "$ScriptLock"	
	fi
}

scrollLine
