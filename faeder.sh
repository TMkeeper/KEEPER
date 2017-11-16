#!/usr/bin/env bash
token="399096444:AAHav14judfKas9nU1lKGMa9pOxvRS84BrY"
function print_logo() {
	echo -e "\e[38;5;77m"   
echo -e 
echo -e 
echo -e 
echo -e 
echo -e 
echo -e ""
echo -e ""
echo -e ""
echo -e 
echo -e 
echo -e 
echo -e 
echo -e 
echo -e 
}

if [ ! -f ./tg ]; then
echo -e ""
echo -e 
echo -e 
echo -e 
echo -e 
echo -e 
echo -e 
    echo "\e[31;1mtg not found"
    echo "Run $0 install"
    exit 1
 fi
if [ ! $token ]; then
echo -e ""
echo -e 
echo -e redis-
echo -e 
echo -e 
echo -e 
echo -e
  echo -e "\e[31;1mToken Not found\e"
 exit 1
 fi


  print_logo
   echo -e ""
echo -e ""
echo -e 
echo -e 
echo -e 
echo -e
echo -e
echo -e 
echo -e 
echo -e
echo -e 
echo -e    

curl "https://api.telegram.org/bot"$token"/sendmessage" -F
./tg -s ./FAEDER.lua $@ --bot=$token
