# openHAB on Snappy
See openHAB wiki at https://github.com/openhab/openhab/wiki/Ubuntu-Snappy for further instructions.

**Hint**: At the moment (March 4th, 2015) snappy has no possibility to add software, for which a license has to be accepted by the user. So for now extract a copy of a jdk in the `jdk` folder and build your own snap.

**Hint**: Please also download [openHAB](http://openhab.org) and the demo configuration if you not have an existing configuration to the `openhab` folder. Do not rename that folder, due to a bug it's case sensitive.

**Hint**: The `start.sh` in the `openhab`-Folder is not used. Instead `bin/start.sh` is the starting script, which uses the local java and configures some other directories because the folder where the snap resides is read only.