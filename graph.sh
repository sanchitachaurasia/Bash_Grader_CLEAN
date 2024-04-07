#!/bin/bash

generate_marks_graph(){
    python_script="marks_graph.py"
    data_file="main.csv"
    plot_file="distribution_plot.png"

    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
        python3 "$python_script" "$data_file" "$@" "$plot_file"
    fi

}

generate_density_graph(){
    python_script="density_graph.py"
    data_file="main.csv"
    plot_file="density_plot.png"

    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
        python3 "$python_script" "$data_file" "$@" "$plot_file"
    fi

}

generate_scatter_graph(){
    python_script="scatter_graph.py"
    data_file="main.csv"
    plot_file="scatter_plot.png"

    if [ $# -eq 0 ]; then
        python3 "$python_script" "$data_file" "" "$plot_file"
    else
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
