# Installation

1. Follow instruction to enable WSL https://learn.microsoft.com/en-us/windows/wsl/install
2. Enable WSL2 (currently only WSL2 is supported)
3. Download latest release from https://github.com/BOINC/boinc-buda-runner-wsl/releases
4. Navigate to the directory where you downloaded the release
5. Double-click on the `boinc-buda-runner.wsl` file
6. Open Windows Terminal and select `boinc-buda-runner` profile or run the command `wsl.exe -d boinc-buda-runner` in the terminal to start the application.
7. Run BOINC client (download and install first if you haven't done so from https://boinc.berkeley.edu/download.php) and verify that WSL and podman are detected.
8. In case of any issues, report them on the GitHub repository: https://github.com/BOINC/boinc

# Upgrade

1. Download the latest release from https://github.com/BOINC/boinc-buda-runner-wsl/releases
2. Stop BOINC client
3. Open Windows Terminal (Win+R -> type `cmd` -> press Enter)
4. Run `wsl.exe --unregister boinc-buda-runner`
5. When done - double click on the `boinc-buda-runner.wsl` or right click on it -> Open with -> Windows Subsystem for Linux
6. Open Windows Terminal (Win+R -> type `cmd` -> press Enter)
7. Type `wsl.exe -d boinc-buda-runner` and wait for the message Podman setup complete