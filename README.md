# tdl-client-spec

Describes the interaction between the client and the challenge server.

The interaction has two major components:
1. A queue system ( `./queue/QueueRunner.feature` )
2. A challenge session API ( `./runner/ChallengeSession.feature` )

The queue system is used to serve requests and receive responses, while the challenge API is used to manage to workflow and receive feedback.

![Queue system](./raw/master/challenge_system.png)


## Include Spec in language client

To include the spec in your client:

```bash
export SPEC_LOCATION=./src/test/resources/tdl/client/
export SPEC_VERSION=v0.3

# Checkout
git submodule add git@github.com:julianghionoiu/tdl-client-spec.git $SPEC_LOCATION
git submodule update --init

# Switch to tag
pushd . 
cd $SPEC_LOCATION
git checkout $SPEC_VERSION
popd

# Commit
git commit $SPEC_LOCATION -m "Added spec submodule"
```


## To release a new version spec

```bash
git add *
git commit -m "Describe the changes"
git tag -a v0.11 -m "Describe the version"
git push --tags
```