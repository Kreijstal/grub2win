#!/bin/bash

function ApproveIt {
  while true; do
    echo
    echo $1
    if [ ! "$2" == "" ] ; then echo $2 ; fi
    echo
    read -p "$3" yn
    echo
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) EndIt ;;
        * )     clear ; echo ; echo "Please answer yes or no."; echo;;
    esac
  done
}

function ProcessModule {
  UnSortedArray=()
  LinkType=kernel
  if [[ $1 =~ "init" ]] ; then LinkType=initrd ; fi
  SearchIt='/boot/'$1
  ArrayInput=($(ls $SearchIt*))
  for sub in "${!ArrayInput[@]}"
    do
      # echo Processing $sub
      NameFormat ${ArrayInput[$sub]}
    done
  if [ ${#UnSortedArray[@]} -eq 0 ] ; then EndIt "No valid "$LinkType" files were found" ; fi
  readarray -t SortedArray < <(printf '%s\n' "${UnSortedArray[@]}" | sort)
  LinkFiles  $LinkType
}

function NameFormat    {
  NameIn=$1
  NameStripped=${NameIn//[-]/.}
  NameStripped="${NameStripped//.img/}"
  Digits=$(echo $NameStripped | tr "." "\n")
  Occurrence=0
  WorkString=""

  for Number in $Digits
    do
      ((Occurrence+=1))
      if [ $Occurrence -eq 1 ] || [ $Occurrence -gt 5 ]; then continue ; fi 
      # echo Occurrence $Occurrence
      if [[ ! "$Number" =~ ^[0-9]+$ ]]; then continue ; fi
      printf -v Padded "%05d" $Number
      WorkString="$WorkString$Padded"
      # echo "> $Number"
      # echo "> $Padded"
  done
  # echo NameIn $NameIn
  # if [ "$WorkString" == "" ] ; then echo No Numbers ; return ; fi
  if [  $Occurrence -lt 4  ] ; then return ; fi
  WorkString="$WorkString:$NameIn"
  UnSortedArray+=($WorkString)
  # echo WorkString $WorkString
}

function PrintDetail {
  echo ; echo
  printf "%s\n" "  Input Files"
  printf "%s\n" "${ArrayInput[@]}"
  echo
  echo
  printf "%s\n" "  UnSortedArray"
  printf "%s\n" "${UnSortedArray[@]}"
  echo
  echo
  echo
  printf "%s\n" "  SortedArray"
  printf "%s\n" "${SortedArray[@]}"
  echo
  echo Final $Final
  echo
}

function LinkFiles {
  Final=${SortedArray[-1]}
  if [ $ParmsIn -gt 0 ] ; then PrintDetail ; fi
  IFS=':' read -a LinkWork <<< "$Final"
  Target=${LinkWork[1]}
  Link=${LinkWork[-1]}
  IFS='-' read -a LinkWork <<< "$Link"
  Link=${LinkWork[0]}
  if [[ $Final =~ ".img" ]] && [[ ! $Link =~ ".img" ]] ; then Link=$Link".img" ; fi
  LinkStatus="created"
  if test -f $Link ; then LinkStatus="refreshed"   ; fi
  rm -f $Link
  ln $Target $Link
  if [ $? -gt 0 ] ; then EndIt "The link of  "$Link"  to  "$Target"  failed" ; fi
  echo
  if [ $ParmsIn -eq 0 ] ; then echo ; echo ; echo "$AstLine" ; fi
  echo 
  echo The $1 link $Link was $LinkStatus
  echo
  echo The current $1 target is $Target
  echo ; if [ $ParmsIn -eq 0 ] ; then echo "$AstLine" ; echo ; fi 
  if [ $ParmsIn -gt 0 ] ; then echo ; echo "$AstLine" ; echo "$AstLine" ; echo "$AstLine" ; echo ; fi
}

function EndIt {
  IFS=' '
  echo ; echo
  if [ "$1" != ""   ] ; then echo ; echo "***  ""$1""  ***";       echo; fi
  if [ "$2" != "OK" ] ; then echo "***  "$ScriptName" cancelled  ***" ; echo ; fi
  echo ; echo ; echo ; exit
}

###############################################################################################

clear
ParmsIn="$#"
ScriptName=$(basename $BASH_SOURCE)
AstLine="**************************************************************************************"

if (( $EUID != 0 )); then 
  ApproveIt  "Script "$ScriptName" must be run via sudo or by root." "" \
    	     "Use sudo to run "$ScriptName" ?   "
              sudo $0 $1 ; exit 
fi

ApproveIt  "Script "$ScriptName" should only be run on Fedora or Manjaro systems." \
    	   "It may cause problems if it is run on other Linux distributions." \
           "Do you want to continue?   "

ProcessModule "vmlinuz"

ProcessModule "init"

EndIt $ScriptName" ended successfully" "OK"
