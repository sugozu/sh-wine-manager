## What does this script do ##
It lets you manage prefixes, applications, their launch options and parameters conveniently in a single file. And quickly run the applications with the correct settings from anywhere once you are done.  
The script generates a template/example prefix file when you first launch it. You will have to configure everything there yourself.  
It has support for running multiple different wine versions, running wine under a different user, changing the wine home directory, etc.  
The script assumes that you will want all your wine prefixes in a single location, this behavior can be altered though in the prefix file.  
If you have all your executables under the same path, you can use a variable set in the script file to shorten the cd path in your prefix file.  

**It is advisable to check the sh file before running it to set the file paths etc. where you like them.**  

## Functions ##
`Wine.sh -r [APPNAME]` - Run application, leave blank to list Wine app shortcuts.  
`Wine.sh -p [PFXNAME] [lx bin] ...` - Run linux binary with wineprefix set. Useful for running winecfg/tricks.  
`Wine.sh -u [PFXNAME]` - Update wineprefix, `-u -a` to update all prefixes.  
`Wine.sh -v` - Setup multiple wine versions.  
