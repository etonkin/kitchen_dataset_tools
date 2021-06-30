#!/bin/bash

TARGETDIR="."
# Rostock annotation dataset
# http://rosdok.uni-rostock.de/resolve/id/rosdok_document_0000012810
challengemode=unknown
if [[ "$1" == "challenge1" ]]; then
    challengemode="manual";
elif [[ "$1" == "challenge2" ]]; then
    challengemode="ml";
else
    echo "Specify which challenge you would like to take part in: manual annotation (challenge1) or automated/semi-automated (challenge2)";
    echo "Example: $0 challenge1";
    exit;
fi
echo $1 $challengemode;

TARGETDIR="./challenge-$challengemode/"
echo "Downloading into $TARGETDIR";

if [ ! -d $TARGETDIR ]; then 
	mkdir $TARGETDIR;
 	if [ $? != 0 ]; then 

		echo "Could not create directory"
		exit;
	fi
fi 
if [ -d $TARGETDIR ]; then 
	cd $TARGETDIR;
else 
	echo "Can't create download directory";
	exit; 
fi
markupdata=rostock-cmu-semantic-annotation.zip
markupdir=rostock-cmu-semantic-annotation
md5exec="";
path_to_md5=$(which md5 2> /dev/null);
if [ -x "$path_to_md5" ] ; then
    md5exec=$path_to_md5;
else
    path_to_md5sum=$(which md5sum 2>/dev/null);
    if [ -x "$path_to_md5sum" ]; then
        md5exec="$path_to_md5sum --tag";
    fi
fi
if [[ -e $markupdata ]]; then
    md5markup=$($md5exec $markupdata | cut -d ' ' -f 4);
    if [ "$md5markup" != "f24e2a65aba3277f80f44fdc4ecf59a3" ]; then
        # md5 does not match
        wget http://rosdok.uni-rostock.de/file/rosdok_document_0000012810/rosdok_derivate_0000044584/data.zip -O $markupdata
    else
        echo "$markupdata already present and complete";
    fi
else
    wget http://rosdok.uni-rostock.de/file/rosdok_document_0000012810/rosdok_derivate_0000044584/data.zip -O $markupdata
fi
if [ ! -e "$markupdir" ]; then
    unzip $markupdata
    mv Data $markupdir
fi

# Three subdatasets are annotated, Brownies, Sandwich and Eggs
# For this challenge, we ask you not to use the audio feed or motion capture or the BodyMedia device data. You can use the video, the eWatch wearable data, the IMUs and RFID data.
brownies_touse="S54 S32 S31 S09"
sandwich_touse="S16 S25 S34 S15"
eggs_touse="S08 S20 S16 S50"
# Training and test sets (ml challenge mode)
brownies_training="S47 S54 S13 S31 "
sandwich_training="S12 S16 S25 S34"
eggs_training="S28 S08 S20 S16"
brownies_test="S09"
sandwich_test="S15"
eggs_test="S50"
if [[ ! -e cmu-data ]]; then
    mkdir cmu-data;
fi

function cmu_download {
    participant=$1
    itemrecipe=$2;
    itemmode=$3;
    testmode=$4;
    dldir=$5;
    echo $participant $itemrecipe $itemmode;
    afname=$x"_"$itemrecipe"_"$itemmode;
    echo $afname;
    echo ASDF wget $testmode http://kitchen.cs.cmu.edu/Main/$afname.zip -O cmu-data/$dldir$x/$afname.zip
    wget $testmode http://kitchen.cs.cmu.edu/Main/$afname.zip -O cmu-data/$dldir$x/$afname.zip
}

