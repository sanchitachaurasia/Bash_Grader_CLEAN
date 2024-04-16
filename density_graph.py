import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

# def plot_density_distribution(data_file, column_names, plot_file):
#     try:
#         df = pd.read_csv(data_file)

#         if not column_names or (len(column_names) == 1 and column_names[0] == ""):
#             # Exclude "Total" and non-numeric columns
#             numeric_cols = df.select_dtypes(include=np.number).columns.tolist()
#             column_names = [col for col in numeric_cols if col.lower() != 'total']

#         for column_name in column_names:
#             if column_name not in df.columns:
#                 print(f"Warning: Column '{column_name}' not found.", file=sys.stderr)
#                 continue

#             marks = df[column_name].dropna()

#             if len(marks) < 2:
#                 print(f"Warning: Insufficient data points for column '{column_name}'.", file=sys.stderr)
#                 continue

#             marks_sorted = np.sort(marks.values)

#             density = np.linspace(marks_sorted.min(), marks_sorted.max(), 1000)
#             kernel = np.zeros_like(density)

#             for x in marks_sorted:
#                 kernel += np.exp(-(density - x) ** 2 / (2 * marks.std() ** 2))

#             kernel /= len(marks_sorted) * np.sqrt(2 * np.pi * marks.std() ** 2)

#             plt.plot(density, kernel, label=column_name)

#         plt.xlabel("Marks")
#         plt.ylabel("Density")
#         plt.title("Density Plot of Marks Distribution")

#         plt.legend()

#         plt.savefig(plot_file)
#         plt.show()

#         return True

#     except Exception as e:
#         print(f"Error: {str(e)}", file=sys.stderr)
#         return False

def plot_density_distribution(data_file, column_names, plot_file):
    try:
        df = pd.read_csv(data_file)

        # Replace 'a' with 0 in numeric columns
        numeric_cols = df.select_dtypes(include=np.number).columns.tolist()
        for col in numeric_cols:
            df[col] = pd.to_numeric(df[col], errors='coerce')

        if not column_names or (len(column_names) == 1 and column_names[0] == ""):
            # Exclude "Total" and non-numeric columns
            column_names = [col for col in numeric_cols if col.lower() != 'total']

        for column_name in column_names:
            if column_name not in df.columns:
                print(f"Warning: Column '{column_name}' not found.", file=sys.stderr)
                continue

            marks = df[column_name].dropna()

            if len(marks) < 2:
                print(f"Warning: Insufficient data points for column '{column_name}'.", file=sys.stderr)
                continue

            marks_sorted = np.sort(marks.values)

            density = np.linspace(marks_sorted.min(), marks_sorted.max(), 1000)
            kernel = np.zeros_like(density)

            for x in marks_sorted:
                kernel += np.exp(-(density - x) ** 2 / (2 * marks.std() ** 2))

            kernel /= len(marks_sorted) * np.sqrt(2 * np.pi * marks.std() ** 2)

            plt.plot(density, kernel, label=column_name)

        plt.xlabel("Marks")
        plt.ylabel("Density")
        plt.title("Density Plot of Marks Distribution")

        plt.legend()

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
    
    if not plot_density_distribution(data_file, column_names, plot_file):
        sys.exit(1)


