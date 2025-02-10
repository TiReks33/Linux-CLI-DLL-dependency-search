# Linux-CLI-dll-dependency-search
## Description

This script automates search of dynamic shared objects (DLL's) of applications via ldd. Supports groups and recursive directories tree searching.

## Usage
***[single file/s]***:  
*script_path*/*script_name* binary_1 binary_2 ... binary_n  
***[directories]***:  
*script_path*/*scipt_name* path_1 path_2/  
***[directories(recursion)]***:  
*script_path*/*scipt_name* -r/--recursion path_1 path_2/  

## Example w/ output
1) single binary
```console
foo@bar:~$ /bin/bash ldd-search.sh /bin/adb-explorer/adb-explorer
Total binary files amount to check: 1.

[Begin check]:

[1.] /bin/adb-explorer/adb-explorer:
	OK
--------------------------------------------------
[End check]
```
2) directory (recursive)
```console
foo@bar:~$ /bin/bash ldd-search.sh --recursive /bin/adb-explorer/plugins/
_Recursive=true
'/bin/adb-explorer/plugins/' is a directory
'/bin/adb-explorer/plugins//iconengines' is a sub-directory
...
'/bin/adb-explorer/plugins//wayland-shell-integration' is a sub-directory
'/bin/adb-explorer/plugins//xcbglintegrations' is a sub-directory
Total binary files amount to check: 58.

[Begin check]:

[1.] /bin/adb-explorer/plugins//iconengines/KIconEnginePlugin.so:
	OK
--------------------------------------------------
[2.] /bin/adb-explorer/plugins//iconengines/libqsvgicon.so:
	OK
--------------------------------------------------
[3.] /bin/adb-explorer/plugins//imageformats/kimg_avif.so:
	OK
--------------------------------------------------
...
[56.] /bin/adb-explorer/plugins//wayland-shell-integration/libxdg-shell-v6.so:
	OK
--------------------------------------------------
[57.] /bin/adb-explorer/plugins//xcbglintegrations/libqxcb-egl-integration.so:
	libxcb-xinput.so.0 => not found
--------------------------------------------------
[58.] /bin/adb-explorer/plugins//xcbglintegrations/libqxcb-glx-integration.so:
	libxcb-xinput.so.0 => not found
--------------------------------------------------
[End check]
```
