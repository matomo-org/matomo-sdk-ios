# How can I contribute?

Welcome! We are very happy to have you here. There are always too many things to do and not enough volunteers to help. So please join! This document collect things we need help with and act as a guideline.

## Reporting bugs

Did you find a bug? Bummer! Please help us find the reason and fix them.

* Search on GitHub under [Issues](https://github.com/matomo-org/matomo-sdk-ios/issues) if it was already reported. Maybe you can add information to it?
* If you're unable to find an open issue addressing the problem, please [open a new one](https://github.com/matomo-org/matomo-sdk-ios/issues/new). Please explain your problem and include as much detail as you can as they might help the maintainers to reproduce it:
  * A clear and descriptive title.
  * Describe your issue and add exact steps to reproduce the issue. You found a crash? Please attach a symbolicated crash report.
  * If possible add a few lines of code or possibly even an example project.

## Discussing

We love to discuss changes and improvements. If there is functionality you want to add or improve please [open an issue](https://github.com/matomo-org/matomo-sdk-ios/issues/new) and describe what you want to do, why and how. Maybe the feature already exists but is hidden? Maybe somebody wants to add ideas on how to implement it.

You are always welcome to add your thoughts to an existing [issue in discussion](https://github.com/matomo-org/matomo-sdk-ios/labels/discussion).

## Submitting changes

When contributing to this repository, please first discuss the change you wish to make via an issue before making a change.

If you implemented a change please send a [Pull Request](https://github.com/matomo-org/matomo-sdk-ios/compare?expand=1) with a clear list of what you have done. Try to only tackle one thing a time. This will lead to smaller pull requests that are easier to review.

## Contributing Code

You want to contribute code? Awesome. Here are some tips that should get you started.

1. Check out the repository
2. Install the CocoaPods by running `pod install` from the checked out folder
3. Open the Workspace in Xcode

### Adding code to the SDK

In the Workspace you will find the *MatomoTracker* Project. Inside of it there is a folder for the SDK code and one for the Tests. Tests can be run from the *MatomoTracker* scheme.

### Adding example code

All the example code can be found in the Workspace, in the *Examples* folder. There is a scheme for every example application. When changing the SDK itself, it might be necessary to run a `pod update` to install all those changes in the Example applications.

### Testing

We have a small set of [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble) specs and we are always open for more.
