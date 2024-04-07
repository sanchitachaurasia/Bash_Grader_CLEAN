#!/bin/bash

source basic.sh
source utils.sh
source git.sh
source stats.sh
source graph.sh

combine() {
    combine_csv_files
}

upload() {
    if [ -n "$1" ]; then
        upload_csv_file "$1"
        if [ $? -eq 0 ]; then
            echo "File uploaded successfully."
        else
            echo "Failed to upload file."
        fi
    else
        echo "Error: No file path provided."
    fi
}

total() {
    add_total_column
}

git_init() {
    if [[ "$#" -ne 1 ]]; then
        echo "Usage: git_init <repo_path>"
        return 1
    fi

    local repo_path="$1"
    init_remote_repo "$repo_path"
}

git_commit() {
    if [[ "$#" -lt 2 ]]; then
        echo "Usage: git_commit -m \"commit message\""
        return 1
    fi
    commit_changes "${@:2}" # Pass only commit message
}

git_checkout() {
    if [[ "$#" -ne 2 ]]; then
        echo "Usage: git_checkout <commit_hash_or_message>"
        return 1
    fi
    checkout_commit "$2"
}

update() {
    update_student_marks
}

stats() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: bash submission.sh stats [mean|median|stddev|student] optional: [column_name]"
        return 1
    fi

    local stat_type="$1"
    shift

    case "$stat_type" in
        mean)
            calculate_mean "${@:1}"
            ;;
        median)
            calculate_median "${@:1}"
            ;;
        mode)
            calculate_mode "${@:1}"
            ;;
        range)
            calculate_range "${@:1}"
            ;;
        variance)
            calculate_variance "${@:1}"
            ;;
        stddev)
            calculate_stddev "${@:1}"
            ;;
        student)
            display_student_marks "${@:1}"
            ;;
        *)
            echo "Invalid statistic type: $stat_type"
            ;;
    esac

    # display_stats "$stat_type" "$@"
}

graph() {
    local graph_type="$1"
    shift

    case "$graph_type" in
        marks)
            generate_marks_graph "${@:1}"
            ;;
        density)
            generate_density_graph "${@:1}"
            ;;
        scatter)
            generate_scatter_graph "${@:1}"
            ;;
        histogram)
            generate_histogram_graph "${@:1}"
            ;;
        box)
            generate_box_graph "${@:1}"
            ;;
        *)
            echo "Invalid graph type: $graph_type"
            ;;
    esac
}

case "$1" in
    combine)
        combine
        ;;
    upload)
        upload "${@:2}"
        ;;
    total)
        total
        ;;
    git_init)
        git_init "${@:2}"
        ;;
    git_commit)
        git_commit "${@:2}"
        ;;
    git_checkout)
        git_checkout "${@:2}"
        ;;
    update)
        update
        ;;
    display)
        display_student_details
        ;;
    stats)
        stats "${@:2}"
        ;;
    graph)
        graph "${@:2}"
        ;;
    *)
        echo "Invalid command. Usage: bash submission.sh <command> [arguments]"
        ;;
esac