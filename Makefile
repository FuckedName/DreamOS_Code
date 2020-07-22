TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/haribote/

MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
CC1      = $(TOOLPATH)cc1.exe -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask.exe -a
OBJ2BIM  = $(TOOLPATH)obj2bim.exe
MAKEFONT = $(TOOLPATH)makefont.exe
BIN2OBJ  = $(TOOLPATH)bin2obj.exe
BIM2HRB  = $(TOOLPATH)bim2hrb.exe
RULEFILE = $(TOOLPATH)haribote/haribote.rul
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del

# 默认动作

default :
	$(MAKE) img

# 镜像文件生成

boot_1.bin : boot_1.nas Makefile
	$(NASK) boot_1.nas boot_1.bin boot_1.lst

jump_2.bin : jump_2.nas Makefile
	$(NASK) jump_2.nas jump_2.bin jump_2.lst

main_3.gas : main_3.c Makefile
	$(CC1) -o main_3.gas main_3.c

main_3.nas : main_3.gas Makefile
	$(GAS2NASK) main_3.gas main_3.nas

main_3.obj : main_3.nas Makefile
	$(NASK) main_3.nas main_3.obj main_3.lst

naskfunc.obj : naskfunc.nas Makefile
	$(NASK) naskfunc.nas naskfunc.obj naskfunc.lst

hzk16.obj : hzk16.bin Makefile
	$(BIN2OBJ) hzk16.bin hzk16.obj _hzk16
	
main_3.bim : main_3.obj naskfunc.obj hzk16.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:main_3.bim stack:6136k map:main_3.map \
		main_3.obj naskfunc.obj hzk16.obj
# 3MB+64KB=3136KB

main_3.hrb : main_3.bim Makefile
	$(BIM2HRB) main_3.bim main_3.hrb 0

haribote.sys : jump_2.bin main_3.hrb Makefile
	copy /B jump_2.bin+main_3.hrb haribote.sys

haribote.img : boot_1.bin haribote.sys Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:boot_1.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		imgout:haribote.img

# 其他指令

img :
	$(MAKE) haribote.img

run :
	$(MAKE) img
	$(COPY) haribote.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: haribote.img

clean :
	-$(DEL) boot_1.bin jump_2.bin
	-$(DEL) *.lst
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) main_3.nas
	-$(DEL) main_3.map
	-$(DEL) main_3.bim
	-$(DEL) main_3.hrb
	-$(DEL) haribote.sys
#	-$(DEL) haribote.img

src_only :
	$(MAKE) clean
	-$(DEL) haribote.img
