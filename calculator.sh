#!/bin/bash

add(){
val=$(($1 + $2))
return $val
}

subs(){
val=$(($1-$2))
return $val
}

mult(){
val=$(($1*$2))
return $val
}

div(){
val=$(($1/$2))
return $val
}

echo "give me first number:"
read a
echo "give me second number:"
read b
echo "give me operator:"
read o

case "$o" in
   "+")
        add $a $b
   ;;
   "-")
        subs $a $b
   ;;
   "*")
        mult $a $b
   ;;
   "/")
        div $a $b
   ;;
   *)
        echo "wrong operator"
   ;;
esac
#echo last returned
echo $?
