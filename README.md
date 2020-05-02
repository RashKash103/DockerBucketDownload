# Docker Bucket Download

Downloads a file/directory from a Google storage cloud bucket using a temporary gsutil installation. To be used in a Dockerfile to dynamically obtain contents of a build.

More information will be added at a later date.

## Installation

### Requirements
- wget
- tar
- bash

Either clone the repo or download a zip and run the `./download_resources.sh` file.


```bash
git clone "https://github.com/RashKash103/DockerBucketDownload.git"
`````

## Usage

### In a Shell

```bash
./download_resources.sh cloudProject gs://bucket/folder/
./download_resources.sh -c "./cloudProject.json" cloudProject gs://bucket/folder/image.png 
`````

### In a Dockerfile

```Dockerfile
COPY credentials.json /root/
COPY download_resources.sh /root/

RUN /root/download_resource.sh cloudProject gs://bucket/folder/
`````

## License
[MIT](https://choosealicense.com/licenses/mit/)
