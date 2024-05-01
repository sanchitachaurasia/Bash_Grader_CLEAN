# reference: Write yourself a git: https://wyag.thb.lt/
# #TODO:
# 1. Change commit-<no> to hash_value in all.
# 2. Find for finding the folder with hash_value.

#This file was still under progress, while submitting. Only rough idea.

#!/bin/bash

# Import the bash_colors.sh script
source bash_colors.sh

# Function to initialize a new git repository
git_init() {
    # Store the repository path provided as an argument
    local repo="$1"
    local old_repo

    # If a .git_repo file already exists
    if [ -f ".git_repo" ]; then
        # Read the old repository path from the .git_repo file
        old_repo=$(cat .git_repo)
        # Warn the user that a repository already exists
        echo "Warning: A repository already exists at $old_repo."
        # Ask the user if they want to initialize a new repository
        read -p "Would you like to initialize a new repository at $repo? (y/n) " confirm
        # If the user doesn't confirm, cancel the operation and return 1
        if [[ $confirm != "y" ]]; then
            echo "Operation cancelled."
            return 1
        fi
        # Ask the user if they want to delete the old repository
        read -p "Do you want to delete the previous repository at $old_repo? (y/n) " confirm
        # If the user confirms
        if [[ $confirm == "y" ]]; then
            # Delete the old repository
            rm -rf "$old_repo"
            echo "Deleted old repository at $old_repo."
        else
            # If the user doesn't confirm, rename the old repository
            local new_repo="${old_repo}_old"
            mv "$old_repo" "$new_repo"
            echo "Renamed old repository to $new_repo."
        fi
    fi

    # If the new repository directory already exists, print an error message and return 1
    if [ -d "$repo" ]; then
        echo "Error: Directory already exists ($repo)"
        return 1
    fi

    # Initialize directories and files for the new repository
    mkdir "$repo"
    echo "$repo" > .git_repo_path
    mkdir "$repo/index"
    mkdir "$repo/commits"
    mkdir "$repo/branches"
    touch "$repo/branches/master"
    touch "$repo/logs"
    echo master > "$repo/HEAD"
    echo "Initialized empty git repository in $repo"
}

