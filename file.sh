#!/bin/bash

if ! [[ $# = 1 ]];then
read -p "Enter the phonebook directory " folder
else
folder=$1
fi

check='^[0-9]+$'
names="^([a-zA-Z' ]+)$"
loc="$PWD"
if ! [[ -d $folder ]]; then 
	mkdir $folder
fi
show_menu()
{
 echo "---------------------------Program Menu------------------------------"
 echo ""
 echo "1- Add new record to phone book "
 echo "2- Search phone book"
 echo "3- Update phone book"
 echo "4- Delete record from phone book"
 echo "0- Exit phone book"
}

show_file()
{
  echo "-------------$1----------"
  cat $1
  echo "--------------------------"
}


search_records()
{
 grep -i -r "$1" $folder | grep -i -r $2 $folder
 record=$?
 if [[ "$record" == "1" ]]; then
 echo "No data found"
 fi;
}

file_exists()
{
 cd $folder
  if [[ -f $1 ]]; then
  result=1
  else 
  result=0
  fi
  cd $loc
  return "$result"
}

validate_data()
{
  grep -i -r "$1" $folder | grep -i -r "$2" $folder
  record=$?
  if [[ "$record" == "1" ]]; then
  echo "No data found"
  else
  if [[ "$3" == "delete" ]]; then
  read -p "Enter file name to be deleted:" data
  else
   read -p "Enter file name to be edited:" data
   fi
  if [[ $data =~ $check ]];  then
  file_exists $data
  value=$?
  if [[ "$value" == "1" ]]; then
  if [[ "$3" == "delete" ]]; then
  read -p "Are you sure? (Y/N)" reply
  if [[ $reply =~ ^[Yy]$ ]]; then 
  cd $folder
  rm $data
  echo "File $data has been successfully deleted" 
  cd $loc
  fi
  else
  if [[ "$3" == "update" ]]; then
  case $1 in 
  "name") read -p "Enter new name:" nedit;;
  "city") read -p "Enter new City:" nedit;;
  "country") read -p "Enter new country:" nedit;;
   *) echo "No data found"
   esac
  cd $folder
  sed -i -r s/"$1"/"$1"/gI $data | sed -i -r s/"$2"/"$nedit"/gI $data
   echo "File $data has been successfully edited"
   show_file $data
   cd $loc
  fi
fi
  else
  echo "$data does not exist"
  fi
else 
	echo "File name must be an integer (Phone number)"
  fi
  fi
}

add()
{
 validate=false
 while [ "$validate" = false ]; do
 read -p "Enter your phone number:" no
 read -p "Enter your full name:" name
 read -p "Enter your city:" city
 read -p "Enter your country:" country
 if ! [[ $no =~ $check ]] || ! [[ $name =~ $names ]] || ! [[ $city =~ $names ]] || ! [[ $country =~ $names ]]; then
 echo "You must enter digits for phone number and letters for name,city and country"
 validate=false
 else
 cd $folder
 if [[ -f $no ]]; then 
 echo "$no already exists in the directory $folder"
 #cd $loc
 validate=false
 else
 validate=true
 #break
 fi
 fi
 done
 
 cat <<EOF >$no
 Name: $name
 City: $city
 Country: $country
EOF
echo "Your data was successfully added"
show_file $no
cd $loc 
}

searchData()
{
  search=true
  while [ "$search" = true ]; do
  echo "How do you want to search the phonebook"
  echo "1- By phone number"
  echo "2- By Name or Surname"
  echo "3- By City"
  echo "4- By country"
  echo "5- Back to main menu"
  read -p "Please choose your operation ->" value
  case $value in 
  1) read -p "Enter phone number:" phone
	 cd $folder
	 if [[ -f $phone ]]; then 
	 show_file $phone
     cd $loc
	 else 
	 echo "No file found"
	 fi
     ;;
  2) read -p "Enter Name:" names
     search_records Name $names
	 ;;
	 
  3) read -p "Enter City:" cty
     search_records City $cty
     ;;
  4) read -p "Enter Country:" nation
     search_records Country $nation
     ;;
  5) search=false;;
  *) echo "Please enter 1, 2, 3, 4 or 5"
  esac
  done
}

edit_data()
{
   validate=false
  while [ "$validate" = false ]; do
  echo "What do you want to do"
  echo "1- Edit Phone number"
  echo "2- Edit name or Surname"
  echo "3- Edit City"
  echo "4- Edit Country"
  echo "0- Go back to main menu"
  read -p "Please choose your operation ->" value
  case $value in 
  1) read -p "Enter Phone number:" edit
     read -p "Enter new Phone number:" new
     if [[ $edit =~ $check ]] || [[ $new =~ $check ]];  then
     file_exists $edit
     value=$?
     if [[ "$value" == "1" ]]; then
     file_exists $new
     result=$?
     if [[ "$result" == "0" ]]; then 
     cd $folder
     mv $edit $new
     echo "File $edit has been successfully edited"
	 show_file $new
     cd $loc
     validate=false
     else
     echo "$edit does not exist"
     validate=false
     fi
     else
     echo "Phone numbers must be a number"
     validate=false
     fi
	 fi
  ;;
  2) read -p "Enter the Name or Surname to be edited:" edit
     validate_data name "$edit" update 
     ;;
  3) read -p "Enter the City to be edited:" edit
     validate_data city "$edit" update 
     ;;
  4) read -p "Enter the Country to be edited:" edit
     validate_data country "$edit" update 
     ;;
 0) validate=true;;
 *) echo "Please enter 1,2,3,4 or 0"
 esac
  done
}

delete_data()
{
  validate=false
  while [ "$validate" = false ]; do
  echo "What do you want to do"
  echo "1- Delete by Phone number"
  echo "2- Delete by name or Surname"
  echo "3- Delete by City"
  echo "4- Delete by Country"
  echo "0- Go back to main menu"
  read -p "Please choose your operation ->" value
  case $value in 
  1) read -p "Enter the file name you want to delete (Phone number):" delete
     if [[ $delete =~ $check ]];  then
   file_exists $delete
   value=$?
   if [[ "$value" == "1" ]]; then
   read -p "Are you sure? (Y/N)" reply
   if [[ $reply =~ ^[Yy]$ ]]; then 
   cd $folder
   rm $delete
   echo "File $delete has been successfully deleted"
   cd $loc
   validate=false
   fi
   else
   echo "$delete does not exist"
   validate=false
   fi
  else
  echo "File Phone number must be a number"
  validate=false
  value=1
  fi
  ;;
  2) read -p "Enter the Name or Surname:" delete
     validate_data Name $delete delete
     ;;
  3) read -p "Enter the City:" delete
     validate_data City $delete delete
     ;;
  4) read -p "Enter the Country:" delete
     validate_data Country $delete delete
     ;;
 0) validate=true;;
 *) echo "Please enter 1,2,3,4 or 0"
 esac
  done
  }
  
echo "Welcome $u"
choice=
until [ "$choice" = "0" ]; do
show_menu
read -p "Please choose your operation -> " choice
echo ""
case $choice in 
1) add;;
2) searchData;;
3) edit_data;;
4) delete_data;;
0) exit;;
*) echo "Please enter 1, 2, 3, 4 or 0"
esac
done
