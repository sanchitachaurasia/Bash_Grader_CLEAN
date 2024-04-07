combine_csv_files() {
    declare -A students

    declare -a columns=("Roll_Number" "Name")

    if [ -f main.csv ] && head -n 1 main.csv | grep -q 'total'; then
        total_exists=true
    else
        total_exists=false
    fi

    for file in *.csv; do
        if [ "$file" == "main.csv" ]; then
            continue
        fi

        column_name="${file%.*}"
        columns+=("$column_name")

        while IFS=, read -r roll_number name marks; do
            if [[ -z ${students[$roll_number]} ]]; then
                students[$roll_number]="$roll_number,$name"
            fi
            if [[ -z $marks ]]; then
                students[$roll_number]+=",a"
            else
                students[$roll_number]+=",$marks"
            fi
        done < <(tail -n +2 "$file")
    done

    IFS=','; echo "${columns[*]}" > main.csv

    for data in "${students[@]}"; do
        echo "$data" >> main.csv
    done

    if [ "$total_exists" = true ]; then
        add_total_column
    fi
}

upload_csv_file() {
    local file_path="$1"
    local file_name=$(basename "$file_path")

    if [ -f "$file_name" ]; then
        read -p "$file_name already exists. Do you want to overwrite it? (y/n) " -n 1 -r   #read -p is used to prompt the user for confirmation. The -n 1 option specifies that read should return after reading a single character, and -r prevents backslashes from being interpreted as escape characters
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$file_path" .
        fi
    else
        cp "$file_path" .
    fi
}

add_total_column() {
    if head -n 1 main.csv | grep -q 'total'; then
        awk 'BEGIN { FS=OFS="," } 
            {
                gsub("\r", ""); 
                if (NR == 1) {
                    print $0;
                } else {
                    total = 0;
                    for (i = 3; i < NF; i++) {
                        if ($i != "total") {
                            mark = ($i == "a" || $i == "" ? 0 : $i);
                            total += mark;
                        }
                    }
                    $NF = total;
                    print $0;
                }
            }
        ' main.csv > temp.csv && mv temp.csv main.csv
    else
        awk 'BEGIN { FS=OFS="," } 
            {
                gsub("\r", ""); 
                if (NR == 1) {
                    print $0, "total";
                } else {
                    total = 0;
                    for (i = 3; i <= NF; i++) {
                        mark = ($i == "a" || $i == "" ? 0 : $i);
                        total += mark;
                    }
                    print $0, total;
                }
            }
        ' main.csv > temp.csv && mv temp.csv main.csv
    fi
}