# Function to checkout a git branch
git_checkout() {
    # Check if a .git_repo_path file exists. This file stores the path to the git repository.
    # If it doesn't exist, it means a git repository hasn't been initialized yet.
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the paths to the index, commits, branches, HEAD, and temporary directories
    local index="$repo/index"
    local commits="$repo/commits"
    local branches="$repo/branches"
    local HEAD="$repo/HEAD"
    local temp1="$repo/temp1"
    local temp2="$repo/temp2"
    local temp3="$repo/temp3"
    local temp="$repo/temp"

    # Check if there are any commits in the commits directory
    # If there are no commits, print an error message and exit with status 1
    if [ $(ls -A "$commits" | wc -l) -eq 0 ]
    then
        echo "$0: error: this command can not be run until after the first commit" 1>&2
        exit 1
    fi

    # Check the arguments to determine the branch to checkout
    if [ $# -eq 1 ]
    then
        if [ -f "$branches/$1" ]
        then
            branch_name="$1"
        else
            echo "$0: error: unknown branch '$1'" 1>&2
            exit 1
        fi
    else
        echo "usage: $0 <branch>" 1>&2
        exit 1
    fi

    # Find the current branch by reading the HEAD file
    branch=$(cat $HEAD)

    # Check if already in the branch to checkout
    if [ $branch = $branch_name ]
    then
        echo "Already on '$branch_name'"
        exit 0
    fi

    # Find the last committed repository for the current branch and the branch to checkout
    count1=$(cat "$branches/$branch" | sed -n 1p | cut -c1)
    repository1="$commits/commit-$count1"

    count2=$(cat "$branches/$branch_name" | sed -n 1p | cut -c1)
    repository2="$commits/commit-$count2"

    # Create three temporary files for storing files that failed to checkout, files to copy, and files to remove
    touch "$temp1" || exit 1
    touch "$temp2" || exit 1
    touch "$temp3" || exit 1
    touch "$temp" || exit 1

    # Put filenames in temp
    for file in $(ls $repository1) $(ls $repository2)
    do
        # Check if the filename is valid
        if echo "$file" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
        then
            :
        else
            echo "$file" >> $temp
        fi
    done

    # For each unique filename in temp
    for filename in $(cat $temp | sort | uniq)
    do
        # Check if the file exists in the repository to checkout
        if [ -f "$repository2/$filename" ]
        then
            # Check if the file exists in the current repository
            if [ -f "$repository1/$filename" ]
            then
                # If the file in the current repository is different from the file in the repository to checkout
                if ! diff "$repository1/$filename" "$repository2/$filename" > /dev/null
                then
                    # Check if the file exists in the index
                    if [ -f "$index/$filename" ]
                    then
                        # If the file in the index is different from the file in the repository to checkout
                        if ! diff "$index/$filename" "$repository2/$filename" > /dev/null
                        then
                            # Check if the file in the index is the same as the file in the current repository
                            if diff "$index/$filename" "$repository1/$filename" > /dev/null
                            then
                                # Check if the file exists in the working directory
                                if [ -f "$filename" ]
                                then
                                    # If the file in the working directory is the same as the file in the index
                                    if diff "$filename" "$index/$filename" > /dev/null
                                    then
                                        echo "$filename" >> "$temp2"
                                    else
                                        echo "$filename" >> "$temp1"
                                    fi
                                else
                                    echo "$filename" >> "$temp2"
                                fi
                            else
                                echo "$filename" >> "$temp1"
                            fi
                        fi
                    else
                        echo "$filename" >> "$temp1"
                    fi
                fi
            else
                # Check if the file exists in the index
                if [ -f "$index/$filename" ]
                then
                    # If the file in the index is different from the file in the repository to checkout
                    if ! diff "$index/$filename" "$repository2/$filename" > /dev/null
                    then
                        echo "$filename" >> "$temp1"
                    fi
                else
                    # Check if the file exists in the working directory
                    if [ -f "$filename" ]
                    then
                        echo "$filename" >> "$temp1"
                    else
                        echo "$filename" >> "$temp2"
                    fi
                fi
            fi
        else
            # Check if the file exists in the index
            if [ -f "$index/$filename" ]
            then
                # If the file in the index is the same as the file in the current repository
                if diff "$index/$filename" "$repository1/$filename" > /dev/null
                then
                    # Check if the file exists in the working directory
                    if [ -f "$filename" ]
                    then
                        # If the file in the working directory is the same as the file in the current repository
                        if diff "$filename" "$repository1/$filename" > /dev/null
                        then
                            echo "$filename" >> "$temp3"
                        else
                            echo "$filename" >> "$temp1"
                        fi
                    else
                        echo "$filename" >> "$temp3"
                    fi
                else
                    echo "$filename" >> "$temp1"
                fi
            else
                # Check if the file exists in the working directory
                if [ -f "$filename" ]
                then
                    echo "$filename" >> "$temp1"
                fi   
            fi
        fi
    done

    # Get the list of files that failed to checkout, files to copy, and files to remove
    fail=$(cat $temp1 | sort)
    copy=$(cat $temp2)
    remove=$(cat $temp3)

    # Remove the temporary files
    rm -f $temp1 || exit 1
    rm -f $temp2 || exit 1
    rm -f $temp3 || exit 1
    rm -f $temp || exit 1

    # If no files failed to checkout
    if [ -z "$fail" ]
    then
        # Write the branch to checkout to the HEAD file
        echo "$branch_name" > $HEAD
        
        # Copy the files from the repository to checkout to the index and the working directory
        for file in $copy
        do
            cp "$repository2/$file" "$index/$file" || exit 1
            cp "$repository2/$file" "$file" || exit 1
        done

        # Remove the files from the index and the working directory
        for file in $remove
        do
            rm -f "$index/$file" || exit 1
            rm -f "$file" || exit 1
        done

        echo "Switched to branch '$branch_name'" 

    # If there are files that failed to checkout
    else
        echo "$0: error: Your changes to the following files would be overwritten by checkout:"
        echo "$fail"
    fi
}

# Function to commit changes in git
git_commit() {
    # Check if a .git_repo_path file exists. This file stores the path to the git repository.
    # If it doesn't exist, it means a git repository hasn't been initialized yet.
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the paths to the index, commits, branches, and HEAD directories
    local index="$repo/index"
    local commits="$repo/commits"
    local branches="$repo/branches"
    local HEAD="$repo/HEAD"

    # Check the arguments to determine the commit message
    if [ $# -eq 2 ] && [ "$1" = '-m' ] &&
        echo "$2" | grep -vE '^ *$' > /dev/null
    then
        message="$2"
    elif [ $# -eq 3 ] && [ "$1" = '-a' ] && [ "$2" = '-m' ] &&
        echo "$3" | grep -vE '^ *$' > /dev/null
    then
        message="$3"
    else
        echo "usage: $0 [-a] -m commit-message" 1>&2
        exit 1
    fi

    # If the '-a' option is used, add all changes in the working directory to the index
    if [ $# -eq 3 ]
    then
        for file in "$index"/*
        do
            filename=$(basename "$file")
            if [ "$filename" = '*' ]
            then
                :
            # when the file doesn't exist in current directory
            elif [ ! -f "$filename" ]
            then
                rm -f "$index/$filename" || exit 1
            else
                cp "$filename" "$index" || exit 1
            fi
        done
    fi

    # Count the number of commits
    count=$(ls -A "$commits" | wc -l)

    # Find the current branch by reading the HEAD file
    branch=$(cat $HEAD)
    logs="$branches/$branch"
    total_logs='$repo/logs'

    # Check if there is anything to commit
    if [ $count -eq 0 ] && [ "$(ls -A $index)" = '' ]
    then
        echo "nothing to commit"
        exit 1
    elif [ $count -gt 0 ]
    then
        num=$(cat "$logs" | sed -n 1p | cut -c1)
        if diff "$index" "$commits/commit-$num" > /dev/null
        then
            echo "nothing to commit"
            exit 1
        fi
    fi

    # Insert the commit number and message to the first line of the logs and total_logs
    if [ $count -eq 0 ]
    then
        echo "$count $message" >> "$logs"
        echo "$count $message" >> "$total_logs"
    else
        sed -i "1i $count $message" "$logs"
        sed -i "1i $count $message" "$total_logs"
    fi

    # Create a new commit directory
    mkdir "$commits/commit-$count" || exit 1

    # Copy the files in the index to the new commit directory
    for file in "$index"/*
    do
        if [ "$file" != "$index/*" ]
        then
            cp "$file" "$commits/commit-$count" || exit 1
        fi
    done

    echo "Committed as commit $count"
}

# Function to add files to the git index
git_add() {
    # If a .git_repo_path file doesn't exist, print an error message and return
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the index directory
    local index="$repo/index"

    # If no arguments were provided, print a usage message and exit with status 1
    if [ $# -eq 0 ]
    then
        echo "usage: $0 <filenames>" 1>&2
        exit 1
    fi

    # For each argument
    for file in "$@"
    do
        # If the filename is invalid, print an error message and exit with status 1
        if echo "$file" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
        then
            echo "$0: error: invalid filename '$file'" 1>&2
            exit 1
        # If the file doesn't exist in both the current directory and the index, print an error message and exit with status 1
        elif [ ! -f "$file" ] && [ ! -f "$index/$file" ]
        then
            echo "$0: error: can not open '$file'" 1>&2
            exit 1
        fi
    done

    # For each argument
    for file in "$@"
    do
        # If the file doesn't exist in the current directory but exists in the index
        if [ ! -f "$file" ] && [ -f "$index/$file" ]
        then
            # Delete the file from the index
            rm -f "$index/$file" || exit 1
        else
            # Copy the file to the index
            cp "$file" "$index" || exit 1
        fi
    done
}

# Function to manage git branches
git_branch() {
    # Check if a .git_repo_path file exists. This file stores the path to the git repository.
    # If it doesn't exist, it means a git repository hasn't been initialized yet.
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the paths to the index, commits, branches, and HEAD directories
    local index="$repo/index"
    local commits="$repo/commits"
    local branches="$repo/branches"
    local HEAD="$repo/HEAD"

    # Check if there are any commits in the commits directory
    # If there are no commits, print an error message and exit with status 1
    if [ $(ls -A "$commits" | wc -l) -eq 0 ]
    then
        echo "$0: error: this command can not be run until after the first commit" 1>&2
        exit 1
    fi

    # Initialize flags for create, delete, and list operations
    create=0
    delete=0
    list=0

    # Check the arguments to determine the operation
    if [ $# -eq 2 ] && [ "$1" = '-d' ] # delete
    then
        delete=1
        branch_name="$2"
    elif [ $# -eq 1 ] && [ "$1" = '-d' ] # delete but missing branch name
    then
        echo "$0: error: branch name required" 1>&2
        exit 1
    elif [ $# -eq 1 ] # create
    then
        create=1
        branch_name="$1"
    elif [ $# -eq 0 ] # list
    then
        list=1
    else
        echo "usage: $0 [-d] <branch>" 1>&2
        exit 1
    fi

    # Find the current branch by reading the HEAD file
    branch=$(cat $HEAD)
    logs="$branches/$branch"

    if [ "$delete" = '1' ] # delete
    then
        # Check if the branch to be deleted exists
        if [ ! -f "$branches/$branch_name" ]
        then
            echo "$0: error: branch '$branch_name' doesn't exist" 1>&2
            exit 1
        # Check if the branch to be deleted is 'master'
        elif [ "$branch_name" = 'master' ]
        then
            echo "$0: error: can not delete branch 'master'" 1>&2
            exit 1
        # Check if the branch to be deleted has unmerged changes
        elif [ $(cat "$branches/$branch" | sed -n 1p | cut -c1) -lt $(cat "$branches/$branch_name" | sed -n 1p | cut -c1) ]
        then
            echo "$0: error: branch '$branch_name' has unmerged changes" 1>&2
            exit 1
        else
            # Delete the branch
            rm -f "$branches/$branch_name" || exit 1
            echo "Deleted branch '$branch_name'"
        fi
    elif [ "$list" = '1' ] # list
    then
        # List all branches by listing all files in the branches directory
        for file in $(ls $branches)
        do
            echo "$file"
        done
    else # create
        # Check if the branch to be created already exists
        if [ -f "$branches/$branch_name" ]
        then
            echo "$0: error: branch '$branch_name' already exists" 1>&2
            exit 1
        else
            # Create the branch by copying the logs of the current branch to a new file in the branches directory
            cp "$logs" "$branches/$branch_name" || exit 1
        fi
    fi
}

# Function to display the commit history in git
git_log() {
    # Check if a .git_repo_path file exists. This file stores the path to the git repository.
    # If it doesn't exist, it means a git repository hasn't been initialized yet.
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the paths to the branches and HEAD directories
    local branches="$repo/branches"
    local HEAD="$repo/HEAD"

    # Check the arguments to ensure no arguments were passed
    # The git_log function does not take any arguments
    if [ $# -ne 0 ]
    then
        echo "usage: $0" 1>&2
        exit 1
    fi

    # Find the current branch by reading the HEAD file
    branch=$(cat $HEAD)
    logs="$branches/$branch"

    # Read and print the logs of the current branch
    # The logs contain the commit history of the branch
    cat "$logs"
}

# Function to merge changes from another branch or commit into the current branch in git
git_merge() {
    # Check if a .git_repo_path file exists. This file stores the path to the git repository.
    # If it doesn't exist, it means a git repository hasn't been initialized yet.
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the paths to the index, commits, branches, and HEAD directories
    local index="$repo/index"
    local commits="$repo/commits"
    local branches="$repo/branches"
    local HEAD="$repo/HEAD"

    # Check if there is any commit
    # If there are no commits, print an error message and exit with status 1
    if [ $(ls -A "$commits" | wc -l) -eq 0 ]
    then
        echo "$0: error: this command can not be run until after the first commit" 1>&2
        exit 1
    fi

    # Check the arguments to determine the commit message
    # The git_merge function requires a branch or commit and a commit message
    if [ $# -eq 1 ]
    then
        echo "$0: error: empty commit message" 1>&2
        exit 1
    elif [ $# -eq 3 ] && [ "$2" = '-m' ]
    then
        if echo "$3" | grep -E '^ *$' > /dev/null
        then
            echo "$0: error: empty commit message" 1>&2
            exit 1
        else
            message="$3"
        fi
    else
        echo "usage: $0 <branch|commit> -m message" 1>&2
        exit 1
    fi

    # Count the commit number
    count=$(ls -A "$commits" | wc -l)

    # Find the current branch by reading the HEAD file
    branch=$(cat $HEAD)
    logs="$branches/$branch"
    total_logs='$repo/logs'

    # If $1 is numeric, it's a commit
    if [ "$1" -eq "$1" ] 2> /dev/null && [ $1 -ge 0 ]
    then
        if [ $1 -lt $count ]
        then
            checked_num=$1
        else
            echo "$0: error: unknown commit '$1'" 1>&2
            exit 1
        fi

    # If $1 is not numeric, it's a branch
    else
        if [ ! -f "$branches/$1" ]
        then
            echo "$0: error: unknown branch '$1'" 1>&2
            exit 1
        # Merge the current branch
        elif [ "$branch" = "$1" ]
        then
            echo "Already up to date"
            exit 0
        else
            checked_num=$(cat "$branches/$1" | sed -n 1p | cut -c1)
        fi
    fi

    # Get the last commit number of the current branch
    last_commit=$(cat "$logs" | sed -n 1p | cut -c1)
    repo_last_commit="$commits/commit-$last_commit"

    # Find the last updated commit number of the current branch
    last_update=0
    for i in $(cat "$logs" | cut -d' ' -f1 | sort -n )
    do
        if [ $i -eq $last_update ]
        then
            last_update=$(($last_update + 1))
        fi
    done
    last_update=$(($last_update - 1))
    repo_last_update="$commits/commit-$last_update"

    # If checked_num exists in the log file of the current branch
    if cat "$logs" | cut -d' ' -f1 | grep -E "$checked_num" > /dev/null
    then
        # No matter if the files exists in working directory
        echo "Already up to date"
        exit 0
    fi

    repo_checked="$commits/commit-$checked_num"

    # Check errors
    for file in $(ls $repo_checked)
    do
        # If file in working directory
        if [ -f "$file" ]
        then
            # If file in repo_last_commit
            if [ -f "$repo_last_commit/$file" ]
            then
                # Local changes
                if ! diff "$file" "$repo_last_commit/$file" > /dev/null
                then
                    echo "$0: error: can not merge: local changes to files" 1>&2
                    exit 1
                fi

                # If file in repo_last_update
                if [ -f "$repo_last_update/$file" ]
                then
                    if diff "$repo_last_commit/$file" "$repo_last_update/$file" > /dev/null ||
                        diff "$repo_last_commit/$file" "$repo_checked/$file" > /dev/null ||
                        diff "$repo_checked/$file" "$repo_last_update/$file" > /dev/null
                    then
                        :
                    # Can not merge
                    else
                        echo "$0: error: can not merge" 1>&2
                        exit 1
                    fi
                fi
            fi
        fi
    done

    for file in $(ls $repo_checked)
    do
        cp "$repo_checked/$file" "$file" || exit 1
        cp "$repo_checked/$file" "$index/$file" || exit 1
    done

    # Check if fast forward
    if [ $last_update -eq $last_commit ]
    then
        echo "Fast-forward: no commit created"
    else
        .\submission.sh git_commit -m "$message"
    fi

    # Change the log file
    logs_copy=$(cat $logs)
    rm -f $logs || exit 1
    while read line
    do
        number=$(echo $line | cut -d' ' -f1)
        if [ $number -le $checked_num ]
        then
            echo "$line" >> $logs
        elif echo $logs_copy | cut -d' ' -f1 | grep -E "$number" > /dev/null
        then
            echo "$line" >> $logs
        fi
    done < $total_logs
}

# git_show function
git_show() {
    # Check if a .git_repo_path file exists. This file stores the path to the git repository.
    # If it doesn't exist, it means a git repository hasn't been initialized yet.
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the paths to the index and commits directories
    local index="$repo/index"
    local commits="$repo/commits"

    # Check the arguments to determine the commit and filename
    # The git_show function requires one argument in the format <commit>:<filename>
    # If the commit is omitted, it shows the file from the index
    # If the commit number is a positive number less than the total number of commits, it shows the file from the specified commit
    if [ $# -ne 1 ]
    then
        echo "usage: $0 <commit>:<filename>" 1>&2
        exit 1
    elif echo "$1" | grep -vE ':' > /dev/null
    then
        echo "$0: error: invalid object $1" 1>&2
        exit 1
    else
        commit=$(echo "$1" | cut -d':' -f1)
        filename=$(echo "$1" | cut -d':' -f2-)
    fi

    # Count the commit number
    count=$(ls -A "$commits" | wc -l)

    # If the commit is omitted, it shows the file from the index
    if [ "$commit" = '' ]
    then
        # Check if the filename is valid
        # A valid filename starts with an alphanumeric character and can contain alphanumeric characters, dots, underscores, and dashes
        if echo "$filename" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
        then
            echo "$0: error: invalid filename '$filename'" 1>&2
            exit 1
        # Check if the file exists in the index
        elif [ ! -f "$index/$filename" ]
        then
            echo "$0: error: '$filename' not found in index" 1>&2
            exit 1
        else
            cat "$index/$filename"
        fi
    # If the commit number is a positive number less than the total number of commits, it shows the file from the specified commit
    elif [ "$commit" -eq "$commit" ] 2> /dev/null &&
        [ $commit -ge 0 ] && [ $commit -lt $count ]
    then
        # Check if the filename is valid
        if echo "$filename" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
        then
            echo "$0: error: invalid filename '$filename'" 1>&2
            exit 1
        # Check if the file exists in the specified commit
        elif [ ! -f "$commits/commit-$commit/$filename" ]
        then
            echo "$0: error: '$filename' not found in commit $commit" 1>&2
            exit 1
        else
            cat "$commits/commit-$commit/$filename"
        fi
    else
        echo "$0: error: unknown commit '$commit'" 1>&2
        exit 1
    fi
}

# git_status function
git_status() {
    # Check if a .git_repo_path file exists. This file stores the path to the git repository.
    # If it doesn't exist, it means a git repository hasn't been initialized yet.
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the repository path from the .git_repo_path file
    local repo=$(cat .git_repo_path)

    # Define the paths to the index, commits, branches, HEAD, and temp directories
    local index="$repo/index"
    local commits="$repo/commits"
    local branches="$repo/branches"
    local HEAD="$repo/HEAD"
    local temp="$repo/temp"

    # Create a temporary file to store filenames
    touch "$temp" || exit 1

    # Find the current branch by reading the HEAD file
    branch=$(cat $HEAD)
    logs="$branches/$branch"

    # Find the last committed repository
    # If there are no commits, the repository is the commits directory
    # Otherwise, the repository is the directory of the last commit
    if [ $(ls -A "$commits" | wc -l) -eq 0 ]
    then
        repository="$commits"
    else
        count=$(cat "$logs" | sed -n 1p | cut -c1)
        repository="$commits/commit-$count"
    fi

    # Put filenames in the temporary file
    # Check each file in the working directory, index, and repository
    for file in $(ls) $(ls $index) $(ls $repository)
    do
        # Check if the filename is valid
        # A valid filename starts with an alphanumeric character and can contain alphanumeric characters, dots, underscores, and dashes
        if echo "$file" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
        then
            :
        elif echo "$file" | grep -E '^git-.*' > /dev/null
        then
            :
        else
            echo "$file" >> $temp
        fi
    done

    # Check each file in the temporary file and display the status of each file
    for file in $(cat $temp | sort | uniq)
    do
        # File not in working directory
        if [ ! -f "$file" ]
        then
            # File not in index
            if [ ! -f "$index/$file" ]
            then
                # File in repository
                echo "$file - deleted"
            # File in index
            else
                # File not in repository
                if [ ! -f "$repository/$file" ]
                then
                    echo "$file - added to index, file deleted"
                # File in repository
                else
                    if diff "$index/$file" "$repository/$file" > /dev/null
                    then
                        echo "$file - file deleted"
                    else
                        echo "$file - file deleted, different changes staged for commit"
                    fi
                fi
            fi
        # File in working directory
        else
            # File not in index
            if [ ! -f "$index/$file" ]
            then
                echo "$file - untracked"
            # File in index
            else
                # File not in repository
                if [ ! -f "$repository/$file" ]
                then
                    if diff "$file" "$index/$file" > /dev/null
                    then
                        echo "$file - added to index"
                    else
                        echo "$file - added to index, file changed"
                    fi
                # File in repository
                else
                    # Working file = index
                    if diff "$file" "$index/$file" > /dev/null
                    then
                        # Working file = index = repository
                        if diff "$file" "$repository/$file" > /dev/null
                        then
                            echo "$file - same as repo"
                        # Working file = index != repository
                        else
                            echo "$file - file changed, changes staged for commit"
                        fi
                    # Working file != index
                    else
                        # Working file != index = repository
                        if diff "$index/$file" "$repository/$file" > /dev/null
                        then
                            echo "$file - file changed, changes not staged for commit"
                        # Working file != index != repository
                        else
                            echo "$file - file changed, different changes staged for commit"
                        fi
                    fi
                fi
            fi
        fi
    done

    # Remove the temporary file
    rm -f $temp || exit 1
}

# git_graph function
git_graph() {
    # Check if a .git_repo file exists. This file stores the path to the remote git repository.
    # If it doesn't exist, it means a remote repository hasn't been initialized yet.
    if [ ! -f ".git_repo" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the remote directory path from the .git_repo file
    local remote_dir=$(cat .git_repo)

    # Check if the log file exists in the remote directory
    # If it doesn't exist, it means there are no commits yet.
    if [ ! -f "$remote_dir/.git_log" ]; then
        echo "Error: No commits found."
        return
    fi

    # Read the log file and generate the graph
    # Each commit is displayed with its hash and message
    while IFS=, read -r hash message
    do
        echo -e "${RED}commit $hash${NC}"
        echo -e "$message\n"
    done < "$remote_dir/.git_log"
}