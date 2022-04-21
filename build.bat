del Tetris.obj
del Tetris.exe
del TetrisRc.res
ml_asm /c /coff Tetris.asm
rc TetrisRc.rc
link_asm /subsystem:windows Tetris.obj TetrisRc.res
pause