testmode="--spider";
testmode="-c"
if [[ "$challengemode" == "manual" ]]; then
    echo "Setting up data for challenge1";
    for x in $brownies_touse; do
        if [ ! -e cmu-data/$x ]; then
            mkdir cmu-data/$x/
        fi
        cmu_download $x Brownie Video $testmode
        cmu_download $x Brownie eWatch $testmode
        cmu_download $x Brownie RFID $testmode
        cmu_download $x Brownie 6DOFv4 $testmode
        cmu_download $x Brownie 3DMGX1 $testmode
    done

    for x in $sandwich_touse; do
        afname=$x"_Sandwich_Video";
        echo $afname;
        if [[ ! -e cmu-data/$x ]]; then
            mkdir cmu-data/$x/
        fi
        cmu_download $x Sandwich Video $testmode
        cmu_download $x Sandwich eWatch $testmode
        cmu_download $x Sandwich RFID $testmode
        cmu_download $x Sandwich 6DOFv4 $testmode
        cmu_download $x Sandwich 3DMGX1 $testmode
    done

    for x in $eggs_touse; do
        afname=$x"_Eggs_Video";
        echo $afname;
        if [[ ! -e cmu-data/$x ]]; then
            mkdir cmu-data/$x/
        fi
        cmu_download $x Eggs Video $testmode
        cmu_download $x Eggs eWatch $testmode
        cmu_download $x Eggs RFID $testmode
        cmu_download $x Eggs 6DOFv4 $testmode
        cmu_download $x Eggs 3DMGX1 $testmode
    done
fi

if [[ "$challengemode" == "ml" ]]; then
    echo "Setting up data for challenge2 (ml)";
    if [[ ! -d cmu-data/ ]]; then
            mkdir cmu-data/
    fi

    if [[ ! -e cmu-data/training ]]; then
        mkdir cmu-data/training;
    fi

    if [[ ! -e cmu-data/test ]]; then
        mkdir cmu-data/test;
    fi

    if [[ ! -e cmu-data/Brownie ]]; then
        mkdir cmu-data/test/Brownie;
        mkdir cmu-data/training/Brownie;
        for x in $brownies_training; do
            cmu_download $x Brownie Video "$testmode" training/
            cmu_download $x Brownie eWatch $testmode "training/"
            cmu_download $x Brownie RFID $testmode "training/"
            cmu_download $x Brownie 6DOFv4 $testmode "training/"
            cmu_download $x Brownie 3DMGX1 $testmode "training/"
        done

        for x in $brownies_test; do
            cmu_download $x Brownie Video $testmode test/
            cmu_download $x Brownie eWatch $testmode test/
            cmu_download $x Brownie RFID $testmode test/
            cmu_download $x Brownie 6DOFv4 $testmode test/
            cmu_download $x Brownie 3DMGX1 $testmode test/
        done
    fi

    if [[ ! -e cmu-data/Sandwich ]]; then
        mkdir cmu-data/test/Sandwich;
        mkdir cmu-data/training/Sandwich;
        for x in $sandwich_training; do
            cmu_download $x Sandwich Video $testmode training/
            cmu_download $x Sandwich eWatch $testmode training/
            cmu_download $x Sandwich RFID $testmode training/
            cmu_download $x Sandwich 6DOFv4 $testmode training/
            cmu_download $x Sandwich 3DMGX1 $testmode training/
        done

        for x in $sandwich_test; do
            cmu_download $x Sandwich Video $testmode test/
            cmu_download $x Sandwich eWatch $testmode test/
            cmu_download $x Sandwich RFID $testmode test/
            cmu_download $x Sandwich 6DOFv4 $testmode test/
            cmu_download $x Sandwich 3DMGX1 $testmode test/
        done
    fi

    if [[ ! -e cmu-data/Eggs ]]; then
        mkdir cmu-data/test/Eggs;
        mkdir cmu-data/training/Eggs;
        for x in $eggs_training; do
            cmu_download $x Eggs Video $testmode training/
            cmu_download $x Eggs eWatch $testmode training/
            cmu_download $x Eggs RFID $testmode training/
            cmu_download $x Eggs 6DOFv4 $testmode training/
            cmu_download $x Eggs 3DMGX1 $testmode training/
        done

        for x in $eggs_test; do
            cmu_download $x Eggs Video $testmode test/
            cmu_download $x Eggs eWatch $testmode test/
            cmu_download $x Eggs RFID $testmode test/
            cmu_download $x Eggs 6DOFv4 $testmode test/
            cmu_download $x Eggs 3DMGX1 $testmode test/
        done
    fi
fi

# vim: ts=4 sw=4 et
