package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsS3Module(t *testing.T) {
	t.Parallel()

	// Generate a random bucket name to prevent conflicts
	// Use lowercase letters and numbers only for S3 bucket names
	uniqueID := strings.ToLower(random.UniqueId())
	bucketName := fmt.Sprintf("terratest-s3-bucket-%s", uniqueID)

	// Construct the terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/simple",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"bucket_name": bucketName,
		},
	})

	// At the end of the test, run `terraform destroy`
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`
	terraform.InitAndApply(t, terraformOptions)

	// Get the bucket ID from the outputs
	bucketID := terraform.Output(t, terraformOptions, "bucket_name")

	// Verify that the bucket exists
	aws.AssertS3BucketExists(t, "us-east-1", bucketID)

	// Verify bucket has correct settings - these would need the AWS SDK to check
	// You can expand this section to test specific properties
}