import glob

env = Environment()

SOURCES = glob.glob('*.c')


env.Append(CCFLAGS = ['-Wall', '-O2'])

env.Append(CPPPATH = '/usr/include/lua5.1')

env.ParseConfig('sdl-config --cflags --libs')
env.Append(LIBS = ['SDL_image', 'SDL_ttf', 'SDL_gfx', 'SDL_mixer'])


env.SharedLibrary(target = 'evolcore', source = [SOURCES], SHLIBPREFIX='')
