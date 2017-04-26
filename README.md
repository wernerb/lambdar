# ƛR: Lambdar (forked and modified)

Run R on AWS Lambda using [Linuxbrew](http://linuxbrew.sh).

Modified so that `setup.R` is run to install packages (or any other bootstrap) and that `script.R` is executed rather than inline code.

### Run

run `make` to package a working R lambda. This creates a `.zip` you can then deploy using `make deploy`
