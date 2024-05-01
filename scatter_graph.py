import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

# Function to plot a density distribution
def plot_density_distribution(data_file, column_names, plot_file):
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
        if not column_names or (len(column_names) == 1 and column_names[0] == ""):
            column_names = [col for col in numeric_cols if col.lower() != 'total']

        # For each column name in the list of column names
        for column_name in column_names:
            # If the column name is not in the DataFrame, print a warning and continue with the next column name
            if column_name not in df.columns:
                print(f"Warning: Column '{column_name}' not found.", file=sys.stderr)
                continue

            # Drop NaN values from the column and store the remaining values in 'marks'
            marks = df[column_name].dropna()

            # If there are less than 2 data points in 'marks', print a warning and continue with the next column name
            if len(marks) < 2:
                print(f"Warning: Insufficient data points for column '{column_name}'.", file=sys.stderr)
                continue

            # Create a linear space of 1000 points between the minimum and maximum mark
            density = np.linspace(marks.min(), marks.max(), 1000)
            # Initialize a kernel density estimate with zeros
            kernel = np.zeros_like(density)

            # For each mark, add a Gaussian kernel to the kernel density estimate
            for x in marks:
                kernel += np.exp(-(density - x) ** 2 / (2 * marks.std() ** 2))

            # Normalize the kernel density estimate
            kernel /= len(marks) * np.sqrt(2 * np.pi * marks.std() ** 2)

            # Plot the kernel density estimate using a scatter plot
            plt.scatter(density, kernel, label=column_name, s=5)  # Adjust the size of points with 's' parameter

        # Set the labels and title of the plot
        plt.xlabel("Marks")
        plt.ylabel("Density")
        plt.title("Density Plot of Marks Distribution")

        # Add a legend to the plot
        plt.legend()

        # Save the plot to a file
        plt.savefig(plot_file)

        # Return True to indicate that the function completed successfully
        return True

    except Exception as e:
        # If an error occurs, print the error message and return False
        print(f"Error: {str(e)}", file=sys.stderr)
        return False

# If this script is run as a standalone program
if __name__ == "__main__":
    # Parse command line arguments
    data_file = sys.argv[1]
    plot_file = sys.argv[-1]
    column_names = sys.argv[2:-1]  # All arguments between data file and plot file are treated as column names

    # Special handling if no columns are specified or a single empty string is passed
    column_names = [name for name in column_names if name.strip()] if column_names else []

    # Call the plot_density_distribution function and exit with an error code if it fails
    if not plot_density_distribution(data_file, column_names, plot_file):
        sys.exit(1)