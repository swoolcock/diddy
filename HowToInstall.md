# Obtaining the Source #

There are two ways to obtain the source code:
  * ZIP File
  * Hg source

### Download the Source Code from Zip ###

The fastest way is to download the latest zip file from here:
> http://diddy.googlecode.com/archive/default.zip

### Download the Source Code via Hg ###

To download the latest source (as the zip files will almost always be out of date):

Download and install a Hg Client:

> TortoiseHg: http://tortoisehg.bitbucket.org/


Create a folder called diddy on your local disk, then within that folder do a Hg Clone.

The files should now download into the new folder.

# Installation #

Once extracted or downloaded you should have a folder structure like this:

```
diddy\
  data\
  examples\
  src\
```


Go into the src folder and copy the diddy folder into your Monkey/modules folder or add diddy/src to the Monkey MODPATH.

```
c:\MonkeyPro\modules\
```

Then at the start of your Monkey file add the following line:

```
Import diddy
```

This will import all the diddy functions into your project/file. Make sure that Import mojo is before the Import diddy command.

Also ensure that you are using the latest version of Monkey.