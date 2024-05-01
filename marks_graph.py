# Import necessary libraries
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

# Function to plot marks distribution
def plot_marks_distribution(data_file, column_names, plot_file):
    try:
        # Read the CSV data file into a pandas DataFrame
        df = pd.read_csv(data_file)

        # Replace 'a' with 0 in numeric columns
        # First, drop the first two columns from the DataFrame
        cols = df.drop(df.columns[[0, 1]], axis=1)
        # Then, for each remaining column, convert its values to numeric, replacing non-numeric values with NaN
        for col in cols:
            df[col] = pd.to_numeric(df[col], errors='coerce')
        # Get a list of the names of the numeric columns in the DataFrame
        numeric_cols = df.select_dtypes(include=np.number).columns.tolist()

        # If no column names are provided, or if a single empty string is provided,
        # use all numeric columns except "Total"
        if len(column_names) == 1 and column_names[0] == "":
            column_names = [col for col in numeric_cols if col.lower() != 'total']

        # For each column name in the list of column names
        for column_name in column_names:
            # If the column name is not in the DataFrame, print a warning and continue with the next column name
            if column_name not in df.columns:
                print(f"Warning: Column '{column_name}' not found.", file=sys.stderr)
                continue

            # Drop NaN values from the column and store the remaining values in 'marks'
            marks = df[column_name].dropna()
            # Count the number of occurrences of each value in 'marks' and sort by index
            mark_counts = marks.value_counts().sort_index()

            # Plot the counts of each mark, using a line plot with circles at the data points
            plt.plot(mark_counts.index, mark_counts.values, marker='o', linestyle='-', label=column_name)

        # Set the labels and title of the plot
        plt.xlabel("Marks")
        plt.ylabel("Number of Students")
        plt.title("Marks Distribution")

        # Enable the grid
        plt.grid(True)

        # Add a legend to the plot
        plt.legend()

        # Save the plot to a file
        plt.savefig(plot_file)

    except Exception as e:
        # If an error occurs, print the error message and exit with an error code
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

# If this script is run as a standalone program
if __name__ == "__main__":
    # Parse command line arguments
    data_file = sys.argv[1]
    plot_file = sys.argv[-1]
    column_names = sys.argv[2:-1]  # All arguments between data file and plot file are treated as column names

    # Call the plot_marks_distribution function
    plot_marks_distribution(data_file, column_names, plot_file)