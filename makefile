SHELL=/bin/bash
all:
	dasm dli.asm -odli.obj -ldli.lst 
	cat P1.TXT | perl foo.pl > P1.LST

edit1:
	tr "\233" "\n" < PM.TXT > P.TXT
save1:
	echo stripping comments
	grep -v '^#' P.TXT > /tmp/foo.txt
	tr "\n" "\233" < /tmp/foo.txt > PM.TXT


# use smartdos, it seems to work witht he H: drive properly
atari1: makeexe
	dasm ea.asm -f3 -oA.EXE -lea.lst
	./makeexe A.EXE
	cp A.EXE ~/atari_disk

makeexe : makeexe.c
	gcc $^ -o $@
