# Go Test 

This tasks will run a go test for a specific app. 

# Inputs
## src

This tasks requires a resource "src" which shall be a GitHub repository. 

## ci folder

The task also assumes a subfolder in the repo named "ci" that contains the bash script. 

# Behavior

The script will simply guess where it is run from, assume it is in a subfolder, and run a go test on the upper folder. 

 
