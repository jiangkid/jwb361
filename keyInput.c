
 #include <linux/input.h>
#include <linux/module.h>
#include <linux/device.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
//#include <asm/hardware.h>
#include <mach/hardware.h>
#include <asm/delay.h>
#include <linux/delay.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include <linux/wait.h>
#include <linux/cdev.h>
//#include <asm-arm/irq.h>
#include <linux/irq.h>
#include <linux/interrupt.h>
//#include <asm-arm/arch-s3c2410/irqs.h>
#include <mach/irqs.h>
//#include <asm-arm/arch-s3c2410/regs-gpio.h>
#include <mach/regs-gpio.h>


#define     DEVICE_NAME "4*4key"    //Éè±¸Ãû³Æ
#define KEYDOWN 1
#define KEYUP 0
#define KEYNONE 2

static struct input_dev *button_dev;

static unsigned char keyvalue[16][16]={
{0, 1, 2, 3},
{4, 5, 6, 7},
{8, 9, 10, 11},
{12, 13, 14, 15},  
};

static unsigned int keycode[16] = {
    KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9,
    KEY_DOT, KEY_A, KEY_B, KEY_C, KEY_D, KEY_BACKSPACE
};

struct key_irq_desc {
    int irq;
    int pin;
    int pin_init_setting;
    int pin_scan_setting;
};

//interupt port
#define COLUMN0 S3C2410_GPG10 //EINT18
#define COLUMN1 S3C2410_GPG9 //EINT17
#define COLUMN2 S3C2410_GPG0 //EINT8
#define COLUMN3 S3C2410_GPF6 //EINT6

static struct key_irq_desc key_irqs [] = {
    {IRQ_EINT18, COLUMN0, S3C2410_GPG10_EINT18, S3C2410_GPG10_INP},
    {IRQ_EINT17, COLUMN1, S3C2410_GPG9_EINT17, S3C2410_GPG9_INP},
    {IRQ_EINT8, COLUMN2, S3C2410_GPG0_EINT8, S3C2410_GPG0_INP},
    {IRQ_EINT6, COLUMN3, S3C2410_GPF6_EINT6, S3C2410_GPF6_INP},
};

struct key_scan_desc{
    int pin;
    int pin_init_setting;
};

//scan port ROW
#define ROW0 S3C2410_GPF3 //EINT3
#define ROW1 S3C2410_GPF2 //EINT2
#define ROW2 S3C2410_GPF1 //EINT1
#define ROW3 S3C2410_GPF0 //EINT0

static struct key_scan_desc key_scans[] = {
    {ROW0, S3C2410_GPF3_OUTP},
    {ROW1, S3C2410_GPF2_OUTP},
    {ROW2, S3C2410_GPF1_OUTP},
    {ROW3, S3C2410_GPF0_OUTP},
};

static void free_irqs(void)
{
    int i;
    for (i=0; i < sizeof(key_irqs)/sizeof(key_irqs[0]); i++) {
        free_irq(key_irqs[i].irq, (void *)&key_irqs[i]);
        }
}

static void disable_irqs(void)
{
    int i;
    for (i=0; i < sizeof(key_irqs)/sizeof(key_irqs[0]); i++) {
        disable_irq(key_irqs[i].irq);
        }
}

static void enable_irqs(void)
{
    int i;
    for (i=0; i < sizeof(key_irqs)/sizeof(key_irqs[0]); i++) {
        enable_irq(key_irqs[i].irq);
        }
}

static void init_gpio(void)
{
    int i = 0;
    for(i=0; i<sizeof(key_scans)/sizeof(key_scans[0]); i++){
        s3c2410_gpio_cfgpin(key_scans[i].pin, key_scans[i].pin_init_setting);
        s3c2410_gpio_setpin(key_scans[i].pin, 0);
        }
    for (i=0; i < sizeof(key_irqs)/sizeof(key_irqs[0]); i++) {
        s3c2410_gpio_cfgpin(key_irqs[i].pin, key_irqs[i].pin_init_setting);
        }

}

static void init_gpio_scan(void)
{
    int i;
    for (i=0; i < sizeof(key_irqs)/sizeof(key_irqs[0]); i++) {
        s3c2410_gpio_cfgpin(key_irqs[i].pin, key_irqs[i].pin_scan_setting);
        }
}

unsigned char GetColumnbyIrq(int irq)
{
    unsigned char column;
    for (column=0; column < sizeof(key_irqs)/sizeof(key_irqs[0]); column++) {
        if(key_irqs[column].irq == irq)
            return column;
        }
    return 0xff;
}

