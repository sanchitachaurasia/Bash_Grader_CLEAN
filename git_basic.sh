#!/bin/bash
source bash_colors.sh

# Function to initialize a new remote repository
init_remote_repo() {
    # Store the repository path provided as an argument
    local repo_path="$1"
    local old_repo_path

    # Check if a .git_repo_path file already exists
    if [ -f ".git_repo_path" ]; then
        # Read the old repository path from the .git_repo_path file
        old_repo_path=$(cat .git_repo_path)
        # Warn the user that a repository already exists
        echo "Warning: A repository already exists at $old_repo_path."
        # Ask the user if they want to initialize a new repository
        read -p "Would you like to initialize a new repository at $repo_path? (y/n) " confirm
        # If the user doesn't confirm, cancel the operation and return 1
        if [[ $confirm != "y" ]]; then
            echo "Operation cancelled."
            return 1
        fi
        # Ask the user if they want to delete the old repository
        read -p "Do you want to delete the previous repository at $old_repo_path? (y/n) " confirm
        # If the user confirms, delete the old repository
        if [[ $confirm == "y" ]]; then
            rm -rf "$old_repo_path"
            echo "Deleted old repository at $old_repo_path."
        else
            # If the user doesn't confirm, rename the old repository
            local new_repo_path="${old_repo_path}_old"
            mv "$old_repo_path" "$new_repo_path"
            echo "Renamed old repository to $new_repo_path."
        fi
    fi

    # If the new repository directory already exists, print an error message and return 1
    if [ -d "$repo_path" ]; then
        echo "Error: Directory already exists ($repo_path)"
        return 1
    fi

    # Create the new repository directory and save its path for future reference
    mkdir -p "$repo_path"
    echo "$repo_path" > .git_repo_path
    echo "Remote repository initialized at $repo_path"
}

# Function to commit changes to the remote repository
commit_changes() {
    # Store the commit message provided as an argument
    local commit_message="$1" 

    # Check if a .git_repo_path file exists in the current directory
    # This file stores the path to the remote repository
    # If it doesn't exist, print an error message and return from the function
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi
    
    # Read the path to the remote repository from the .git_repo_path file
    local remote_dir=$(cat .git_repo_path)

    # Generate a random 16-digit hash value for the commit
    # This will be used as a unique identifier for the commit
    local hash_value=$(openssl rand -hex 8)
    # Define the path to the new commit directory
    local commit_dir="$remote_dir/$hash_value"

    # Create a new directory for the commit in the remote repository
    mkdir -p "$commit_dir"

    # Copy only CSV files from the current directory to the commit directory
    rsync -a --include='*.csv' --exclude='*' . "$commit_dir/"

    # Add a new line to the log file with the commit hash and message
    # The log file is located in the remote repository directory
    echo "$hash_value,$commit_message" >> "$remote_dir/.git_log"
    # Print a success message with the commit hash and message
    echo "Files committed with hash value: $hash_value"
    echo "Commit message: $commit_message"

    # If a .last_commit file exists in the remote repository directory
    # This file stores the hash of the last commit
    if [ -f "$remote_dir/.last_commit" ]; then
        # Read the hash of the last commit from the .last_commit file
        local last_commit=$(cat "$remote_dir/.last_commit")
        # Print the files that have been modified since the last commit
        # The diff command is used to compare the last commit directory and the current commit directory
        echo "Modified files since last commit:"
        diff -rq "$remote_dir/$last_commit" "$commit_dir"
    fi

    # Save the hash of the current commit as the last commit
    # This is done by writing the hash to the .last_commit file
    echo "$hash_value" > "$remote_dir/.last_commit"
}

# Function to checkout to a specific commit
checkout_commit() {
    # Store the commit hash provided as an argument
    local commit_hash="$1"
    # If a .git_repo_path file doesn't exist, print an error message and return
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi
    
    # Read the remote directory path from the .git_repo_path file
    local remote_dir=$(cat .git_repo_path)

    # Find the commit folder that starts with the provided hash
    local commit_folder=$(find "$remote_dir" -type d -name "$commit_hash*")

    # If a matching commit folder is found, copy its contents to the checkouted directory
    if [ -n "$commit_folder" ]; then
        cp -r "$commit_folder/"* .
        echo "Checked out to commit: $commit_hash"
    else
        # If no matching commit folder is found, print an error message
        echo "Error: Invalid commit hash provided."
    fi
}

# Function to display the commit graph
commit_graph() {
    # If a .git_repo_path file doesn't exist, print an error message and return
    if [ ! -f ".git_repo_path" ]; then
        echo "Error: Remote repository not initialized. Run git_init first."
        return
    fi

    # Read the remote directory path from the .git_repo_path file
    local remote_dir=$(cat .git_repo_path)

    # If a .git_log file doesn't exist, print an error message and return
    if [ ! -f "$remote_dir/.git_log" ]; then
        echo "Error: No commits found."
        return
    fi

    # Read the log file and print each commit hash and message
    while IFS=, read -r hash message
    do
        echo -e "${RED}commit $hash${NC}"
        echo -e "$message\n"
    done < "$remote_dir/.git_log"
}