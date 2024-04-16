# # # it's 1 am but it works, for all if nothing/wrong, finallyyyy ಠ_ಠ
# # # uhhhh rishabh said include it for if 2 or more arguments are give, will have to change both now
# # works so well ahhh (ﾉ◕ヮ◕)ﾉ*:・ﾟ✧ 
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

# def plot_marks_distribution(data_file, column_names, plot_file):
#     try:
#         df = pd.read_csv(data_file)
#         # df.replace('a', 0, inplace=True)
#         if len(column_names) == 1 and column_names[0] == "":
#             # Exclude "Total" and non-numeric columns
#             numeric_cols = df.select_dtypes(include=np.number).columns.tolist()
#             column_names = [col for col in numeric_cols if col.lower() != 'total']

#         for column_name in column_names:
#             if column_name not in df.columns:
#                 print(f"Warning: Column '{column_name}' not found.", file=sys.stderr)
#                 continue

#             marks = df[column_name].dropna()
#             mark_counts = marks.value_counts().sort_index()

#             plt.plot(mark_counts.index, mark_counts.values, marker='o', linestyle='-', label=column_name)

#         plt.xlabel("Marks")
#         plt.ylabel("Number of Students")
#         plt.title("Marks Distribution")
#         plt.grid(True)
#         plt.legend()
#         plt.savefig(plot_file)
#         plt.show()

#     except Exception as e:
#         print(f"Error: {str(e)}", file=sys.stderr)
#         sys.exit(1)

# if __name__ == "__main__":
#     data_file = sys.argv[1]
#     plot_file = sys.argv[-1]
#     column_names = sys.argv[2:-1]  # Arguments between data file and plot file are column names
    
#     plot_marks_distribution(data_file, column_names, plot_file)
def plot_marks_distribution(data_file, column_names, plot_file):
    try:
        df = pd.read_csv(data_file)

        # Replace 'a' with 0 in numeric columns
        numeric_cols = df.select_dtypes(include=np.number).columns.tolist()
        for col in numeric_cols:
            df[col] = pd.to_numeric(df[col], errors='coerce')

        if len(column_names) == 1 and column_names[0] == "":
            # Exclude "Total" and non-numeric columns
            column_names = [col for col in numeric_cols if col.lower() != 'total']

        for column_name in column_names:
            if column_name not in df.columns:
                print(f"Warning: Column '{column_name}' not found.", file=sys.stderr)
                continue

            marks = df[column_name].dropna()
            mark_counts = marks.value_counts().sort_index()

            plt.plot(mark_counts.index, mark_counts.values, marker='o', linestyle='-', label=column_name)

        plt.xlabel("Marks")
        plt.ylabel("Number of Students")
        plt.title("Marks Distribution")
        plt.grid(True)
        plt.legend()
        plt.savefig(plot_file)
        plt.show()

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    data_file = sys.argv[1]
    plot_file = sys.argv[-1]
    column_names = sys.argv[2:-1]  # Arguments between data file and plot file are column names
    
    plot_marks_distribution(data_file, column_names, plot_file)