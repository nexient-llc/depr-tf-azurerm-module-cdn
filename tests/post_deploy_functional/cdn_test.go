package test

// Basic imports
import (
	"os"
	"path"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/suite"
)

// Define the suite, and absorb the built-in basic suite
// functionality from testify - including a T() method which
// returns the current testing context
type TerraTestSuite struct {
	suite.Suite
	TerraformOptions *terraform.Options
	suiteSetupDone   bool
}

// setup to do before any test runs
func (suite *TerraTestSuite) SetupSuite() {
	// Ensure that the destroy method is called even if the apply fails
	defer func() {
		if !suite.suiteSetupDone {
			terraform.Destroy(suite.T(), suite.TerraformOptions)
		}
	}()
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(suite.T(), "../..", ".")
	_ = files.CopyFile(path.Join("..", "..", ".tool-versions"), path.Join(tempTestFolder, ".tool-versions"))
	pwd, _ := os.Getwd()
	suite.TerraformOptions = terraform.WithDefaultRetryableErrors(suite.T(), &terraform.Options{
		TerraformDir: tempTestFolder,
		VarFiles:     [](string){path.Join(pwd, "..", "minimal.tfvars")},
	})
	// unable to make the terraform idempotent for the CDN delivery_rules (request_uri_condition, url_path_condition)
	terraform.InitAndApply(suite.T(), suite.TerraformOptions)
	suite.suiteSetupDone = true
}

// TearDownAllSuite has a TearDownSuite method, which will run after all the tests in the suite have been run.
func (suite *TerraTestSuite) TearDownSuite() {
	terraform.Destroy(suite.T(), suite.TerraformOptions)
}

// In order for 'go test' to run this suite, we need to create
// a normal test function and pass our suite to suite.Run
func TestRunSuite(t *testing.T) {
	suite.Run(t, new(TerraTestSuite))
}

// All methods that begin with "Test" are run as tests within a suite.
func (suite *TerraTestSuite) TestCDN() {

	actualCdnProfileName := terraform.Output(suite.T(), suite.TerraformOptions, "cdn_profile_name")
	actualCdnEndpointName := terraform.Output(suite.T(), suite.TerraformOptions, "cdn_endpoint_name")
	expectedCdnProfileName := "demo-eus-dev-000-cdn-000"
	expectedCdnEndpointName := "demo-eus-dev-000-ep-000"
	//expectedRgName := "demofn-eus-dev-000-rg-000"
	// NOTE: "subscriptionID" is overridden by the environment variable "ARM_SUBSCRIPTION_ID". <>
	//subscriptionID := ""
	suite.Equal(actualCdnProfileName, expectedCdnProfileName, "The CDN profile names should match")
	suite.Equal(actualCdnEndpointName, expectedCdnEndpointName, "The CDN endpoint names should match")
	suite.NotEmpty(actualCdnProfileName, "Profile Name cannot be empty")
	// azure.AppExists(suite.T(), expectedFunctionName, expectedRgName, subscriptionID)
}
