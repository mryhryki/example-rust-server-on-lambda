DOCKER_TAG     := experimental:example-rust-server-on-lambda
AWS_ACCOUNT_ID  = $(shell aws sts get-caller-identity | jq -r ".Account")
ECR_REPOSITORY  = ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
ECR_URI         = ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${DOCKER_TAG}

deploy: push-image pulumi-up

remove: pulumi/node_modules
	cd ./pulumi/ && ECR_URI="${ECR_URI}" pulumi down

pulumi-up: pulumi/node_modules
	cd ./pulumi/ && ECR_URI="${ECR_URI}" pulumi up

push-image: build
	aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin "${ECR_URI}"
	docker tag "${DOCKER_TAG}" "${ECR_URI}"
	docker push "${ECR_URI}"

run-local: build
	docker run --rm -p "8080:8080" "${DOCKER_TAG}"

build:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
	printf "${DOCKER_TAG}" > .dockertag
	docker build --tag "${DOCKER_TAG}" .

pulumi/node_modules: pulumi/package.json pulumi/package-lock.json
	cd ./pulumi/ && npm ci
