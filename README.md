# Introduction
This is a Roku channel for Kino.pub. The author of this chanel has no affiliation with Kino.pub. I have put this channel together simply to have some fun and make watching this service possible through Roku.

Right now only dev mode install is supported. If there is enough demand I will try to get the channel to Roku channel store.

# Getting Started
To get started you need a couple of things.
1) Get yourself an IDE. [There is a plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript).
2) Switch your Roku into [dev mode](https://developer.roku.com/develop/getting-started/setup-guide).
3) Have fun: [Roku SDK](https://sdkdocs.roku.com/display/sdkdoc/Roku+SDK+Documentation) and [Kino.pub API](https://kinoapi.com/)
4) Build and deploy using your IDE (or manually)

# How to build
```
make
```
or if you want to send the release to tv:
```
export DEVPASSWORD=<roku tv password>; export ROKU_DEV_TARGET=<roku tv ip>; make && make install
```

`out/apps/Kino.pub.zip` will be your application.

# Contribute
Shoot an email with the account to add as a contributor to psavichev@gmail.com
