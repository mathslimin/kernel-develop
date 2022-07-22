
ifneq ($(KERNELRELEASE),)

MODULE_NAME := test_module
$(MODULE_NAME)-objs := hello.o
obj-m += $(MODULE_NAME).o

else

#KVER := $(shell uname -r)
#KDIR := /lib/modules/$(KVER)/build
 
all:
#	$(MAKE) -C $(KDIR) M=$(CURDIR) modules
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) modules
clean:
	@rm -rf .tmp_* .*o.cmd *.o *.ko *.mod.c *.order *.symvers *.mod .*.cmd
endif
