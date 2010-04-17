#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <linux/input.h>

#define DEVICE "/dev/input/event2"

static struct input_event buff; 

main()
{
   int fd;
   char num;
    
   fd = open(DEVICE, O_RDWR);

   if (fd == -1){
        printf("open key device error!\n");
        return 0;
    }

    while(1){
            while(read(fd,&buff,sizeof(struct input_event))==0); 
            printf("type:%d\t code:0x%x\t value:0x%x\n",buff.type,buff.code,buff.value); 
            //read(fd, &num, sizeof(num));
            //printf("key===========0x%x\n",num);
    }

   close(fd);
   return 0;
}

