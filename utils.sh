#!/bin/bash

display_student_details() {
    while true; do
        echo "Enter student's roll number(or 'exit' to quit):"
        read identifier

        if [[ "$identifier" == "exit" ]]; then
            break
        fi

        matches=$(grep -i "^$identifier" main.csv)
        if [ -z "$matches" ]; then
            suggestions=$(agrep -2 "$identifier" main.csv | cut -d',' -f1,2)
            if [ -n "$suggestions" ]; then
                echo "Doesn't match. Did you mean one of these?"
                echo "$suggestions"
                echo "Please enter again"
                continue
            else
                continue
            fi
        fi

        if (( $(echo "$matches" | wc -l) > 1 )); then
            echo "Multiple matches found. Did you mean one of these?"
            echo "$matches" | cut -d',' -f1,2
            echo "Please enter again"
            continue
        fi

        IFS=',' read -r -a column_names <<< "$(head -n 1 main.csv)"

        while IFS= read -r match; do
            IFS=',' read -r -a student_details <<< "$match"
            for i in "${!column_names[@]}"; do
                printf "%-15s: %s\n" "${column_names[$i]}" "${student_details[$i]}"
            done
            echo
        done <<< "$matches"
    done
}

update_student_marks() {
    while true; do
        echo "Enter student's roll number (or 'exit' to quit):"
        read roll_number

        if [[ "$roll_number" == "exit" ]]; then
            break
        fi

        matches=$(grep -i "^$roll_number" main.csv)
        if [ -z "$matches" ]; then
            suggestions=$(agrep -2 "$roll_number" main.csv | cut -d',' -f1,2)
            if [ -n "$suggestions" ]; then
                echo "Doesn't match. Did you mean one of these?"
                echo "$suggestions"
                echo "Please enter again"
                continue
            else
                continue
            fi
        fi

        if (( $(echo "$matches" | wc -l) > 1 )); then
            echo "Multiple matches found. Did you mean one of these?"
            echo "$matches" | cut -d',' -f1,2
            echo "Please enter again"
            continue
        fi

        name=$(awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $2}' main.csv)
        echo "You are updating the marks for $name. Continue? (y/n)"
        read confirm
        if [[ "$confirm" =~ ^[nN]$ ]]; then
            continue
        fi

        echo "Choose update mode: (1) Interactive mode (2) Name mode"
        read mode

        name=$(awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $2}' main.csv)

        if [ "$mode" == "1" ]; then
            header=$(head -n 1 main.csv)
            IFS=',' read -ra cols <<< "$header"
            for index in "${!cols[@]}"; do
                if [ "$index" -gt 1 ]; then
                    echo "Enter new marks for ${cols[$index]} (or 'n' for no change, 'a' for absent):"
                    read marks
                    if [ "$marks" != "n" ]; then
                        old_marks=$(awk -v roll=$roll_number -v idx=$index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $((idx+1))}' main.csv)
                        awk -v roll=$roll_number -v mark=$marks -v idx=$index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$((idx+1))=mark} 1' main.csv > temp.csv && mv temp.csv main.csv
                        if [ -f "${cols[$index]}.csv" ]; then
                            if [ "$old_marks" == "a" ] && [ "$marks" != "a" ]; then
                                echo "$roll_number,$name,$marks" >> ${cols[$index]}.csv
                            elif [ "$old_marks" != "a" ] && [ "$marks" == "a" ]; then
                                awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)!=tolower(roll)' ${cols[$index]}.csv > temp.csv && mv temp.csv ${cols[$index]}.csv
                            elif [ "$old_marks" != "a" ] && [ "$marks" != "a" ]; then
                                awk -v roll=$roll_number -v mark=$marks -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$3=mark} 1' ${cols[$index]}.csv > temp.csv && mv temp.csv ${cols[$index]}.csv
                            fi
                        fi
                    fi
                fi
            done
        elif [ "$mode" == "2" ]; then
            echo "Enter the name of the column to update:"
            read column_name
            echo "Enter new marks for $column_name (or 'a' for absent):"
            read marks
            col_index=$(awk -F, 'NR==1 {for(i=1;i<=NF;i++) {if(tolower($i)==tolower(col_name)) print i}}' col_name=$column_name main.csv)
            old_marks=$(awk -v roll=$roll_number -v idx=$col_index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {print $idx}' main.csv)
            awk -v roll=$roll_number -v mark=$marks -v idx=$col_index -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$idx=mark} 1' main.csv > temp.csv && mv temp.csv main.csv
            if [ -f "$column_name.csv" ]; then
                if [ "$old_marks" == "a" ] && [ "$marks" != "a" ]; then
                    echo "$roll_number,$name,$marks" >> $column_name.csv
                elif [ "$old_marks" != "a" ] && [ "$marks" == "a" ]; then
                    awk -v roll=$roll_number -F, 'BEGIN{OFS=","} tolower($1)!=tolower(roll)' $column_name.csv > temp.csv && mv temp.csv $column_name.csv
                elif [ "$old_marks" != "a" ] && [ "$marks" != "a" ]; then
                    awk -v roll=$roll_number -v mark=$marks -F, 'BEGIN{OFS=","} tolower($1)==tolower(roll) {$3=mark} 1' $column_name.csv > temp.csv && mv temp.csv $column_name.csv
                fi
            fi
        fi
    done
}
