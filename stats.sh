#!/bin/bash

calculate_mean() {
    if [ $# -eq 0 ]; then
        read -r header < main.csv
        IFS=',' read -ra headers <<< "$header"
        for ((i = 0; i < ${#headers[@]}; i++)); do
            if [[ "${headers[$i]}" != "Roll_Number" && "${headers[$i]}" != "Name" ]]; then
                calculate_mean "${headers[$i]}"
            fi
        done
    else
        local column_name="$1"
        local column_index=-1

        read -r header < main.csv
        IFS=',' read -ra headers <<< "$header"
        for ((i = 0; i < ${#headers[@]}; i++)); do
            if [[ "${headers[$i]}" == "$column_name" ]]; then
                column_index=$((i + 1))
                break
            fi
        done

        if [[ $column_index -eq -1 ]]; then
            echo "Column '$column_name' not found."
            return 1
        fi

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

calculate_median() {
    if [ $# -eq 0 ]; then
        read -r header < main.csv
        IFS=',' read -ra headers <<< "$header"
        for ((i = 0; i < ${#headers[@]}; i++)); do
            if [[ "${headers[$i]}" != "Roll_Number" && "${headers[$i]}" != "Name" ]]; then
                calculate_median "${headers[$i]}"
            fi
        done
    else
        local column_name="$1"
        local column_index=-1

        read -r header < main.csv
        IFS=',' read -ra headers <<< "$header"
        for ((i = 0; i < ${#headers[@]}; i++)); do
            if [[ "${headers[$i]}" == "$column_name" ]]; then
                column_index=$((i + 1))
                break
            fi
        done

        if [[ $column_index -eq -1 ]]; then
            echo "Column '$column_name' not found."
            return 1
        fi

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

calculate_mode() {
    local column_name="$1"
    local column_index=-1

    read -r header < main.csv
    IFS=',' read -ra headers <<< "$header"
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

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

calculate_range() {
    local column_name="$1"
    local column_index=-1

    read -r header < main.csv
    IFS=',' read -ra headers <<< "$header"
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

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

calculate_variance() {
    local column_name="$1"
    local column_index=-1

    read -r header < main.csv
    IFS=',' read -ra headers <<< "$header"
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

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

calculate_stddev() {
    local column_name="$1"
    local column_index=-1

    read -r header < main.csv
    IFS=',' read -ra headers <<< "$header"
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ "${headers[$i]}" == "$column_name" ]]; then
            column_index=$((i + 1))
            break
        fi
    done

    if [[ $column_index -eq -1 ]]; then
        echo "Column '$column_name' not found."
        return 1
    fi

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

