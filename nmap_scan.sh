#!/bin/bash

target=$1

echo "Starting Nmap scan on ${target}..."

echo "[+] Detecting open ports..."
nmap -Pn -p- -T4 target_ip_address -oN output_${target}.txt
echo "[+] Extracting open ports..."
cat output.txt | grep open | awk -F/ '{print $1}’ > open_ports_${target}.txt 
echo "[+] Doing a deeper scan..."
nmap -p open_ports_${target}.txt  -sS -sC -sV -O -A -T4 target_ip_address -oN nmap_final_${target}.txt # The options should be modified based on further need.

echo "[+] Removing unnecessary files..."
rm output_${target}.txt open_ports_${target}.txt

echo -e "\n Output is Stored in nmap_final_${target}.txt"
