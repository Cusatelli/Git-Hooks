# Git-Hooks <!-- omit in toc -->

<img src="https://repository-images.githubusercontent.com/662103045/52d15f7b-a96b-4673-9c66-a3c8fd962cc5" alt="" style="width:100%;"/>

## Table of contents <!-- omit in toc -->

- [Introduction](#introduction)
- [Build \& Deploy](#build--deploy)
- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [Conventions](#conventions)
- [License](#license)
- [Contact](#contact)

## Introduction

The Git-Hooks project aims to provide a solution for automating certain tasks in Git repositories, regardless of the version control system (VCS) platform being used (e.g., GitHub, GitLab, Bitbucket). It focuses on local Git operations and utilizes Git hooks, which are located in the `.git/hooks/` directory.

The main purpose of this project is to enable automatic prefixing of commit messages with the correct branch or ticket number. Additionally, it attempts to add commit types such as `feat`, `refactor`, `fix`, or `chore` based on the first entry of the staged items. The commit message format follows the guidelines of the **Conventional Commits v1.0.0** specification, which can be found at [https://www.conventionalcommits.org/en/v1.0.0/#summary](https://www.conventionalcommits.org/en/v1.0.0/#summary).

<p align="right">(<a href="#top">back to top</a>)</p>

## Build & Deploy

[To be filled with build and deployment instructions]

<p align="right">(<a href="#top">back to top</a>)</p>

## Install

To install and use the Git-Hooks project, follow these steps:

1. Clone the repository:
   ```bash
   git clone git@github.com:Cusatelli/Git-Hooks.git
   cd Git-Hooks
   ```
2. [Additional installation instructions if needed]

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage

To use the Git Hooks solution, follow these steps:

1. Navigate to the Git-Hooks directory:

   Copy code

   ```bash
   cd Git-Hooks/src
   ```

2. Customize the hooks according to your requirements. Modify the scripts located in the src directory:
   - **Create-PrepareCommitMessage.sh**: A script that sets up prepare-commit-msg to automatically prefix commits with the correct branch/ticket number and add commit types based on the staged items.
   - **Set-Configuration.sh**: A script that configures Git-Hooks, including the issue pattern, issue prefix, and whether to use conventional commits.
3. After customizing the hooks, run them in your project's directory.
4. Open PowerShell and run `.\Set-Configuration.sh` to access the settings menu. Alternatively, you can edit the `settings.json` file directly if preferred.
5. Once the configuration settings are complete, execute the `.\Create-PrepareCommitMessage.sh` script in PowerShell to automatically generate the prepare-commit-msg hook.
6. The appropriate commands will be executed automatically to enable the configured functionality.
7. You're all set! The Git hooks will now be triggered automatically when performing Git operations in your project.

<p align="right">(<a href="#top">back to top</a>)</p>

<p align="right">(<a href="#top">back to top</a>)</p>

## Maintainers

[To be filled with maintainers' information]

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing

Contributions to the Git-Hooks project are welcome. If you would like to contribute, please contact [@Cusatelli](https://github.com/Cusatelli) for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

## Conventions

The Git-Hooks project follows the Conventional Commits specification for commit message formatting. The general format is as follows:

```
<type>(<scope>): <subject>
```

The `<scope>` part is optional.

The following commit types are used:

- `feat`: New feature for the user (not a new feature for a build script)
- `fix`: Bug fix for the user (not a fix to a build script)
- `docs`: Changes to the documentation
- `style`: Formatting, missing semicolons, etc. (no production code change)
- `refactor`: Refactoring production code, e.g., renaming a variable
- `test`: Adding missing tests, refactoring tests (no production code change)
- `chore`: Updating grunt tasks, etc. (no production code change)

For more details, please refer to the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification.

<p align="right">(<a href="#top">back to top</a>)</p>

## License

No License.

<p align="right">(<a href="#top">back to top</a>)</p>

## Contact

For any inquiries or questions, please contact Cusatelli at [github.cusatelli@gmail.com](mailto:github.cusatelli@gmail.com).

<p align="right">(<a href="#top">back to top</a>)</p>
