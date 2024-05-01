import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

def plot_box_plot(data_file, column_names, plot_file):
    try:
        # Read the CSV file into a pandas DataFrame
        df = pd.read_csv(data_file)

        # Replace non-numeric values with NaN in numeric columns
        cols = df.drop(df.columns[[0, 1]], axis=1)
        for col in cols:
            df[col] = pd.to_numeric(df[col], errors='coerce')
        numeric_cols = df.select_dtypes(include=np.number).columns.tolist()
        
        # If no column names are provided, use all numeric columns except those named "Total"
        if not column_names or (len(column_names) == 1 and column_names[0] == ""):
            column_names = [col for col in numeric_cols if col.lower() != 'total']

        # Create a box plot of the specified columns
        plt.figure(figsize=(10, 6)) 
        df.boxplot(column=column_names)
        
        # Set the labels and title of the plot
        plt.xlabel("Assessment Components")
        plt.ylabel("Marks")
        plt.title("Box Plot of Marks Distribution")

        # Adjust the layout and save the plot to a file
        plt.tight_layout() 
        plt.savefig(plot_file)
        # plt.show()

        return True

    except Exception as e:
        # Print any errors that occur
        print(f"Error: {str(e)}", file=sys.stderr)
        return False

if __name__ == "__main__":
    # Parse command line arguments
    data_file = sys.argv[1]
    plot_file = sys.argv[-1]
    column_names = sys.argv[2:-1]  # All arguments between data file and plot file are treated as column names

    # Special handling if no columns are specified or a single empty string is passed
    column_names = [name for name in column_names if name.strip()] if column_names else []
    
    # Call the plot_box_plot function and exit with an error code if it fails
    if not plot_box_plot(data_file, column_names, plot_file):
        sys.exit(1)