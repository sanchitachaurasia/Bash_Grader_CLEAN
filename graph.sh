#!/bin/bash

# This function generates a marks graph using a Python script
generate_marks_graph(){
    # Define the Python script, data file, and plot file
    python_script="marks_graph.py"
    data_file="main.csv"
    plot_file="distribution_plot.png"

    # If no arguments are provided, call the Python script with an empty string for column names
    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
        # If arguments are provided, call the Python script with the provided arguments as column names
        python3 "$python_script" "$data_file" "$@" "$plot_file"
    fi
}

# This function generates a density graph using a Python script
generate_density_graph(){
    # Define the Python script, data file, and plot file
    python_script="density_graph.py"
    data_file="main.csv"
    plot_file="density_plot.png"

    # If no arguments are provided, call the Python script with an empty string for column names
    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
        # If arguments are provided, call the Python script with the provided arguments as column names
        python3 "$python_script" "$data_file" "$@" "$plot_file"
    fi
}

# This function generates a scatter graph using a Python script
generate_scatter_graph(){
    # Define the Python script, data file, and plot file
    python_script="scatter_graph.py"
    data_file="main.csv"
    plot_file="scatter_plot.png"

    # If no arguments are provided, call the Python script with an empty string for column names
    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
        # If arguments are provided, call the Python script with the provided arguments as column names
        python3 "$python_script" "$data_file" "$@" "$plot_file"
    fi
}

generate_histogram_graph(){
    python_script="histogram_graph.py"
    data_file="main.csv"
    plot_file="histogram_plot.png"

    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
        python3 "$python_script" "$data_file" "$@" "$plot_file"
    fi

}

generate_box_graph(){
    python_script="box_graph.py"
    data_file="main.csv"
    plot_file="box_plot.png"

    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
        python3 "$python_script" "$data_file" "$@" "$plot_file"
    fi

}