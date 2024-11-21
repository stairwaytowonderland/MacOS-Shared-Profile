# MacOS-Shared-Profile

## Clone into existing folder (e.g. `/Users/Shared`)

```bash
git init
git branch -m main
git remote add origin https://github.com/stairwaytowonderland/MacOS-Shared-Profile.git
git fetch
git pull origin main
git branch --set-upstream-to=origin/main main
```
## Run setup

```bash
make configure
make install
```
