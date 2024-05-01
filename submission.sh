#!/bin/bash

# Import the necessary scripts. These scripts contain functions that will be used in this script.
source basic.sh
source utils.sh
source git_basic.sh
source git_custom.sh
source stats.sh
source graph.sh
source bash_colors.sh

# Define a function that combines CSV files.
combine() {
    # The combine_csv_files function is called here.
    combine_csv_files
}

# Define a function that uploads a CSV file.
upload() {
    # Check if a file path is provided as an argument.
    if [ -n "$1" ]; then
        # If a file path is provided, call the upload_csv_file function with the file path.
        upload_csv_file "$1"
        # Check if the upload was successful.
        if [ $? -eq 0 ]; then
            # If the upload was successful, print a success message.
            echo -e "${GREEN}File uploaded successfully.${NC}"
        else
            # If the upload failed, print an error message.
            echo -e "${RED}Failed to upload file.${NC}"
        fi
    else
        # If no file path is provided, print an error message.
        echo -e "${RED}Error: No file path provided.${NC}"
    fi
}

# Define a function that adds a total column to the CSV file.
total() {
    # The add_total_column function is called here.
    add_total_column
}

# Define a function that updates student marks.
update() {
    # The update_student_marks function is called here.
    update_student_marks
}

sinit() {
    if [[ "$#" -ne 1 ]]; then
        echo "Usage: init <repo_path>"
        return 1
    fi

    local repo_path="$1"
    init_remote_repo "$repo_path"
}

scommit() {
    if [[ "$#" -lt 2 ]]; then
        echo "Usage: commit -m \"commit message\""
        return 1
    fi
    commit_changes "${@:2}" # Pass only commit message
}

scheckout() {
    if [[ "$#" -ne 1 ]]; then
        echo "Usage: checkout <commit_hash_or_message>"
        return 1
    fi
    checkout_commit "$1"
}

sgraph() {
    if [[ "$#" -ne 0 ]]; then
        echo "Usage: commit_graph"
        return 1
    fi
    commit_graph
}

# Define a function that calculates statistics.
stats() {
    # Check if any arguments are provided.
    if [ "$#" -lt 1 ]; then
        # If no arguments are provided, calculate the mean, median, and standard deviation for all columns.
        echo -e "${YELLOW}Calculating mean, median, and standard deviation for all columns:${NC}"
        calculate_mean
        calculate_median
        calculate_stddev
        return 1
    fi

    # Store the first argument in a variable.
    local stat_type="$1"
    # Shift the arguments to the left.
    shift

    # Depending on the value of stat_type, call the corresponding function.
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
        percentile)
            calculate_percentiles "${@:1}"    
            ;;
        *)
            # If stat_type does not match any of the above, print an error message.
            echo -e "${RED}Invalid statistic type: ${BLUE}$stat_type${NC}"
            ;;
    esac
}

# Define a function that generates graphs.
graph() {
    # Store the first argument in a variable.
    local graph_type="$1"

    # Check if graph_type is empty.
    if [ -z "$graph_type" ]; then
        # If it is, print an error message and return from the function.
        echo -e "${RED}Error: No graph type provided. (marks, density, scatter, histogram, box)${NC}"
        return 1
    fi

    # Shift the arguments to the left.
    shift

    # Depending on the value of graph_type, call the corresponding function.
    case "$graph_type" in
        marks)
            generate_marks_graph "$@"
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
            # If graph_type does not match any of the above, print an error message.
            echo -e "${RED}Invalid graph type: ${BLUE}$graph_type${NC}"
            ;;
    esac
}

# Define a function that initializes a new git repository.
init() {
    git_init "$@"
}

# Define a function that adds files to the git staging area.
add() {
    git_add "$@"
}

# Define a function that creates a new git branch.
branch() {
    git_branch "$@"
}

# Define a function that switches to a different git branch.
checkout() {
    git_checkout "$@"
}

# Define a function that commits changes in the git repository.
commit() {
    git_commit "$@"
}

# Define a function that shows the commit history of the git repository.
log() {
    git_log "$@"
}

# Define a function that merges git branches.
merge() {
    git_merge "$@"
}

# Define a function that shows information about a git object.
show() {
    git_show "$@"
}

# Define a function that shows the status of the git repository.
status() {
    git_status "$@"
}

# Define a function that shows a graphical representation of the git repository.
ggraph() {
    git_graph "$@"
}

header() {
# Print a fancy header.
    echo -e "${BLUE}            .-.              /\\            .-.\`;   .'\                         "
    echo -e "${BLUE}           (_) )-.       _  / |    .;;;.\`-'  _ \`; ; (                         "
    echo -e "${BLUE}             .: __)     (  /  |  .;;  (_)   (  ;' ;  )                        "
    echo -e "${BLUE}            .:'   \`.     \`/.__|_.'\`;;;.      \`.;__;.'                         "
    echo -e "${BLUE}            :'      ).:' /    |   _   \`:  .  .:'  \`:                         "
    echo -e "${BLUE}         (_/  \`----'(__.'     \`-'(_.;;;' (_.'       \`:                        "
    echo -e "${BLUE}          .-..-.                /\\     .-.                .-.-.       "
    echo -e "${BLUE}   .;;.\`-'  (_) )-.         _  / |    (_) )-.     .;;;.\`-' (_) )-.    "
    echo -e "${BLUE}  ;; (_;      .:   \\       (  /  |  .   .:   \\   ;;  (_)     .:   \\   "
    echo -e "${BLUE} ;;          .::.   )       \`/.__|_.'  .:'    \\  .;;; .-.   .::.   )  "
    echo -e "${BLUE};;    \`;;' .-:. \`:-'    .:' /    |   .-:.      );;  .;  ; .-:. \`:-'   "
    echo -e "${BLUE}\`;.___.'  (_/     \`:._.(__.'     \`-'(_/  \`----' \`;.___.' (_/     \`:._.${NC}"
    echo -e ""
    echo -e "${GREEN}CS 108 Project by Sanchita Chaurasia${NC}"
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
    init)
        sinit "${@:2}"
        ;;
    commit)
        scommit "${@:2}"
        ;;
    checkout)
        scheckout "${@:2}"
        ;;
    graph)
        sgraph "${@:2}"
        ;;
    git_init)
        init "${@:2}"
        ;;
    git_add)
        add "${@:2}"
        ;;
    git_branch)
        branch "${@:2}"
        ;;
    git_checkout)
        checkout "${@:2}"
        ;;
    git_commit)
        commit "${@:2}"
        ;;
    git_log)
        log "${@:2}"
        ;;
    git_merge)
        merge "${@:2}"
        ;;
    git_show)
        show "${@:2}"
        ;;
    git_status)
        status "${@:2}"
        ;;
    git_graph)
        ggraph "${@:2}"
        ;;
    name)
        header
        ;;
    *)
        # If the command is not recognized, print an error message.
        echo -e "${RED}Invalid command. Usage: <command> [arguments]. Type 'doc' to open project report.${NC}"
        ;;
esac
