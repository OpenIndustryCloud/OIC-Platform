# Helm Lint 

This tasks lints a helm chart. 

# Inputs
## src

This tasks requires a resource "src" which shall be a GitHub repository. 

## ci folder

The task also assumes a subfolder in the repo named "ci" that contains the bash script. 

## deploy folder

The task also assumes a subfolder in the repo named "deploy" that contains a chart, itself in a subfolder named after the src name.

So in essence, we are looking at a tree like: 

```bash
$ tree src/
src/
├── ci
│   ├── lint_helm.sh
│   ├── lint_helm.yaml
├── deploy
│   └── foobar
│       ├── Chart.yaml
│       ├── charts
│       ├── templates
│       │   ├── NOTES.txt
│       │   ├── _helpers.tpl
│       │   ├── deployment.yaml
│       │   ├── ingress.yaml
│       │   └── service.yaml
│       └── values.yaml
```

# Behavior

We basically run ```helm lint deploy app``` and exit depending on the result