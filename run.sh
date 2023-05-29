#Input checking.
if [[ $# != 0 ]]
then
    echo "Arguments must be empty."
    exit 1
fi

#Running project and creating output folder if successful.
if driver;
then
    echo "Driver ran successfully."
    folder="snapshot/output-$(date "+%Y-%m-%d-%H%M%S")"
    if !(mkdir $folder
    cp seed.txt $folder
    cp Results.txt $folder
    cp TestCases.txt $folder)
    then
        echo "Failed to create output folder."
        exit 1
    fi
    echo "Successfully created output folder."
    exit 0
else
    echo "Driver failed to run."
    exit 1
fi