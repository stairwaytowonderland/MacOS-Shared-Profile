# shared-profile

## Clone into existing folder (e.g. `/Users/Shared`)

```bash
git init
git branch -m main
git remote add origin https://github.com/stairwaytowonderland/shared-profile.git
git fetch
# Run the following two commands if a managed file has uncommitted changes or differs from HEAD
#git branch main origin/main
#git reset HEAD -- .
git pull origin main
git branch --set-upstream-to=origin/main main
```

## Run setup

```bash
make configure
make install
```
