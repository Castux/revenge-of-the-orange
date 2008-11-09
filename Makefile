evolcore.so : evolcore.os
	gcc -o evolcore.so -shared evolcore.os -L/usr/lib -lSDL -lSDL_image -lSDL_ttf -lSDL_gfx -lSDL_mixer

evolcore.os : evolcore.c
	gcc -o evolcore.os -c -Wall -O2 -fPIC -D_GNU_SOURCE=1 -D_REENTRANT -I/usr/include/lua5.1 -I/usr/include/SDL evolcore.c
