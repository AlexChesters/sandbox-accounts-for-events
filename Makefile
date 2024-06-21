# Input parameters:
# - bucket: S3 bucket for build artifacts (CloudFormation needs permission to access files in this bucket)
# - profile: (optional) Name of AWS CLI credential profile to use for S3 artifact upload
# - email: (only for "deploy") Email address of initial admin user to be auto-created
#
# command syntax:
#   make build bucket=[myDeploymentBucket]
#   make build bucket=[myDeploymentBucket] profile=[myAwsProfile] branch=[currentDevelopmentBranch]
#   make deploy bucket=[myDeploymentBucket] email=[myAdminEmailAddress]
#   make deploy bucket=[myDeploymentBucket] email=[myAdminEmailAddress] profile=[myAwsProfile]

ifndef bucket
bucket=atc-dce-deployment-artifacts
$(info Parameter 'bucket' has not been set, defaulting to 'atc-dce-deployment-artifacts'.)
endif

ifndef region
region=eu-west-1
$(info Parameter 'region' has not been set, defaulting to 'eu-west-1'.)
endif

ifndef profile
profile="dce-master"
$(info Parameter 'profile' has not been set, defaulting to 'dce-master'.)
endif

ifndef branch
branch=main
$(info Parameter 'branch' has not been set, defaulting to 'main'.)
endif

# avoid interferences between "build" folder and "build" command, clear build history
.PHONY: all build clean
.SILENT:

build:
# create "build-cfn" folder if it doesn't exist and empty it
	mkdir -p build-cfn
	rm -f build-cfn/*

# create build artifacts (= zip files) for CloudFormation deployment
	zip -FSr build-cfn/sandbox-accounts-for-events.zip . -x amplify/#current-cloud-backend/\* build/\* build-cfn/\* \*dist/\* \*.DS_Store\* \*.vscode/\* \*.git/\* src/aws-exports.json\* \*amplify-meta.json\* amplify/team-provider-info.json\* \*awscloudformation\* \*node_modules\* amplify/.config/local-\*
	cd install/cfn-lambda/dceHandleTerraFormDeployment && zip -FSr ../../../build-cfn/sandbox-accounts-for-events-lambda-terraform.zip . && cd -
	cd install/cfn-lambda/dceHandleAmplifyDeployment && zip -FSr ../../../build-cfn/sandbox-accounts-for-events-lambda-amplify.zip . && cd -

# upload build artifacts and CloudFormation template to specified S3 bucket
	aws s3 sync build-cfn s3://$(bucket) --profile $(profile)
	aws s3 cp install/sandbox-accounts-for-events-install.yaml s3://$(bucket)/sandbox-accounts-for-events-install.yaml --profile $(profile)


deploy:
# check if "email" parameter has bet set, else cancel script execution
	if [ -z "$(email)" ]; then \
		echo "*** Missing command line parameter 'email=[admin_email_address]'.  Stop."; \
	else \
		aws cloudformation deploy \
		--stack-name Sandbox-Accounts-for-Events \
		--template-file install/sandbox-accounts-for-events-install.yaml \
		--parameter-overrides ParameterKey=AdminUserEmailInput,ParameterValue=$(email) ParameterKey=RepositoryBucket,ParameterValue=$(bucket) \
		--capabilities CAPABILITY_IAM --profile $(profile) \
		--region $(region); \
	fi

delete:
	aws cloudformation delete-stack \
	--stack-name Sandbox-Accounts-for-Events --profile $(profile) \
	--region $(region)

create-bucket:
	aws s3 mb s3://$(bucket) --region $(region) --profile $(profile)

delete-bucket:
	aws s3 rb s3://$(bucket) --region $(region) --profile $(profile) --force

