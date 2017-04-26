# Lambdar: Build R for Amazon Linux and deploy to AWS Lambda
name=lambdar
bucket=mybucket
functionname=myrlambda

R_VERSION=3.3.2

.DELETE_ON_ERROR:
.SECONDARY:

all: $(name).zip

deploy: $(name).zip.json

# Bundle up R and all of its dependencies
r-%.tar.gz: lambdar.mk
	docker run -v $(PWD):/xfer -w /xfer henrikbengtsson/lambdar:build make -f lambdar.mk

test-version: r-$(R_VERSION).tar.gz test-r-interactive.sh
	docker run --env R_VERSION=$(R_VERSION) -v $(PWD):/xfer -w /xfer lambci/lambda-base bash -C test-r.sh

test: r-$(R_VERSION).tar.gz
	docker run -it --env INTERACTIVE=true --env R_VERSION=$(R_VERSION) -v $(PWD):/xfer -w /xfer lambci/lambda-base bash -C test-r.sh

# Build the zip archive for AWS Lambda
%.zip: %.js r-$(R_VERSION).tar.gz
	zip -qr $@ $^ *.R

# Deploy the zip to Lambda
%.zip.json: %.zip
	aws s3 --region eu-west-1 cp $(name).zip s3://$(bucket)/ 
	aws --region eu-west-1 lambda update-function-code --function-name $(functionname) --s3-bucket $(bucket) --s3-key $(name).zip

clean:
	@rm -f r-$(R_VERSION).tar.gz
	@rm -f $(name).zip
