#!/bin/bash

# Input files
truncated_file=".top_res_temp.txt"
untruncated_file=".ps_res_temp.txt"

# Load input files
top -l 1 -stats COMMAND > "$truncated_file"
ps aux | awk '{for (i=11; i<=NF; i++) printf $i " "; print ""}' > "$untruncated_file"

# Prepare output file
output_file=$1
if [[ ! "$output_file" =~ [a-zA-Z]+ ]]; then
    output_file="out.txt"
fi
rm -f "$output_file"
touch "$output_file"

# Load output file
start=false
while IFS= read -r truncated_line
do

    # Skip to commands
    if [[ "$truncated_line" == *"COMMAND"* ]]; then
        start=true
        continue
    fi
    if [ "$start" == "false" ]; then
        continue
    fi
    
    # Get untruncated line
    untruncated_line=$(grep -o -m 1 "${truncated_line}[a-zA-Z)]*" "$untruncated_file" | head -n 1)

    # Remove whitespace
    untruncated_line=$(echo "${untruncated_line}" | xargs)
    truncated_line=$(echo "${truncated_line}" | xargs)
    
    # Add untruncated if found else truncated
    if [[ "$untruncated_line" =~ [a-zA-Z]+ ]]; then
        
        # Check for duplicate
        untruncated_in_out=$(grep -o -m 1 "$untruncated_line*" "$output_file" )
        if [[ ! "$untruncated_in_out" =~ [a-zA-Z]+ ]]; then
            echo "$untruncated_line" >> "$output_file"
        fi
    else
        
        # Check for duplicate
        truncated_in_out=$(grep -o -m 1 "$truncated_line*" "$output_file" )
        if [[ ! "$truncated_in_out" =~ [a-zA-Z]+ ]]; then
            echo "$truncated_line" >> "$output_file"
        fi
    fi
    
done < "$truncated_file"

rm "$truncated_file"
rm "$untruncated_file"