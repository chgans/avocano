# Avocano fork

This repository is a fork of https://github.com/GoogleCloudPlatform/avocano.
I'm using it as an experiment to setup my own django powered website.

Changes will focus on:
- Removing the JS client and Firebase, as I'm planing to have a regular Django backend/frontend.
- Enabling the CI features that are specific to the GoogleCloudPlatform project (please release, conventional commit, ...)
- Validation of PR by deploying a project from scratch (see provisioning/automation/)
- Validation of the upgrading the production project
- Maybe more...

Eventually this project will be set as read-only, and I will create my own project from scratch based on what i have achieved with my fork.

Big thank you to the GoogleCloudPlatform team for providing me with a solid base.

# 🥑 Avocano - a fake dropship sample website

Avocano is a sample dropship/fake product website, combining: 
 
 * Cloud Run API backend, written with [Django REST Framework](https://www.django-rest-framework.org/),
 * Cloud SQL database, with migrations applied through Cloud Run Jobs.
 * Terraform and Cloud Build provisioning. 

## Launch

Launch this application using the Cloud Shell:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fgooglecloudplatform%2Favocano&cloudshell_tutorial=README.walkthrough.md&cloudshell_workspace=.)

![Screenshot of the deployed application](avocano-screenshot.png)

## Use this application

Read more about how to use this application in the [docs](docs/README.md).

## Code of Conduct

Please see the [code of conduct](CODE_OF_CONDUCT.md)

## Contributions

Please see the [contributing guidelines](CONTRIBUTING.md)

## License

This sample is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).

Demo images used are part of [Emoji Kitchen](https://emojipedia.org/emoji-kitchen/), mashups of Google's emoji set. 
