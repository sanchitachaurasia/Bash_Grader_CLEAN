import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

# def plot_box_plot(data_file, column_names, plot_file):
#     try:
#         df = pd.read_csv(data_file)

#         if not column_names or (len(column_names) == 1 and column_names[0] == ""):
#             # Exclude "Total" and non-numeric columns
#             numeric_cols = df.select_dtypes(include=np.number).columns.tolist()
#             column_names = [col for col in numeric_cols if col.lower() != 'total']

#         plt.figure(figsize=(10, 6))  # Adjust figure size as needed
#         df.boxplot(column=column_names)
        
#         plt.xlabel("Assessment Components")
#         plt.ylabel("Marks")
#         plt.title("Box Plot of Marks Distribution")

#         plt.tight_layout()  # Adjust layout for better visualization
#         plt.savefig(plot_file)
#         plt.show()

#         return True

#     except Exception as e:
#         print(f"Error: {str(e)}", file=sys.stderr)
#         return False

# if __name__ == "__main__":
#     data_file = sys.argv[1]
#     plot_file = sys.argv[-1]
#     column_names = sys.argv[2:-1]  # All arguments between data file and plot file are treated as column names

#     # Special handling if no columns are specified or a single empty string is passed
#     column_names = [name for name in column_names if name.strip()] if column_names else []
    
#     if not plot_box_plot(data_file, column_names, plot_file):
#         sys.exit(1)
def plot_box_plot(data_file, column_names, plot_file):
    try:
        df = pd.read_csv(data_file)

        # Replace 'a' with 0 in numeric columns
        numeric_cols = df.select_dtypes(include=np.number).columns.tolist()
        for col in numeric_cols:
            df[col] = pd.to_numeric(df[col], errors='coerce')

        if not column_names or (len(column_names) == 1 and column_names[0] == ""):
            # Exclude "Total" and non-numeric columns
            column_names = [col for col in numeric_cols if col.lower() != 'total']

        plt.figure(figsize=(10, 6)) 
        df.boxplot(column=column_names)
        
        plt.xlabel("Assessment Components")
        plt.ylabel("Marks")
        plt.title("Box Plot of Marks Distribution")

        plt.tight_layout() 
        plt.savefig(plot_file)
        plt.show()

        return True

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        return False

if __name__ == "__main__":
    data_file = sys.argv[1]
    plot_file = sys.argv[-1]
    column_names = sys.argv[2:-1]  # All arguments between data file and plot file are treated as column names

    # Special handling if no columns are specified or a single empty string is passed
    column_names = [name for name in column_names if name.strip()] if column_names else []
    
    if not plot_box_plot(data_file, column_names, plot_file):
        sys.exit(1)