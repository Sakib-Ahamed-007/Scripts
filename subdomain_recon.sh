#!/bin/bash

# This script is for automating subdomain enumeration using sublist3r, subfinder & crt.sh

if [ -z "$1" ]; then
        echo "Usage: $0 <domain>"
        exit 1
fi

echo -e "Checking for required tools..."

# Checking if the required programs are installed or not.
if command -v sublist3r &>/dev/null; then
        echo "[OK] sublist3r is installed"
else
        echo "[-] sublist3r doesn't exist. Please install it"
        exit 1
fi

if command -v assetfinder &>/dev/null; then
        echo "[OK] assetfinder is installed"
else
        echo "[-] assetfinder doesn't exist. Please install it"
        exit 1
fi

if command -v subfinder &>/dev/null; then
        echo "[OK] subfinder is installed"
else
        echo "[-] subfinder doesn't exist. Please install it"
        exit 1
fi

if command -v jq &>/dev/null; then
        echo "[OK] jq is installed"
else
        echo "[-] jq doesn't exist. Please install it"
        exit 1
fi

# Fetching subdomains using sublist3r, assetfinder & subfinder
domain="$1"
filename=subdomains_${domain}.txt

echo -e "\nStarting Subdomain Enumeration..."
echo -e "[+] Fetching subdomains with sublist3r..."
sublist3r -d $domain 2>&1 | tee -a $filename >/dev/null
echo -e "\n[+] Fetching subdomains with assetfinder..."
assetfinder --subs-only $domain 2>&1 | tee -a $filename >/dev/null
echo -e "\n[+] Fetching subdomains with subfinder..."
subfinder -d $domain 2>&1 | tee -a $filename >/dev/null

# Fetching subdomains using from crt.sh
echo -e "\n[+] Fetching subdomains from crt.sh..."

url="https://crt.sh/?q=%25.${domain}&output=json"
subdomains=$(curl -s "$url" | jq -r '.[].name_value' | grep -oE "([a-zA-Z0-9.-]+)\.${domain}" | sort -u)

for subdomain in $subdomains; do
   echo $subdomain 2>&1 | tee -a $filename >/dev/null
done 

echo -e "\nFetched Subdomains: "
# Removing non-domain and duplicate entries.
cat $filename | grep -oE "([a-zA-Z0-9.-]+)\.${domain}" | sed 's/^\.//' | sort -u | tee $filename

total_fetched=$(wc -l "${filename}" | grep -oE "[0-9]+")
echo -e "\n[+] Fetched ${total_fetched} subdomains.\nFetched subdomain are stored in $filename.\nBye"
