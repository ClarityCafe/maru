# The Maru Experimental Board [![Build Status](https://dev.azure.com/enra0226/Maru/_apis/build/status/sr229.maru?branchName=master)](https://dev.azure.com/enra0226/Maru/_build/latest?definitionId=1&branchName=master)

Maru is a experimental board I created to better understand Chromium OS. Right now its primary aim is to be built and ultimately, support a wide range of hardware, ala-CloudReady.

## Roadmap

- [ ] :clap: MAKE :clap: IT :clap: BUILD :clap:

- [x] work on driver support.
   - [x] include Libinput support and add additional drivers.

- [ ] Omaha Update server
  - This is intended for OTA updates. We want people to use Maru as a simple update.

- [ ] Other architecture support
  - i386 won't be supported, unfortunately.

## Building Maru

You'll need to grab the entire Chromium OS Source code to build this.

### Fetching `depot_tools` 

To be able to pull the entire Chromium OS tree, we'll need to use Google's in-house tools for pulling the entire source.

```
$ sudo mkdir -p /usr/local/repo
$ sudo chmod 777 /usr/local/repo
$ cd /usr/local/repo
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ export PATH=/usr/local/repo/depot_tools:$PATH
$ umask 022

```

### Prepare environment

let's go ahead and make a `project` folder, it should look like this.

```
$ mkdir -p $HOME/project/chromiumos-R74      # This is the directory to hold Chromium OS source code, name it according to the release you are going to build.
$ mkdir -p $HOME/project/overlays            # This is the directory to hold this repository.

```
Now, we're ready to pull the Chromium OS source code.

But first we need to know which release you'd like to build via using `git ls-remote`

```
$ git ls-remote https://chromium.googlesource.com/a/chromiumos/manifest.git | grep release

```
Keep in mind you should be looking for ``release-Rxx-XXXXX.B``, since these are the "stable" versions.

When you're done selecting what repo you need to use, go ahead and run the following commands

```
$ cd $HOME/project/chromiumos-R74
$ repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git -b stabilize-10718.88.B  # The last R70 stable release
$ repo sync -j8         # Raise this number if you have a fast Internet connection

```
**Note: This Repository is only built for R74, if you need to build this to R76, then you might need to do some modificiations. We follow ArnoldTheBat upstream.**

### Enabling Google Login

If you want to enable Google login in your build, make sure you have `.googleapikeys` in your `$HOME`. `repo` will know what to do with it.

`.googleapikeys` should look like the following:

```
'google_api_key': 'your api key',
'google_default_client_id': 'your client id',
'google_default_client_secret': 'your client secret',
```
Finally, head to this [documentation](http://www.chromium.org/developers/how-tos/api-keys) to get an API key.

### Prepare the Overlay

Finally, you need to symbolic link this repo after cloning inside `project/overlays`.

```
$ cd /project/overlays
$ git clone https://github.com/sr229/maru.git

$ cd /project/chromiumos-R74/src/overlays
$ ln -s /project/overlays/maru/* .
```

### Build the image

Once that's all done, all that its left to do is run a this and wait.

```
$ export BOARD=maru-amd64
$ cros_sdk -- ./setup_board --board=${BOARD}
$ cros_sdk -- ./build_packages --board=${BOARD}
$ cros_sdk -- ./build_image --board=${BOARD}

```

The build system will make a chroot and build Chromium OS according to the Maru configuration. It should take less than 5 hours to build on a i7 with 8GB RAM, but it could be slower. 

Once the build finishes, you can find your images at `/project/chromiumos-R74/src/build/images/maru-amd64`.

## Installing the image

You can use ``dd`` in Linux or use Rufus in DD mode in Linux to your USB.

Once the image finishes writing to a USB, boot it to your PC, and cross your fingers.

## Contributing

Please read the [Chromium OS Developer Guide](http://www.chromium.org/chromium-os/developer-guide) to get yourself familiarized with how everything works.