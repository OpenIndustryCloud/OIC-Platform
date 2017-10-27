# Function Test 

This tasks will test a Fission Function written in Go by comparing an expected input to an expected output. 

# Inputs
## src

This tasks requires a resource "src" which shall be a GitHub repository with the python code at the root and in a single file. It will be mounted at /userfunc as required by the Fission framework.  

# Behavior

We apply a simple bash script that will run a query against the code after specializing the function. We effectively run a simple CURL method agains the function, and compare the expected output vs. the actual output. We then emit a log message with the status OK or KO, and exit accordingly. 

# Docker Image

We use a custom image based on the Fission Env, customized with our own set of requirements. You can check the code [here](/src/docker-images/fission/environments/go/test/Dockerfile)