if not exist "obj/" mkdir obj
if not exist "rom/" mkdir rom

ASM68K.EXE source/main.asm , rom/gengle.bin, rom/gengle.sym, rom/gengle.list
romfix.exe rom/gengle.bin