static __inline unsigned char key_scan(unsigned char column)
{
        unsigned char row=0xff;
        //printk("column: %d\t", column);
        if(column == 0xff) return 0xff;
        s3c2410_gpio_setpin(ROW0, 0);
        s3c2410_gpio_setpin(ROW1, 1);
        s3c2410_gpio_setpin(ROW2, 1);
        s3c2410_gpio_setpin(ROW3, 1);
        if(!s3c2410_gpio_getpin(key_irqs[column].pin)) {
            row = 0;
            goto  done;
            }
        s3c2410_gpio_setpin(ROW0, 1);
        s3c2410_gpio_setpin(ROW1, 0);
        s3c2410_gpio_setpin(ROW2, 1);
        s3c2410_gpio_setpin(ROW3, 1);
        if(!s3c2410_gpio_getpin(key_irqs[column].pin)) {
            row = 1;
            goto  done;
            }
        s3c2410_gpio_setpin(ROW0, 1);
        s3c2410_gpio_setpin(ROW1, 1);
        s3c2410_gpio_setpin(ROW2, 0);
        s3c2410_gpio_setpin(ROW3, 1);
        if(!s3c2410_gpio_getpin(key_irqs[column].pin)) 
        {
            row = 2;
            goto  done;
        }
        s3c2410_gpio_setpin(ROW0, 1);
        s3c2410_gpio_setpin(ROW1, 1);
        s3c2410_gpio_setpin(ROW2, 1);
        s3c2410_gpio_setpin(ROW3, 0);
        if(!s3c2410_gpio_getpin(key_irqs[column].pin)) 
        {
            row = 3;
            goto  done;
        }
        done:        
        //printk("row: %d\n", row);
        if(row!=0xff && column!=0xff)
            return keyvalue[row][column];
        else
            return 0xff;
 }
struct KeyReportCode{
    unsigned int keyCode;
    char state;
};

static struct KeyReportCode reportCode = {0xff, KEYNONE};

static irqreturn_t key_isr(int irq, void *dev_id)//,struct pt_regs *regs)
{
    unsigned char keyValue;
    printk("key_isr, irq: %d\n", irq);
    disable_irqs();
    init_gpio_scan();
    mdelay(10); //ms
    keyValue = key_scan(GetColumnbyIrq(irq));
    printk("keyValue=====:%d\n", keyValue);
    printk("keycode==========:0x%x\t keyState:%d\n", reportCode.keyCode, reportCode.state);
    if(keyValue!=0xff && reportCode.state == KEYNONE) {
        reportCode.state = KEYDOWN;
        reportCode.keyCode = keycode[keyValue];
        printk("key down, keycode==========:0x%x\t keyState:%d\n", reportCode.keyCode, reportCode.state);
        input_report_key(button_dev, reportCode.keyCode, reportCode.state);
        input_sync(button_dev);
        }
    else if(keyValue == 0xff && reportCode.state == KEYDOWN){
        reportCode.state = KEYUP;
        printk("key up, keycode==========:0x%x\t keyState:%d\n", reportCode.keyCode, reportCode.state);
        input_report_key(button_dev, reportCode.keyCode, reportCode.state);
        input_sync(button_dev);
        reportCode.state = KEYNONE;
        }
    init_gpio();
    enable_irqs();
    return IRQ_RETVAL(IRQ_HANDLED);
}

static int request_irqs(void)
{
    int i;
    int err = 0;
    for (i = 0; i < sizeof(key_irqs)/sizeof(key_irqs[0]); i++) {
    	if (key_irqs[i].irq < 0) {
    		continue;
    	}
            err = request_irq(key_irqs[i].irq, key_isr, IRQ_TYPE_EDGE_BOTH, 
                              DEVICE_NAME, (void *)&key_irqs[i]);
            if (err)
                break;
        }

    if (err) {
        i--;
        for (; i >= 0; i--) {
	    if (key_irqs[i].irq < 0) {
		continue;
	    }
	    disable_irq(key_irqs[i].irq);
            free_irq(key_irqs[i].irq, (void *)&key_irqs[i]);
        }
        return -EBUSY;
    }
    return 0;
}

static int __init scankeyinput_init(void)
{
        int i;        
        int error = 0;
        request_irqs();
        /*
	if (request_irq(button_irqs[KEY].irq, button_interrupt, IRQ_TYPE_EDGE_BOTH, "button", (void *)&button_irqs[KEY])) {
                printk(KERN_ERR "button.c: Can't allocate irq %d\n", button_irqs[KEY].irq);
                return -EBUSY;
        }*/

	button_dev = input_allocate_device();
	if (!button_dev) {
		printk(KERN_ERR "button.c: Not enough memory\n");
		error = -ENOMEM;
		goto err_free_irq;
	}
        button_dev->name = "key";
        //button_dev->phys = "key/input0";
	button_dev->evbit[0] = BIT_MASK(EV_KEY);
        
         for (i = 0; i < sizeof(keycode)/sizeof(keycode[0]); i++) {
            set_bit(keycode[i], button_dev->keybit);
            //button_dev->keybit[BIT_WORD(KEY_5)] = BIT_MASK(KEY_5);
            }
	error = input_register_device(button_dev);
	if (error) {
		printk(KERN_ERR "button.c: Failed to register device\n");
		goto err_free_dev;
	}

	return 0;

 err_free_dev:
	input_free_device(button_dev);
 err_free_irq:
	free_irqs();
	return error;
}
static void __exit scankeyinput_exit(void)
{
	free_irqs();
        input_unregister_device(button_dev);
}
module_init(scankeyinput_init);
module_exit(scankeyinput_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("jwb");
MODULE_LICENSE("Dual BSD/GPL");
MODULE_DESCRIPTION ("The button input device driver");


