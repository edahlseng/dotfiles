autoload -U add-zsh-hook
check-terraform-version() {
	if [[ -e "./main.tf" ]]; then
		desiredTerraformVersion=$(cat main.tf | grep --extended-regexp '^\s*required_version\s*=\s*"\s*(?:=|>=)?\s*[0-9]+\.[0-9]+\.[0-9]+\s*"\s*$' | head | sed -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/')
		tfenv install "${desiredTerraformVersion}" && tfenv use "${desiredTerraformVersion}"
	fi
}
add-zsh-hook chpwd check-terraform-version
check-terraform-version
