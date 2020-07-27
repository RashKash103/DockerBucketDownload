# Docker Bucket Download

Downloads a file/directory from a Google storage cloud bucket using a temporary gsutil installation. To be used in a Dockerfile to dynamically obtain contents of a build.

More information will be added at a later date.

## Installation

### Requirements
- wget
- tar
- bash

Either clone the repo or download a zip and run the `./download_resources` file.


```bash
git clone "https://github.com/RashKash103/DockerBucketDownload.git"
`````

## Usage

```text
Usage:  download_resources
            [ -d | --do-not-delete-credentials ]
            [ -k | --keep-gsutil ]
            [ -o | --overwrite ]
            [ -l | --save-location PATH ]
            [ -t | --temporary-directory DIRECTORY ]
            [ -c | --credentials FILENAME ]
            [ -h | --help ]
            PROJECT URL
        Options:
            -d | --do-not-delete-credentials        : If set, will not delete the credentials file
            -k | --keep-gsutil                      : If set, will keep the gsutil installation directory
                                                    : Note: If using this option, make sure to set the BOTO_PATH environment variable to the .boto file for authentication
            -o | --overwrite                        : If set, will overwrite any files already existing in the Docker image
            -l | --save-location PATH               : If set, will save the the downloaded folder/file from the storage bucket to PATH (default ./)
            -t | --temporary-directory DIRECTORY    : If set, will override the default temporary directory to DIRECTORY (default ./temp)
                                                    : Warning: Will clear everything in the temporary directory! (except for gsutil and .boto if --keep-gsutil is given)
            -c | --credentials FILENAME             : If set, will override the path for the credentials file to FILENAME (default ./credentials.json)
            -h | --help                             : Displays this help message
        Mandatory:
            PROJECT                                 : The Project ID as specified on the Google Cloud page
            URL                                     : The URL to download from the Google Cloud storage bucket
```

### In a Shell

```bash
./download_resources cloudProject gs://bucket/folder/
./download_resources -c "./cloudProject.json" cloudProject gs://bucket/folder/image.png
`````

### In a Dockerfile

WIth a downloaded version

```Dockerfile
COPY credentials.json /root/
COPY download_resources /root/

RUN /root/download_resources cloudProject gs://bucket/folder/*
`````

Directly from GitHub (you must have `git` installed on the image prior to cloning the repo)

```Dockerfile
COPY credentials.json /root/

# Saves the branch version information so Docker does not cache an old version of the script
ADD https://api.github.com/repos/RashKash103/DockerBucketDownload/git/refs/heads/master version.json
RUN git clone https://github.com/RashKash103/DockerBucketDownload.git

RUN DockerBucketDownload/download_resources -oc /root/credentials.json cloudProject gs://bucket/folder/*

# Clears the added files/folders
RUN rm -rf DockerBucketDownload
RUN rm version.json
```

Note: Due to how `gsutil cp` works, you cannot specify a folder as `gs://bucket/folder/`. This will cause `gsutil` not to download from the bucket. Instead, you must use `gs://bucket/folder` to download an entire folder. To download contents of a folder, you can use `gs://bucket/folder/*`.

## License
[MIT](https://choosealicense.com/licenses/mit/)
