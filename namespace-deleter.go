// namespace-deleter.go
// WIP
// this script will (so far) fetch the required terraform files to destroy AWS resources during
// deleted namespace cleanup.

// Usage: go run namespace-deleter.go [namespace-name]
//
// You'll still need to manually head into the created resources directory and do tf init / apply
// to actually delete the resources.

package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func checkInRepo() {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("failed to get current directory: %s", err)
	}

	if !strings.Contains(wd, "cloud-platform-environments") {
		log.Fatalf("this script must be run inside of cloud-platform-environments repository")
	}
}

func checkGitRepo() {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("failed to get current directory: %s", err)
	}

	if _, err := os.Stat(filepath.Join(wd, ".git")); os.IsNotExist(err) {
		log.Fatalf("working directory is not a git repository")
	}

}

// Check namespace directory exists. If it does, abort and print error message
func checkNamespaceDir(namespace string) {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("failed to get current directory: %s", err)
	}

	namespaceDir := filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace)
	if _, err := os.Stat(namespaceDir); err == nil {
		log.Fatalf("Namespace directory still exists in repository: %s", namespaceDir)
	}
}

// run git rev-list command to get the commit hash of the PR in which the namespace was deleted
func getCommitHash(namespace string) string {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("failed to get current directory: %s", err)
	}

	hash, err := exec.Command("git", "rev-list", "-n", "1", "HEAD", "--", filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace, "resources")).Output()
	if err != nil {
		log.Fatalf("failed to get commit hash: %s", err)
	}

	commitHash := strings.TrimSuffix(string(hash), "\n")
	fmt.Println("Namespace deleted in commit hash: " + commitHash)

	return string(commitHash)
}

// Checkout  main, variables and versions.tf files from the commit hash from directory namespaces/live.cloud-platform.service.justice.gov.uk/[namespace-name]/resources
func checkoutFiles(commitHash string, namespace string) {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("failed to get current directory: %s", err)
	}

	err = exec.Command("git", "checkout", (commitHash + "^"), filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace, "resources", "main.tf")).Run()
	if err != nil {
		log.Fatalf("failed to checkout main.tf file: %s", err)
	}

	err = exec.Command("git", "checkout", (commitHash + "^"), filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace, "resources", "variables.tf")).Run()
	if err != nil {
		log.Fatalf("failed to checkout variables.tf file: %s", err)
	}

	err = exec.Command("git", "checkout", (commitHash + "^"), filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace, "resources", "versions.tf")).Run()
	if err != nil {
		log.Fatalf("failed to checkout versions.tf file: %s", err)
	}

	fmt.Println("Required terraform files for destroy checked out in: " + filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace, "resources"))
	err = exec.Command("ls", "-l", filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace, "resources")).Run()
	if err != nil {
		log.Fatalf("failed to list files in directory: %s", err)
	}

}

// Delete namespace directory - unused as of now...
func deleteNamespaceDir(namespace string) {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("failed to get current directory: %s", err)
	}

	namespaceDir := filepath.Join(wd, "namespaces/live.cloud-platform.service.justice.gov.uk", namespace)
	err = os.RemoveAll(namespaceDir)

	if err != nil {
		log.Fatalf("failed to delete namespace directory: %s", err)
	}

	fmt.Printf("Deleted namespace directory: %s\n", namespaceDir)
}

func main() {
	if len(os.Args) < 1 {
		log.Fatalf("Usage: namespace-deleter.go [namespace-name]")
	}

	namespace := os.Args[1]

	checkInRepo()
	checkGitRepo()
	checkNamespaceDir(namespace)
	checkoutFiles(getCommitHash(namespace), namespace)

}
