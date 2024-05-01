#!/bin/bash

# Function to calculate the mean of a column in a CSV file
calculate_mean() {
    # If no arguments are provided, calculate the mean for all columns except "Roll_Number" and "Name"
    if [ $# -eq 0 ]; then
        # Read the first line of the CSV file into 'header'
        read -r header < main.csv
        # Split 'header' into an array 'headers' using ',' as the delimiter
        IFS=',' read -ra headers <<< "$header"
        # Loop over the indices of 'headers'
        for ((i = 0; i < ${#headers[@]}; i++)); do
            # If the current header is not "Roll_Number" and not "Name"
            if [[ "${headers[$i]}" != "Roll_Number" && "${headers[$i]}" != "Name" ]]; then
                # Call this function recursively with the current header as the argument
                calculate_mean "${headers[$i]}"
            fi
        done
    else
        # If an argument is provided, calculate the mean for the specified column
        local column_name="$1"
        local column_index=-1

        # Read the first line of the CSV file into 'header'
        read -r header < main.csv
        # Split 'header' into an array 'headers' using ',' as the delimiter
        IFS=',' read -ra headers <<< "$header"
        # Loop over the indices of 'headers'
        for ((i = 0; i < ${#headers[@]}; i++)); do
            # If the current header is equal to 'column_name'
            if [[ "${headers[$i]}" == "$column_name" ]]; then
                # Set 'column_index' to the current index plus one
                column_index=$((i + 1))
                break
            fi
        done

        # If 'column_index' is still -1, the column was not found
        if [[ $column_index -eq -1 ]]; then
            echo "Column '$column_name' not found."
            return 1
        fi

        # Use awk to calculate the mean of the column
        awk -v col="$column_index" '
            BEGIN {
                FS=","
                sum = 0
                count = 0
            }
            NR > 1 {
                count++
                if ($col != "a") {
                    sum += $col
                }
            }
            END {
                if (count > 0) {
                    printf "Mean for %s: %.3f\n", col_name, sum / count
                } else {
                    print "No valid data found in column " col_name
                }
            }
        ' col_name="$column_name" main.csv
    fi
}

# Function to calculate the median of a column in a CSV file
calculate_median() {
    # If no arguments are provided, calculate the median for all columns except "Roll_Number" and "Name"
    if [ $# -eq 0 ]; then
        # Read the header line from the CSV file
        read -r header < main.csv
        # Split the header line into an array of column names
        IFS=',' read -ra headers <<< "$header"
        # Loop over each column name
        for ((i = 0; i < ${#headers[@]}; i++)); do
            # If the column name is not "Roll_Number" and not "Name", calculate the median for this column
            if [[ "${headers[$i]}" != "Roll_Number" && "${headers[$i]}" != "Name" ]]; then
                calculate_median "${headers[$i]}"
            fi
        done
    else
        # If an argument is provided, calculate the median for the specified column
        local column_name="$1"
        local column_index=-1

        # Read the header line from the CSV file
        read -r header < main.csv
        # Split the header line into an array of column names
        IFS=',' read -ra headers <<< "$header"
        # Loop over each column name to find the index of the specified column
        for ((i = 0; i < ${#headers[@]}; i++)); do
            if [[ "${headers[$i]}" == "$column_name" ]]; then
                column_index=$((i + 1))
                break
            fi
        done

        # If the column is not found, print an error message and return 1
        if [[ $column_index -eq -1 ]]; then
            echo "Column '$column_name' not found."
            return 1
        fi

        # Use awk to calculate the median of the specified column
        awk -v col="$column_index" '
            BEGIN {
                FS=","
                count = 0
            }
            NR > 1 {
                if ($col != "a") {
                    marks_array[count++] = $col
                }
            }
            END {
                if (count > 0) {
                    asort(marks_array)
                    median_index = int(count / 2)
                    if (count % 2 == 0) {
                        median = (marks_array[median_index] + marks_array[median_index + 1]) / 2
                    } else {
                        median = marks_array[median_index + 1]
                    }
                    printf "Median for %s: %.3f\n", col_name, median
                } else {
                    print "No valid data found in column " col_name
                }
            }
        ' col_name="$column_name" main.csv
    fi
}

# Function to calculate the mode of a column in a CSV file
calculate_mode() {
    # The argument is the name of the column
    local column_name="$1"
    local column_index=-1

    # Read the header line from the CSV file
    read -r header < main.csv
    # Split the header line into an array of column names
    IFS=',' read -ra headers <<< "$header"
    # Loop over each column name to find the index of the specified column
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    # If the column is not found, print an error message and return 1
    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

    # Use awk to calculate the mode of the specified column
    awk -v col="$column_index" '
        BEGIN {
            FS=","
            max_count = 0
        }
        NR > 1 {
            if ($col != "a") {
                counts[$col]++
                if (counts[$col] > max_count) {
                    max_count = counts[$col]
                    mode = $col
                }
            }
        }
        END {
            if (max_count > 1) {
                printf "Mode for %s: %s\n", col_name, mode
            } else {
                print "No mode found for column " col_name
            }
        }
    ' col_name="$column_name" main.csv
}

# Function to calculate the range of a column in a CSV file
calculate_range() {
    # The argument is the name of the column
    local column_name="$1"
    local column_index=-1

    # Read the header line from the CSV file
    read -r header < main.csv
    # Split the header line into an array of column names
    IFS=',' read -ra headers <<< "$header"
    # Loop over each column name to find the index of the specified column
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    # If the column is not found, print an error message and return 1
    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

    # Use awk to calculate the range of the specified column
    awk -v col="$column_index" '
        BEGIN {
            FS=","
            min_value = "inf"
            max_value = "-inf"
        }
        NR > 1 {
            if ($col != "a" && $col < min_value) {
                min_value = $col
            }
            if ($col != "a" && $col > max_value) {
                max_value = $col
            }
        }
        END {
            if (min_value != "inf" && max_value != "-inf") {
                printf "Range for %s: %s [%s,%s]\n", col_name, max_value - min_value, min_value, max_value
            } else {
                print "Insufficient data available in column " col_name " for calculating range"
            }
        }
    ' col_name="$column_name" main.csv
}

# Function to calculate the variance of a column in a CSV file
calculate_variance() {
    # The argument is the name of the column
    local column_name="$1"
    local column_index=-1

    # Read the header line from the CSV file
    read -r header < main.csv
    # Split the header line into an array of column names
    IFS=',' read -ra headers <<< "$header"
    # Loop over each column name to find the index of the specified column
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    # If the column is not found, print an error message and return 1
    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

    # Use awk to calculate the variance of the specified column
    awk -v col="$column_index" '
        BEGIN {
            FS=","
            sum = 0
            sum_squared = 0
            count = 0
        }
        NR > 1 {
            if ($col != "a") {
                sum += $col
                sum_squared += ($col * $col)
                count++
            }
        }
        END {
            if (count > 1) {
                mean = sum / count
                variance = (sum_squared / count) - (mean * mean)
                printf "Variance for %s: %.2f\n", col_name, variance
            } else {
                print "Insufficient data available in column " col_name " for calculating variance"
            }
        }
    ' col_name="$column_name" main.csv
}

# Function to calculate the standard deviation of a column in a CSV file
calculate_stddev() {
    # If no arguments are provided, calculate the standard deviation for all columns except "Roll_Number" and "Name"
    if [ "$#" -eq 0 ]; then
        local header
        IFS=',' read -r -a header < main.csv
        for column_name in "${header[@]:2}"; do
            if [ "$column_name" != "total" ]; then
                calculate_stddev "$column_name"
            fi
        done
        return 1
    fi

    # The argument is the name of the column
    local column_name="$1"
    local column_index=-1

    # Read the header line from the CSV file
    read -r header < main.csv
    # Split the header line into an array of column names
    IFS=',' read -ra headers <<< "$header"
    # Loop over each column name to find the index of the specified column
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    # If the column is not found, print an error message and return 1
    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

    # Use awk to calculate the standard deviation of the specified column
    awk -v col="$column_index" '
        BEGIN {
            FS=","
            sum = 0
            count = 0
            square_sum = 0
        }
        NR > 1 {
            if ($col != "a") {
                sum += $col
                square_sum += ($col * $col)
                count++
            }
        }
        END {
            if (count > 1) {
                mean = sum / count
                variance = (square_sum / count) - (mean * mean)
                stddev = sqrt(variance)
                printf "Standard deviation for %s: %.3f\n", col_name, stddev
            } else {
                print "Insufficient data available in column " col_name " for calculating standard deviation"
            }
        }
    ' col_name="$column_name" main.csv
}

# Function to calculate percentiles of a column in a CSV file
calculate_percentiles() {
    # Define the file name and the percentiles to calculate
    local file="main.csv"
    local percentile1=75
    local percentile2=50

    # Get the column names from the first line of the file
    local column_names=( $(head -1 "$file" | tr ',' ' ') )

    # Loop over all columns except 'total', starting from the third column
    for ((i=2; i<${#column_names[@]}; i++)); do
        local column_name="${column_names[$i]}"
        # Skip the 'total' column
        if [ "$column_name" != "total" ]; then
            echo "Column: $column_name"
            # Calculate the 75th and 50th percentiles for the current column
            calculate_percentile "$file" "$column_name" "$percentile1"
            calculate_percentile "$file" "$column_name" "$percentile2"
            # Allow the user to calculate additional percentiles for the current column
            while true; do
                read -p "Enter another percentile for $column_name or 'exit' to move on: " percentile
                if [ "$percentile" = "exit" ]; then
                    break
                elif [[ $percentile =~ ^[0-9]+$ ]]; then
                    calculate_percentile "$file" "$column_name" "$percentile"
                else
                    echo "Invalid input. Please enter a number or 'exit'."
                fi
            done
        fi
    done
}

# Function to calculate a specific percentile of a column in a CSV file
calculate_percentile() {
    # The arguments are the file name, the column name, and the percentile to calculate
    local file="$1"
    local column_name="$2"
    local percentile="$3"

    # Get the index of the column in the file
    local column_index=$(head -1 "$file" | tr ',' '\n' | grep -n -x "$column_name" | cut -d: -f1)

    # Sort the values in the column, skipping the header row and non-numeric values
    local sorted_numbers=$(awk -F, -v col="$column_index" 'NR>1 && $col ~ /^[0-9]+(\.[0-9]+)?$/ {print $col}' "$file" | sort -n)

    # Calculate the index that corresponds to the percentile
    local index=$(echo "$sorted_numbers" | wc -l | awk -v percentile="$percentile" '{print int($1 * percentile / 100 + 0.5)}')

    # Ensure the index is at least 1
    if [ "$index" -lt 1 ]; then
        index=1
    fi

    # Find the value at the index
    local percentile_value=$(echo "$sorted_numbers" | sed -n "${index}p")

    echo "$column_name $percentile percentile: $percentile_value"
}

