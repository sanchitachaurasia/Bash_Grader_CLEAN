#!/bin/bash

# Check if the total column exists
if [ -f main.csv ] && head -n 1 main.csv | grep -q 'total'; then
    echo "Generating"
else
    echo 'Kindly run "bash submission.sh total" to add the total column and try again.'
    exit 1
fi

# Process the CSV file
awk -F, '
BEGIN {
    OFS=",";
}
NR > 1 {
    email = $1 "@iitb.ac.in";
    print $1, $2, $NF, email;
}' main.csv | sort -t, -k3,3nr -k2,2 | awk -F, -v OFS=',' '
BEGIN {
    print "Roll_No,Name,Total,Email,Rank,Percentile,Grade";
}
{
        total_students+=1;
}
{

    rank=NR;
    percentile=((total_students - rank + 0.5) / total_students) * 100;    
    if (percentile >= 95) grade = "AA";
    else if (percentile >= 85) grade = "AB";
    else if (percentile >= 70) grade = "BB";
    else if (percentile >= 50) grade = "BC";
    else if (percentile >= 30) grade = "CC";
    else if (percentile >= 15) grade = "CD";
    else if (percentile >= 5) grade = "DD";
    else grade = "F";
    print $1, $2, $3, $4, rank, percentile, grade;
}' > output.csv
cat output.csv
rm output.csv