# Sanchita Chaurasia
#!/bin/bash

# Color codes
source bash_colors.sh

# combine_csv_files: This function combines multiple CSV files into a single CSV file named main.csv.
# It assumes that each CSV file has columns for "Roll_Number", "Name", and "marks".
# The function reads each CSV file, adds a new column to main.csv for each file,
# and populates the new column with the marks from the corresponding file.
# If a student is not present in a file, an "a" is added to their row in the new column.
# If the main.csv file already contains a 'total' column, the function updates the totals.
combine_csv_files() {
    # Declare associative arrays to store student data and presence
    declare -A students
    declare -A present

    # Declare an array to store column names
    declare -a columns=("Roll_Number" "Name")
    declare -a student_data

    # Check if the main.csv file exists and contains a 'total' column
    if [ -f main.csv ] && head -n 1 main.csv | grep -q 'total'; then
        total_exists=true
    else
        total_exists=false
    fi

    # Single pass: go through each CSV file and add the marks or "a" for each student
    for file in *.csv; do
        # Skip the main.csv file
        if [ "$file" == "main.csv" ]; then
            continue
        fi

        # Extract the column name from the file name
        column_name="${file%.*}"
        # %.*: Matches any string that starts with a dot (.).
        # The %.* pattern removes the shortest match of .* (i.e., the file extension) from the end of the string.

        # Add the column name to the columns array
        columns+=("$column_name")

        # Initialize present array
        # Initially, empty in first iteration
        for roll_number in "${!students[@]}"; do
            present[$roll_number]=false
        done

        # Read the CSV file line by line
        while IFS=, read -r roll_number name marks; do
            # If the student is not already in the students array, add them
            if [[ -z ${students[$roll_number]} ]]; then # -z: checks if the variable is empty
                students[$roll_number]="$roll_number,$name"
                for ((i=2; i<${#columns[@]}-1; i++)); do # ${#columns[@]}: length of the columns array
                    students[$roll_number]+=",a" # Appends ",a" to the student's data in the students array. This is done for each column that has been processed so far.
                done
            fi
            # Add the marks to the student's data
            students[$roll_number]+=",$marks"
            # Mark the student as present in this file
            present[$roll_number]=true
        done < <(tail -n +2 "$file") # tail -n +2: prints the file starting from the second line

        # Add "a" for students not present in this file
        for roll_number in "${!students[@]}"; do
            if [ "${present[$roll_number]}" = false ]; then 
                students[$roll_number]+=",a"
            fi
        done
    done

    # Write the column names to the main.csv file
    IFS=','; printf "%s\n" "${columns[*]}" > main.csv #%s\n format string tells printf to print each element of the array as a string followed by a newline.
    # The ${columns[*]} syntax is used to get all elements of the columns array. When used with IFS=',', this will join all elements of the columns array with a comma.

    # Add the student data to the main.csv file
    for data in "${students[@]}"; do
        student_data+=("$data")
    done

    printf "%s\n" "${student_data[@]}" >> main.csv

    # If the 'total' column existed in the original main.csv file, add it back
    if [ "$total_exists" = true ]; then
        add_total_column
    fi
}

# upload_csv_file: This function uploads a CSV file to the current directory.
# It first checks if the file path provided is not empty and the file exists.
# If the file already exists in the current directory, it asks the user if they want to overwrite it.
# If the user agrees, it overwrites the file; otherwise, it leaves the existing file unchanged.
# If the file does not exist in the current directory, it simply copies the file to the current directory.
upload_csv_file() {
    # Store the file path in a variable
    local file_path="$1"

    # Check if file path is not empty and file exists
    if [[ -z "$file_path" || ! -f "$file_path" ]]; then
        echo -e "${RED}Invalid file path provided: $file_path${NC}"
        return 1
    fi

    # Extract the file name from the file path
    local file_name=$(basename "$file_path")

    # Check if the file already exists in the current directory
    if [ -f "$file_name" ]; then
        # If the file exists, ask the user if they want to overwrite it
        read -p "$file_name already exists in the current directory. Do you want to overwrite it? (y/n) " -n 1 -r
        # -p: to specify a prompt that will be displayed before the input
        # -n 1: to limit the input to a single character
        # -r: to prevent backslashes from being interpreted as escape characters
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # $REPLY: default variable that read uses to store the input if no variable name is provided.
            # If the user wants to overwrite the file, copy the new file over the old one
            cp "$file_path" . && echo -e "${GREEN}$file_name has been overwritten.${NC}" || echo -e "${RED}Failed to overwrite $file_name.${NC}"
            # &&: executed only if the command before && succeeds (returns a zero exit status).
            # ||: executed only if the command before || fails (returns a non-zero exit status).
        fi
    else
        # If the file does not exist, copy it to the current directory
        cp "$file_path" . && echo -e "${GREEN}$file_name has been uploaded.${NC}" || echo -e "${RED}Failed to upload $file_name.${NC}"
        # &&: executed only if the command before && succeeds (returns a zero exit status).
        # ||: executed only if the command before || fails (returns a non-zero exit status).
    fi
}

# add_total_column: This function adds a 'total' column to the main.csv file.
# If the 'total' column already exists, it updates the totals.
# If the 'total' column does not exist, it adds the column and calculates the totals.
# The totals are calculated as the sum of all marks, with 'a' or empty marks counted as 0.
add_total_column() {
    # Check if the main.csv file contains a 'total' column
    if head -n 1 main.csv | grep -q 'total'; then
        # If the 'total' column exists, update it with the new totals
        awk 'BEGIN { FS=OFS="," }  # Set the field separator and output field separator to comma
            {
                gsub("\r", "");  # Remove carriage return characters
                if (NR == 1) { 
                # NR: number of records (lines)
                    print $0;  # Print the line as is
                } else {
                    total = 0;  # Initialize total to 0
                    for (i = 3; i < NF; i++) {  # Loop through all fields starting from the third
                        if ($i != "total") {  # If the field is not 'total'
                            mark = ($i == "a" || $i == "" ? 0 : $i); # || - logical OR operation; ? 0 : $i: This is a ternary operator, which is a shorthand for an if-else statement. If the condition before the ? is true (i.e., $i is "a" or an empty string), it evaluates to the value before the :. If the condition is false, it evaluates to the value after the :
                            total += mark;  # Add the mark to the total
                        }
                    }
                    $NF = total;  # Set the last field to the total
                    print $0;  # Print the line
                }
            }
        ' main.csv > temp.csv && mv temp.csv main.csv  # Write the output to a temporary file and then replace the original file with the temporary file
    else
        # If the 'total' column does not exist, add it and calculate the totals
        awk 'BEGIN { FS=OFS="," } 
            {
                gsub("\r", ""); 
                if (NR == 1) {
                    print $0, "total";  # Add 'total' to the header
                } else {
                    total = 0;
                    for (i = 3; i <= NF; i++) {
                        mark = ($i == "a" || $i == "" ? 0 : $i);
                        total += mark;  # Add the mark to the total
                    }
                    print $0, total;  # Add the total to the end of the line
                }
            }
        ' main.csv > temp.csv && mv temp.csv main.csv  # Write the output to a temporary file and then replace the original file with the temporary file
    fi
}

#USAGE:
# combine
# upload "file_path"
# total

#ASSUMPTIONS:
#1. The CSV files have the same format with columns "Roll_Number", "Name", and "Marks".
#2. The "Marks" column contains numerical values or "a" for absent students.
#3. The script assumes that it has read and write permissions for the current directory and all CSV files in it. If it doesn't, commands like cp and mv could fail.
#4. The script does not handle cases where the CSV files have different column names or formats. It assumes uniformity in the structure of the CSV files.
#5. awk compatibility

#TODO-DONE:
#1. Define three main functions (combine_csv_files, upload_csv_file, add_total_column)
#2. Implement upload_csv_file: basic functionality of copying a file to the current directory and added error handling for invalid file paths.
#3. Implement combine_csv_files: read each CSV file and store the data in an associative array. Write the combined data to main.csv.
#4. Implement add_total_column: add a 'total' column to the main.csv file and calculate the totals.
#5. error handling to the combine_csv_files and add_total_column functions: cases where main.csv doesn't exist or has a 'total' column.
#6: Improve upload_csv_file: to handle the case where the file already exists in the current directory. Ask the user if they want to overwrite the existing file.
#7. Add color codes for better output formatting.
#8. Add better comments to explain the purpose and logic of each function.
#TODO:
#9. Final Testing & Usage Instructions in README.md

# Sanchita Chaurasia