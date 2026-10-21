# Complete Android NDK Installation

## Goal and Boundaries
Install NDK 28.2.13676358 in /Users/alexey/Library/Android/sdk for the existing Android Studio Flutter Run configurations. Do not build or launch the application from the terminal, change project sources, or change NDK versions.

## Verified State
- Official command-line tools archive downloaded (137 MB); sdk/cmdline-tools/latest exists.
- sdk/ndk/28.2.13676358 contains only .installer; installation is not complete.
- Previously started installation may still be active; current process status is unverified.
- Android Studio GUI automation was denied by macOS Accessibility permissions.

## Execution
1. Inspect the existing SDK installation process and its logs. If still downloading, monitor it rather than start a competing installer. Report actual progress to the user.
2. If the process failed, inspect its error first. Verify sdkmanager exists and use Android Studio's bundled JBR via JAVA_HOME if necessary.
3. Only after confirming no active installer is using the NDK directory, quarantine an incomplete directory to a unique temporary location. Never move a directory during an active install.
4. Run the official sdkmanager with --sdk_root=/Users/alexey/Library/Android/sdk and package 'ndk;28.2.13676358'. Keep logs visible and wait for completion. Resolve download, Java, disk-space, or license errors explicitly; do not silently accept new license terms on the user's behalf.
5. Validate successful exit, source.properties reporting Pkg.Revision = 28.2.13676358, package.xml, and the installed Darwin toolchain clang --version. Confirm sdkmanager lists the package as installed.
6. Report the verified installation result. Leave application launch to Android Studio's existing App - Debug or App - Release configuration and the Run button on the connected phone; no terminal app launch.

## Failure Handling
Do not declare success based only on the directory's existence. If downloads stall, inspect actual transfer/log activity and explain the blocker before retrying. Preserve project changes and other SDK packages. No source migration or rollout is needed; SDK installation is the only intended system change.
