# Docker Lint 

This tasks will look up Dockerfiles in a directory and lint them all. 

# Inputs
## src

This tasks requires a resource "src" which shall be a GitHub repository containing the source code, mounted at /src in the container. 

## ci folder

The task also assumes a subfolder in the repo named "ci" that contains the bash script. 

# Behavior

We apply a simple bash script that will lookup all files in the folder that start with "Dockerfile", then lint them. This means you can have several Dockerfiles for each of your contexts (GPU, non GPU, python2 or 3...)

 
