if not exist "obj/" mkdir obj
if not exist "rom/" mkdir rom

ASM68K.EXE /l /o l+ source/main.asm, obj/main.obj
ASM68K.EXE /l /o l+ source/util.asm, obj/util.obj
ASM68K.EXE obj/main.obj, obj/util.obj, rom/gengle.sym, rom/gengle.list
