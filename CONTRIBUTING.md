# Contributing to EMODnet data archaeology workflow

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

We welcome contributions to this project to make it better!

> **Note:** [Please don't file an issue to ask a question.](https://github.com/lab42open-team/EMODnet-data-archaeology/issues) You'll get faster results by using the [Discussions section](https://github.com/lab42open-team/EMODnet-data-archaeology/discussions) on GitHub.


[How Can I Contribute?](#how-can-i-contribute)
  * [Reporting Bugs](#reporting-bugs)
  * [Suggesting Enhancements](#suggesting-enhancements)
  * [Code Contribution](#code-contribution)
  * [Pull Requests](#pull-requests)

## How can I contribute?

### Reporting Bugs

This section guides you through submitting a bug report. Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/). Create an issue on that repository and provide the following information by filling in [the template](https://github.com/lab42open-team/EMODnet-data-archaeology/blob/master/.github/ISSUE_TEMPLATE/bug_report.md).

First check if the bug is already submitted in [Issues](https://github.com/lab42open-team/EMODnet-data-archaeology/issues) and if not press the `New issue` button and select the `bug report` template.

### Suggesting Enhancements

Suggest enhancements including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion :pencil: and find related suggestions :mag_right:.
Fill in [the template](https://github.com/lab42open-team/EMODnet-data-archaeology/blob/master/.github/ISSUE_TEMPLATE/feature_request.md), including the steps that you imagine you would take if the feature you're requesting existed.

### Code Contribution

- Create a personal fork of the project on Github.
- Clone the fork on your local machine. Your remote repo on Github is called `origin`.
```
git clone
```
- Add the original repository as a remote called `upstream`.
```
git remote -v
```
to see that the local repo is connected to the forked repo in origin. If not

```
git remote add upstream https://github.com/lab42open-team/EMODnet-data-archaeology.git
```
- If you created your fork a while ago be sure to pull upstream changes into your local repository.

```
git fetch upstream | git checkout master | git merge upstream/master
```
- Create a new branch to work on! Branch from `develop`.

```
git checkout develob

git checkout -b my-branch

```
- Implement/fix your feature, comment your code.
- Follow the code style of the project, including indentation.
- If the project has tests run them!
- Write or adapt tests as needed.
- Add or change the documentation as needed.
- Squash your commits into a single commit with git's [interactive rebase](https://help.github.com/articles/interactive-rebase). Create a new branch if necessary.
- Push your branch to your fork on Github, the remote `origin`.

### Pull requests

- From your fork open a pull request in the correct branch. Target the project's `develop` branch if there is one, else go for `master`!
- If the maintainer requests further changes just push them to your branch. The PR will be updated automatically.
- Once the pull request is approved and merged you can pull the changes from `upstream` to your local repo and delete
your extra branch(es).

And last but not least: Always write your commit messages in the present tense. Your commit message should describe what the commit, when applied, does to the code – not what you did to the code.
