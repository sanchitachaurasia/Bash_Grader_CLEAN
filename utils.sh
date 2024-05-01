#!/bin/bash

# Import the functions from the basic.sh script
source basic.sh
# Import color codes from the bash_colors.sh script
source bash_colors.sh

# The display_student_details function in the script prompts the user for a student's roll number and 
# then displays the details of the student from a CSV file. If the roll number doesn't match any students, 
# it suggests similar roll numbers. If multiple matches are found, it displays all of them and 
# asks the user to enter the roll number again.
display_student_details() {
    # Start an infinite loop
    while true; do
        # Ask the user to enter a student's roll number
        echo -e "${GREEN}Enter student's roll number(or 'exit' to quit):${NC}"
        read identifier

        # If the user enters 'exit', break the loop and end the function
        if [[ "$identifier" == "exit" ]]; then
            break
        fi

        # Search for the entered roll number at the start of a line in the main.csv file
        # The -i option makes the search case-insensitive
        matches=$(grep -i "^$identifier" main.csv)

        # If no matches were found
        if [ -z "$matches" ]; then
            # Use agrep to find similar roll numbers in the main.csv file
            # The -2 option allows up to 2 errors for a match (insertions, deletions or substitutions)
            # The cut command extracts the roll number and name from the matching lines
            suggestions=$(agrep -1 "$identifier" main.csv | cut -d',' -f1,2)

            # If there are any suggestions
            if [ -n "$suggestions" ]; then
                # Inform the user that the entered roll number doesn't match any students
                echo -e "${RED}Doesn't match. Did you mean one of these?${NC}"
                # Display the suggestions
                echo "$suggestions"
                echo "Please enter again"
                # Skip the rest of this loop iteration and start the next one
                continue
            else
                # If there are no suggestions, skip the rest of this loop iteration and start the next one
                continue
            fi
        fi

        # If more than one match was found
        if (( $(echo "$matches" | wc -l) > 1 )); then
            # Inform the user that multiple matches were found
            echo "${RED}Multiple matches found. Did you mean one of these?${NC}"
            # Display the matches
            echo "$matches" | cut -d',' -f1,2
            echo "Please enter again"
            # Skip the rest of this loop iteration and start the next one
            continue
        fi

        # Read the first line of the main.csv file, which contains the column names, into an array
        IFS=',' read -r -a column_names <<< "$(head -n 1 main.csv)"

        # For each match
        while IFS= read -r match; do
            # Split the match into an array of student details
            IFS=',' read -r -a student_details <<< "$match"
            # For each column name
            for i in "${!column_names[@]}"; do
                # Print the column name and the corresponding student detail
                printf "${YELLOW}%-15s:${NC} %s\n" "${column_names[$i]}" "${student_details[$i]}"
            done
            # Print a blank line for separation
            echo
        done <<< "$matches"
    done
}

