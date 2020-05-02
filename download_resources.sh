#!/bin/bash

DELETECREDENTIALS=true
KEEPGSUTIL=false
OVERWRITE=false
SAVELOCATION="./"
TEMPORARYDIRECTORY="./temp"
CREDENTIALS="./credentials.json"

usage()
{
    echo "Usage: $0 
                [ -d | --do-not-delete-credentials ]
                [ -k | --keep-gsutil ]
                [ -o | --overwrite ]
                [ -l | --save-location PATH ]
                [ -t | --temporary-directory DIRECTORY ]
                [ -c | --credentials FILENAME ]
                PROJECT URL
            Options:
                -d | --do-not-delete-credentials        : If set, will not delete the credentials file from the docker image
                -k | --keep-gsutil                      : If set, will keep the gsutil installation directory
                -o | --overwrite                        : If set, will overwrite any files already existing in the Docker image
                -l | --save-location PATH               : If set, will save the the downloaded folder/file from the storage bucket to PATH (default ./)
                -t | --temporary-directory DIRECTORY    : If set, will override the default temporary directory to DIRECTORY (default ./temp)
                -c | --credentials FILENAME             : If set, will override the path for the credentials file to FILENAME (default ./credentials.json)
            Mandatory:
                PROJECT                                 : The Project ID as specified on the Google Cloud page
                URL                                     : The URL to download from the Google Cloud storage bucket"
    exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n $0 -o dkol:t:c: --long do-not-delete-credentials,keep-gsutil,overwrite,save-location:,temporary-directory:,credentials: -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
    case "$1" in
        -d | --do-not-delete-credentials)   DELETECREDENTIALS=false     ; shift     ;;
        -k | --keep-gsutil)                 KEEPGSUTIL=true             ; shift     ;;
        -o | --overwrite)                   OVERWRITE=true              ; shift     ;;
        -l | --save-location)               SAVELOCATION="$2"           ; shift 2   ;;
        -t | --temporary-directory)         TEMPORARYDIRECTORY="$2"     ; shift 2   ;;
        -c | --credentials)                 CREDENTIALS="$2"            ; shift 2   ;;
        --)     shift; break ;;
        *)      echo "Unexpected option: $1"
                usage ;;
    esac
done

if [ ${#@} -ne 2 ]; then
    usage
fi

if [ ! -f "$CREDENTIALS" ]; then
    echo "Error: $CREDENTIALS file not found"
    exit 2
fi

mkdir -p $TEMPORARYDIRECTORY

wget https://storage.googleapis.com/pub/gsutil.tar.gz -O "$TEMPORARYDIRECTORY/gsutil.tar.gz"
tar xfz $TEMPORARYDIRECTORY/gsutil.tar.gz -C "./$TEMPORARYDIRECTORY/"

echo -e "\n\n"

chmod 666 $CREDENTIALS
echo -e "`pwd`/$CREDENTIALS\nN\n$1" | "./$TEMPORARYDIRECTORY/gsutil/gsutil" config -e -o "`pwd`/$TEMPORARYDIRECTORY/.boto"
export BOTO_PATH="`pwd`/$TEMPORARYDIRECTORY/.boto"

echo -e "\n\n"

mkdir $TEMPORARYDIRECTORY/download
"./$TEMPORARYDIRECTORY/gsutil/gsutil" cp -r $2 "./$TEMPORARYDIRECTORY/download"

if [ "$OVERWRITE" = true ] ; then
    cp -RT "./$TEMPORARYDIRECTORY/download" "$SAVELOCATION"
else
    cp -RTn "./$TEMPORARYDIRECTORY/download" "$SAVELOCATION"
fi

if [ "$DELETECREDENTIALS" = true ] ; then
    rm -f $CREDENTIALS
fi

if [ "$KEEPGSUTIL" = true ] ; then
    rm -rf "./$TEMPORARYDIRECTORY/!(gsutil|.boto)"
else
    rm -rf "./$TEMPORARYDIRECTORY"
fi

rm $0
