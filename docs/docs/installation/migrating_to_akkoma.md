# Migrating to Akkoma

**Akkoma does not currently have a stable release, until 3.0, all builds should be considered "develop"**

## Why should you migrate?

aside from actually responsive maintainer(s)? let's lookie here, we've got:

- custom emoji reactions
- misskey markdown (MFM) rendering and posting support
- elasticsearch support (because pleroma search is GARBAGE)
- latest develop pleroma-fe additions
- local-only posting
- probably more, this is like 3.5 years of IHBA additions finally compiled

## Actually migrating

Let's say you're very cool and have decided to move to the cooler
fork of Akkoma - luckily this isn't very hard.

You'll need to update the backend, then possibly the frontend, depending
on your setup.

## From Source

If you're running the source Akkoma install, you'll need to set the
upstream git URL then just rebuild - that'll be:

```bash
git remote set-url origin https://akkoma.dev/AkkomaGang/akkoma.git/
git fetch origin
git pull -r
# or, if you're on an instance-specific branch, you may want
# to run "git merge stable" instead (or develop if you want)
```

Then compile, migrate and restart as usual.

## From OTP

This will just be setting the update URL - find your flavour from the [mapping on the install guide](../otp_en/#detecting-flavour) first.

```bash
export FLAVOUR=[the flavour you found above]

./bin/pleroma_ctl update --zip-url https://akkoma-updates.s3-website.fr-par.scw.cloud/develop/akkoma-$FLAVOUR.zip
./bin/pleroma_ctl migrate
```

Then restart. When updating in the future, you canjust use

```bash
./bin/pleroma_ctl update --branch develop
```

## Frontend changes

Akkoma comes with a few frontend changes as well as backend ones,
your upgrade path here depends on your setup

### I just run with the built-in frontend

You'll need to run a couple of commands,

```bash
# From source
mix pleroma.frontend install pleroma-fe
# you'll probably want this too
mix pleroma.frontend install admin-fe

# OTP
./bin/pleroma_ctl frontend install pleroma-fe
# you'll probably want this too
./bin/pleroma_ctl frontend install admin-fe
```

### I've run the mix task to install a frontend

Hooray, just run it again to update the frontend to the latest build.
See above for that command.

### I compile the JS from source

Your situation will likely be unique - you'll need the changes in the
[forked pleroma-fe repository](https://akkoma.dev/AkkomaGang/pleroma-fe),
and either merge or cherry-pick from there depending on how you've got
things.