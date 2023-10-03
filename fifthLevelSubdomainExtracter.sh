#!/bin/bash

DOMAIN=$1
DIRECTORY="${DOMAIN}_fifthLevelExtractor"
mkdir -p "$DIRECTORY"

#subfinder
echo " "
echo "Bullet Train Subfinder"
echo " "
subfinder -d "$DOMAIN" | tee "$DIRECTORY/subfinder.txt"
echo "subfinder done"
echo " "

#findomain
echo " "
echo "Bullet Train Findomain"
echo " "
findomain -t "$DOMAIN" -u "$DIRECTORY/findomain.txt"
echo "findomain done"
echo " "

#arranging files
echo " "
echo "sorting files and output"
cat "$DIRECTORY/subfinder.txt" "$DIRECTORY/findomain.txt" | sort -u | tee "$DIRECTORY/subdomains.txt"
rm -rf "$DIRECTORY/subfinder.txt" "$DIRECTORY/findomain.txt"
echo "sorting files output done"
echo " "

# Extract subdomains 5th level or deeper
echo " "
echo "Extracting 5th level or deeper subdomains"
results=()
while read -r line; do
    if [[ "$line" =~ ^([^.]+\.){4,}[^.]+\.[^.]+$ ]]; then
        results+=("$line")
    fi

done < "$DIRECTORY/subdomains.txt"

# Check if any results were found
if [ ${#results[@]} -eq 0 ]; then
    echo "no 5th level or deeper subdomains found" > "$DIRECTORY/fifthLevelDeeperExtracter.txt"
else
    # Write the results to the output file
    printf "%s\n" "${results[@]}" > "$DIRECTORY/fifthLevelDeeperExtracter.txt"
fi

echo "Extraction complete. Check $DIRECTORY/fifthLevelDeeperExtracter.txt for results."
echo " "

#httpx
echo " "
echo "httpx station train"
echo " "
if [ -f "$DIRECTORY/fifthLevelDeeperExtracter.txt" ]; then
    cat "$DIRECTORY/fifthLevelDeeperExtracter.txt" | httpx | tee "$DIRECTORY/fifthLevelDeeperExtracter_httpx.txt"
    echo " "
    cat "$DIRECTORY/fifthLevelDeeperExtracter_httpx.txt" | httpx -title -status-code -fr -o "$DIRECTORY/fifthLevelDeeperExtracter_httpx_title_statuscode.txt"
else
    echo "subdomains.txt not found in $DIRECTORY. Please make sure it exists."
fi
echo " "