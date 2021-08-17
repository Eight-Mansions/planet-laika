del cd\build.log
del cd\laika.bin
del exe\SLPM_862.64

copy exe\orig\SLPM_862.64 exe\SLPM_862.64
tools\armips.exe code\code.asm
copy exe\SLPM_862.64 cd\laika\SLPM_862.64

tools\planet_laika_scene_compress.exe ins cd\laika *.BIN

tools\planet_laika_font_in.exe graphics\font.bmp cd\laika\SYS\LAIKA.FNZ

del cd\laika\STR\M000.STR
del cd\laika\STR\M064.STR
copy movies\M000.STR cd\laika\STR\M000.STR
copy movies\M064.STR cd\laika\STR\M064.STR

tools\psximager\psxbuild.exe -v cd\laika >> cd\build.log