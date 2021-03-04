#!/bin/bash
if [ -n "${WVER}" ]; then
  if [ -z "${winepath}" ]; then
    export winepath="/opt/wine-${WVER}/usr"
    if [ -d "${winepath}" ]; then
      export PATH="$winepath/bin:$PATH"
      export LD_LIBRARY_PATH="$winepath/lib:$LD_LIBRARY_PATH"
      export WINESERVER="$winepath/bin/wineserver"
      export WINELOADER="$winepath/bin/wine"
      export WINEDLLPATH="$winepath/lib/wine"
    fi
  fi
fi
if [ "${1}" != "-v" ]; then
  export WMGR=`readlink -f "$0"`
  # home directory (/home, not /home/user), in-case you want to run your Wine applications under a sandbox or different user
  export UDIR="$HOME"
  # user name
  export USER="Wuser"
  export USERNAME="$USER"
  export LOGNAME="$USER"
  export HOME="$UDIR/$USER"

  # file paths for wine 
  export WPFXF="$UDIR/Wine/WApps" # prefix file path and name
  export WPFXD="$UDIR/Wine/.pfx/" # directory which will contain all your wine-prefixes.
  export WWRKD="$UDIR/Wine/.Win/" # if all your exes are under the same directory, 
  # this is the only path you need to modify if you change where you store your apps, no need to edit the prefix file.
  if [ ! -f "${WPFXF}" ]; then
    printf 'case "${1}" in\n  PFX)\n    export WINEPREFIX="${WPFXD}${2}"\n    case "${2}" in\n    W32)#p\n      export WINEARCH=win32\n      WVER=4.20 . ${WMGR} -v\n      export WTX=()\n    ;;\n    W64)#p\n      export WTX=(d3dx9_43 d3dx11_43)\n    ;;\n  esac\n  ;;\n  Appname1)#e\n    cd "~/working/directory/path"\n    . ${WPFXF} PFX W32\n    taskset 0x3 wine "program.exe" -changedir\n  ;;\n  Appname2)#e\n    cd "${WWRKD}path/from/variable/in/Wine.sh"\n    . ${WPFXF} PFX W64\n    nohup wine "game_that_takes_arguments.exe" ${@:2} &\n  ;;\n  Appname3)#e\n    cd "${WWRKD}good/if/all/your/windows/apps/are/in/same/path"\n    . ${WPFXF} PFX W64\n    __GL_ExtensionStringVersion=17700 wine "game_that_takes_arguments.exe" ${@:2}\n  ;;\nesac'\
      >> "${WPFXF}"
  fi
  case "${1}" in
  -r) # launch application
    if [ -z "${2}" ]; then
      echo $(sed -n 's/)#e/\t/p' ${WPFXF})
    else . ${WPFXF} ${2}
    fi # the dot causes the config file to be included and ran as a bash file, so the wine program is ran with the variables set in this bash file
  ;;
  -p) # run any application with the wine prefix set
    if [ -z "${2}" ]; then
      ls ${WPFXD}
    elif [[ "${2}" == "." ]]; then
       WINEPREFIX="$PWD" "${3}" "${4}" ${@:5}
    else
      . ${WPFXF} PFX ${2}
      if [ "${3}" != "winetricks" ]; then
        export WTX=''
      fi
      "${3}" ${WTX} ${@:4}
    fi
  ;;
  -u) # updates wine prefix
    if [ -z "${2}" ]; then
      echo $(sed -n 's/)#p/\t/p' ${WPFXF})
    elif [[ "${2}" == "-a" ]]; then
      IFS=$(printf \0) ; for dpx in ${WPFXDIR}* ; do WINEPREFIX="${dpx}" wineboot -u ; done ; IFS=
    elif [[ "${2}" == "." ]]; then
       WINEPREFIX="$PWD" wineboot -u
    else WINEPREFIX="${WPFXDIR}${2}" wineboot -u
    fi
  ;;
  *)
  printf \
"\0-r [APPNAME]               Run application, leave blank to list Wine app shortcuts."\
"\n-p [PFXNAME] [lx bin] ...  Run linux binary with wineprefix set. Useful for running winecfg/tricks."\
"\n-u [PFXNAME]               Update wineprefix, -u -a to update all prefixes."\
"\nif  PFXNAME  is set to . , Current directory is used as the wineprefix."\
"\n-v                         Setup multiple wine versions simultaneously."\
"\nExamples:"\
"\n  Wine.sh -p PfxName wine example.exe -argA 2 -argB 3"\
"\n  WINEARCH=win32 WVER=4.18 Wine.sh -p PfxName winetricks quartz"\
"\nthe above will install quartz, along with any libraries set in the prefix file\n"
  ;;
  esac
elif [ -z "${WVER}" ] || [ -z "${2}" ]; then
  printf "Use 'WVER=X.XX Wine.sh -v .../wine-${WVER}-X.pkg.tar.zst' to setup another version\n"
else
  if [ ! -d "/opt/wine-${WVER}/usr" ]; then
      sudo mkdir "/opt/wine-${WVER}"
      sudo tar -C "/opt/wine-${WVER}" -xvf "${2}" usr
  else
    printf "Running with existing Wine version at /opt/wine-${WVER}\n"
  fi
fi
