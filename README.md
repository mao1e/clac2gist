# clac2gist

Save your [clac](https://clac.cs.columbia.edu) files directly to a GitHub Gist with one script.

Before pushing, the script automatically cleans up:
- `.git` directories
- `mbox` files
- Executable files

## Prerequisites

Install the GitHub CLI and authenticate:

```bash
brew install gh
gh auth login
```

When prompted, use these settings:

| Prompt | Answer |
|---|---|
| Where do you use GitHub? | `GitHub.com` |
| Preferred protocol for Git operations? | `SSH` |
| Upload your SSH public key? | `/Users/<you>/.ssh/id_ed25519.pub` |
| Title for your SSH key? | Anything you want (e.g. `GitHub CLI`) |

## Usage

```bash
chmod +x clac2gist.sh
./clac2gist.sh
```
