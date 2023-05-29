# !/bin/bash

# On my honor:
#
# - I have not discussed the C language code in my program with
# anyone other than my instructor or the teaching assistants
# assigned to this course.
#
# - I have not used C language code obtained from another student,
# the Internet, or any other unauthorized source, either modified
# or unmodified.
#
# - If any C language code or documentation used in my program
# was obtained from an authorized source, such as a text book or
# course notes, that has been clearly noted with a proper citation
# in the comments of my program.
#
# - I have not designed this program in such a way as to defeat or
# interfere with the normal operation of the Curator System.
#
# Nathaniel Dunlap

# This sets up the entire project starting with the tar file.
# Extracts and moves all contents into ./files/
# creates the compile, run and clean scripts inside ./files/
# when called, checks if files/snapshot exists and if it exists, 
# archives it; then it checks if ./files/ exists,
# and if yes, packages everything into a tarfile and archives it
# and creates a new ./files/ folder as described above (i.e. fresh start)

#Input filtering.
if [[ $# -ne 1 ]]
then
    echo "Incorrect number of arguments, provide one tar file."
    exit 1
fi
if [[ $1 != *.tar ]]
then
    echo "Argument is not a tar file."
    exit 1
fi

#If a project already exists, then it is archived and deleted.
if [[ -d "files" && -d "snapshots" ]]
then
    if [[ -d "files/snapshot/code" ]]
    then
        cd files/snapshot
        tar -cf ../../snapshots/snapshot-$(date "+%Y-%m-%d-%H%M%S").tar *
        cd ../..
    fi
    cd files
    tar -cf ../snapshots/files-$(date "+%Y-%m-%d-%H%M%S").tar *
    cd ..
    rm -r files
    cd snapshots
    tar -cf ../oldsnapshots-$(date "+%Y-%m-%d-%H%M%S").tar *
    cd ..
    rm -r snapshots
fi

#Creating a new project and extracting files.
mkdir files
mkdir snapshots
tar xf $1 -C files


# Create the helper scripts inside ./files/
# see writeup for details.

compilescript=./files/compile.sh
runscript=./files/run.sh
snapshotscript=./files/make-snapshot.sh

cat << 'EOF' > $compilescript 
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
EOF

cat << 'EOF' > $runscript
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
EOF

cat << 'EOF' > $snapshotscript
#Creating archive, going into folder to avoid creating the parent directory in the archive.
cd snapshot
if tar -cf ../../snapshots/snapshot-$(date "+%Y-%m-%d-%H%M%S").tar *;
then
    echo "Snapshot archived successfully."
    exit 0
else
    echo "Snapshot archive failed."
    exit 1
fi
EOF

exit 0
