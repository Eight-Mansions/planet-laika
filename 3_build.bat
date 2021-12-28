del cd\build.log
del cd\laika.bin
del exe\SLPM_862.64

copy exe\orig\SLPM_862.64 exe\SLPM_862.64
tools\armips.exe code\code.asm
tools\atlas exe\SLPM_862.64 trans\scripts\exe.txt >> error.txt
copy exe\SLPM_862.64 cd\laika\SLPM_862.64

del ins\S01\S01C01I4.IMG
copy graphics\S01C01I4.IMG ins\S01\S01C01I4.IMG

del ins\S01\S01C06I2.IMG
copy graphics\S01C06I2.IMG ins\S01\S01C06I2.IMG

tools\planet_laika_scene_compress.exe ins cd\laika *

tools\planet_laika_font_in.exe graphics\font.bmp cd\laika\SYS\LAIKA.FNZ

del cd\laika\STR\M000.STR
del cd\laika\STR\M064.STR
copy movies\M000.STR cd\laika\STR\M000.STR
copy movies\M064.STR cd\laika\STR\M064.STR

tools\psximager\psxbuild.exe -v cd\laika >> cd\build.log