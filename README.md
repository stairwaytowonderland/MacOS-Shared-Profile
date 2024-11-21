# MacOS-Shared-Profile

## Clone into existing folder (e.g. `/Users/Shared`)

```bash
git init
git remote add origin https://github.com/stairwaytowonderland/MacOS-Shared-Profile.git
git fetch
git branch --set-upstream-to=origin/main main
git pull
```
## Run setup

```bash
make configure
make install
```
