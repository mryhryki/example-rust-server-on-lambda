import * as aws from "@pulumi/aws";

const lambdaRole = new aws.iam.Role("example-rust-server-on-lambda-role", {
  assumeRolePolicy: {
    Version: "2012-10-17",
    Statement: [{
      Action: "sts:AssumeRole",
      Principal: {
        Service: "lambda.amazonaws.com",
      },
      Effect: "Allow",
      Sid: "",
    }],
  },
});
new aws.iam.RolePolicyAttachment(
  "example-rust-server-on-lambda-policy-attachment",
  {
    role: lambdaRole,
    policyArn: aws.iam.ManagedPolicies.AWSLambdaExecute,
  },
);

const lambdaFunction = new aws.lambda.Function(
  "example-rust-server-on-lambda",
  {
    packageType: "Image",
    imageUri: process.env.ECR_URI,
    role: lambdaRole.arn,
  },
);

new aws.lambda.FunctionUrl("example-rust-server-on-lambda", {
  functionName: lambdaFunction.name,
  authorizationType: "NONE",
}).functionUrl.apply(console.log);
