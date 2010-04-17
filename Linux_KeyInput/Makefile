CROSS=arm-linux-
#INCLUDE :=-I/home/pioneer/work/linux-2.6.29
testOBJ=testKeyScan

ooo=keyInput
obj-m := $(ooo).o
#KDIR =/lib/modules/$(shell uname -r)/build 
KDIR=/home/pioneer/work/linux-2.6.29/

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules
	#cp $(ooo).ko /home/pioneer/work/temp/
	cp $(ooo).ko /home/pioneer/work/root_qtopia/lib/modules/2.6.29.4-FriendlyARM
	
test: 
	$(CROSS)gcc $(INCLUDE) -o $(testOBJ) testKeyScan.c
	cp $(testOBJ) /home/pioneer/work/root_qtopia/lib/modules/2.6.29.4-FriendlyARM

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	@rm -vf $(testOBJ) *.o *~

