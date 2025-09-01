# Contributing

We would love you to contribute to BulletDroid project and help make it better!

All contributions are welcome, including issues, and new docs, as well as updates, tweaks, and more.

## How to Start?

We're excited that you're interested in contributing to BulletDroid. To make sure your time is valued and your contributions are successful, please first find an issue or create a new one to solve. Then, you can start working on it.

## Code of Conduct

Help us keep BulletDroid open and inclusive. Please read and follow our [Code of Conduct](https://github.com/DannyLuna17/BulletDroid2-Dev/blob/master/CODE_OF_CONDUCT.md).

## Submit a Pull Request

Branch naming convention is as following

`TYPE-ISSUE_ID-DESCRIPTION`

example:

```
doc-548-submit-a-pull-request-section-to-contribution-guide
```

When `TYPE` can be:

- **feat** - a new feature
- **doc** - documentation only changes
- **cicd** - changes related to CI/CD system
- **fix** - a bug fix
- **refactor** - code change that neither fixes a bug nor adds a feature

**All PRs must include a commit message with the description of the changes made!**

For the initial start, fork the project and use git clone command to download the repository to your computer. A standard procedure for working on an issue would be to:

1. `git pull`, before creating a new branch, pull the changes from upstream. Your master needs to be up to date.

```
$ git pull
```

2. Create a new branch from `master` like: `doc-548-submit-a-pull-request-section-to-contribution-guide`.<br/>

```
$ git checkout -b [name_of_your_new_branch]
```

3. Work - commit - repeat (make sure you're on the correct branch!)

4. Push changes to GitHub

```
$ git push origin [name_of_your_new_branch]
```

5. Submit your changes for review
   If you go to your repository on GitHub, you'll see a `Compare & pull request` button. Click on that button.
6. Start a Pull Request
   Now submit the pull request and click on `Create pull request`.
7. Get a code review approval/reject.
8. After approval, merge your PR.
9. GitHub will automatically delete the branch after the merge is done. (they can still be restored).

## Setup From Source

To set up a working **development environment**, just fork the project git repository and install the dependencies.

### Get Started

After finishing the installation process, you can start writing and editing code.

## Dependencies

Please avoid introducing new dependencies to BulletDroid without consulting the team. New dependencies can be very helpful, but they also introduce new security and privacy risks, add complexity, and impact the project size.

Adding a new dependency should have vital value for the product with minimum possible risk.

### Sending Feedbacks and Reporting Bugs

Sending feedback is a great way for us to understand your different use cases of BulletDroid better. If you had any issues, bugs, or want to share your experience, feel free to do so on our GitHub issues page or at our [Telegram channel](https://t.me/BulletDroidChannel).

### Submitting New Ideas

If you think BulletDroid could use a new feature, please open an issue on our GitHub repository, stating as much information as you have about your new idea and its implications. We would also use this issue to gather more information, get more feedback from the community, and have a proper discussion about the new feature.

### Improving Documentation

Submitting documentation updates, enhancements, designs, or bug fixes, as well as spelling or grammar fixes is much appreciated.