# The update_student_marks function in the script allows a user to update student marks in a CSV file. 
# It prompts the user for a student's roll number, finds the student in the CSV file, and 
# then allows the user to update the student's marks either for all subjects (Interactive mode) 
# or a specific subject (Name mode). 
# If a 'total' column exists, it also updates the total marks for the student.
update_student_marks() {
    # Check if the main.csv file exists and if it contains a 'total' column
    # If it does, set total_exists to true, otherwise set it to false
    if [ -f main.csv ] && head -n 1 main.csv | grep -q 'total'; then
        total_exists=true
    else
        total_exists=false
    fi

    # Start an infinite loop
    while true; do
        # Ask the user to enter a student's roll number
        echo "Enter student's roll number (or 'exit' to quit):"
        read roll_number

        # If the user enters 'exit', break the loop and end the function
        if [[ "$roll_number" == "exit" ]]; then
            break
        fi

        # Search for the entered roll number at the start of a line in the main.csv file
        # The -i option makes the search case-insensitive
        matches=$(grep -i "^$roll_number" main.csv)

        # If no matches were found
        if [ -z "$matches" ]; then
            # Use agrep to find similar roll numbers in the main.csv file
            # The -2 option allows up to 2 errors for a match (insertions, deletions or substitutions)
            # The cut command extracts the roll number and name from the matching lines
            suggestions=$(agrep -1 "$roll_number" main.csv | cut -d',' -f1,2)

            # If there are any suggestions
            if [ -n "$suggestions" ]; then
                # Inform the user that the entered roll number doesn't match any students
                echo "Doesn't match. Did you mean one of these?"
                # Display the suggestions
                echo "$suggestions"
                echo "Please enter again"
                # Skip the rest of this loop iteration and start the next one
                continue
            else
                # If there are no suggestions, skip the rest of this loop iteration and start the next one
                continue
            fi
        fi

        # If more than one match was found
        if (( $(echo "$matches" | wc -l) > 1 )); then
            # Inform the user that multiple matches were found
            echo "Multiple matches found. Did you mean one of these?"
            # Display the matches
            echo "$matches" | cut -d',' -f1,2
            echo "Please enter again"
            # Skip the rest of this loop iteration and start the next one
            continue
        fi

        # Use awk to extract the name of the student with the entered roll number from the main.csv file
        name=$(awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $2}' main.csv)

        # Ask the user to confirm that they want to update the marks for the student
        echo "You are updating the marks for $name. Continue? (y/n)"
        read confirm

        # If the user enters 'n' or 'N', skip the rest of this loop iteration and start the next one
        if [[ "$confirm" =~ ^[nN]$ ]]; then
            continue
        fi

        # Ask the user to choose an update mode
        echo "Choose update mode: (1) Interactive mode (2) Name mode"
        read mode

        # Use awk to extract the name of the student with the entered roll number from the main.csv file
        name=$(awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $2}' main.csv)

        # If the user chose interactive mode
        if [ "$mode" == "1" ]; then
            # Read the first line of the main.csv file, which contains the column names, into an array
            header=$(head -n 1 main.csv)
            IFS=',' read -ra cols <<< "$header"
            # The -r option prevents backslashes from acting as escape characters, and the -a option reads the input into an array

            # For each column name
            for index in "${!cols[@]}"; do
                # If the column is not the roll number, name, or total column
                if [ "$index" -gt 1 ] && [ "${cols[$index]}" != "total" ]; then
                    # Ask the user to enter new marks for the column
                    echo "Enter new marks for ${cols[$index]} (or 'n' for no change, 'a' for absent):"
                    read marks

                    # If the user didn't enter 'n'
                    if [ "$marks" != "n" ]; then
                        # Use awk to extract the old marks for the column from the main.csv file
                        old_marks=$(awk -v roll=$roll_number -v idx=$index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $((idx+1))}' main.csv)
                        #v is used to assign a value to a variable before execution
                        # Use awk to replace the old marks with the new marks in the main.csv file
                        awk -v roll=$roll_number -v mark=$marks -v idx=$index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$((idx+1))=mark} 1' main.csv > temp.csv && mv temp.csv main.csv

                        # If a CSV file for the column exists
                        if [ -f "${cols[$index]}.csv" ]; then
                            # If the student was absent and is now present
                            if [ "$old_marks" == "a" ] && [ "$marks" != "a" ]; then
                                # Add the student's roll number, name, and marks to the CSV file
                                echo "$roll_number,$name,$marks" >> ${cols[$index]}.csv
                            # If the student was present and is now absent
                            elif [ "$old_marks" != "a" ] && [ "$marks" == "a" ]; then
                                # Remove the student from the CSV file
                                awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)!=tolower(roll)' ${cols[$index]}.csv > temp.csv && mv temp.csv ${cols[$index]}.csv
                            # If the student was present and is still present
                            elif [ "$old_marks" != "a" ] && [ "$marks" != "a" ]; then
                                # Update the student's marks in the CSV file
                                awk -v roll=$roll_number -v mark=$marks -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$3=mark} 1' ${cols[$index]}.csv > temp.csv && mv temp.csv ${cols[$index]}.csv
                            fi
                        fi
                    fi
                fi
            done
        # If the user chose name mode
        elif [ "$mode" == "2" ]; then
            # Ask the user to enter the name of the column to update
            echo "Enter the name of the column to update:"
            read column_name

            # If the column is not the total column
            if [ "$column_name" != "total" ]; then
                # Ask the user to enter new marks for the column
                echo "Enter new marks for $column_name (or 'a' for absent):"
                read marks

                # Use awk to find the index of the column in the main.csv file
                col_index=$(awk -F, 'NR==1 {for(i=1;i<=NF;i++) {if(tolower($i)==tolower(col_name)) print i}}' col_name=$column_name main.csv)

                # Use awk to extract the old marks for the column from the main.csv file
                old_marks=$(awk -v roll=$roll_number -v idx=$col_index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $idx}' main.csv)

                # Use awk to replace the old marks with the new marks in the main.csv file
                awk -v roll=$roll_number -v mark=$marks -v idx=$col_index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$idx=mark} 1' main.csv > temp.csv && mv temp.csv main.csv

                # If a CSV file for the column exists
                if [ -f "$column_name.csv" ]; then
                    # If the student was absent and is now present
                    if [ "$old_marks" == "a" ] && [ "$marks" != "a" ]; then
                        # Add the student's roll number, name, and marks to the CSV file
                        echo "$roll_number,$name,$marks" >> $column_name.csv
                    # If the student was present and is now absent
                    elif [ "$old_marks" != "a" ] && [ "$marks" == "a" ]; then
                        # Remove the student from the CSV file
                        awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)!=tolower(roll)' $column_name.csv > temp.csv && mv temp.csv $column_name.csv
                    # If the student was present and is still present
                    elif [ "$old_marks" != "a" ] && [ "$marks" != "a" ]; then
                        # Update the student's marks in the CSV file
                        awk -v roll=$roll_number -v mark=$marks -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$3=mark} 1' $column_name.csv > temp.csv && mv temp.csv $column_name.csv
                    fi
                fi
            fi
        fi

        # If the total column exists
        if [ "$total_exists" = true ]; then
            # Update the total column
            add_total_column
        fi
    done
}
