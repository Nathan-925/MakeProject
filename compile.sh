#Input filtering.
if [[ $# -gt 1 && $1 != "-debug" || $# -gt 1 ]]
then
    echo "Arguments must be empty or -debug only"
    exit 1
fi

#Adding all .h, .c, and .o files to the compile command.
files=(*)
compiledFiles=()
for (( i = ${#files[@]}-1; i >= 0; i-- ))
do
    if [[ ${files[i]} == *.[hco] ]]
    then
        compiledFiles+=(${files[i]})
    fi
done

#Arguments for the compile command. -g is added if -debug was used.
args=(-std=c11 -Wall)
if [[ $# == 1 ]]
then
    args+=(-g)
fi

if gcc -o driver ${args[@]} ${compiledFiles[@]};
then
    echo "Compilation successful."
    
    #Snapshot is archived and cleared if it exists, then a new snapshot folder is created.
    if [[ -d snapshot ]]
    then
        if sh make-snapshot.sh;
        then
            if ! rm -r snapshot;
            then
                echo "Failed to delete snapshot directory."
                exit 1;
            fi
        else
            echo "Cancelling deletion die to snapshot faliure."
            exit 1
        fi
    fi

    #Copying all .h, .c, and .o files into the snapshot folder.
    if !(mkdir snapshot
    mkdir snapshot/code
    cp *.[hco] snapshot/code);
    then
        echo "Failed to create new snapshot directory."
        exit 1
    fi
    echo "New snapshot created succesfully."
    exit 0
else
    echo "Compilation failed"
    exit 1
fi