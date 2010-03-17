import os
import serial
from struct import *
import time

WR_DF           =   0x01
WR_DF_RSP       =   0x02
RD_CHECK        =   0x03
RD_CHECK_RSP    =   0x04

if __name__ == "__main__":
    t_org = time.time()
    f = open('HZK16.dat', 'rb')
    ser = serial.Serial(port='COM1', baudrate=115200)
    f.seek(0, os.SEEK_END)
    fileSize = f.tell()
    
    f.seek(0, os.SEEK_SET)    
    #write data
    page = 0
    while f.tell() != fileSize:
        hexData = f.read(264)
        print 'write page %s...'%page,         
        ser.write(pack('B', WR_DF))#command
        ser.write(pack('H', len(hexData)+2))#dataLen
        ser.write(pack('H', page))#page
        ser.write(hexData)
        rspData = ser.read(3)
        rspCMD, = unpack('B', rspData[0:1])
        rspLen, = unpack('H', rspData[1:])
        
        if rspCMD == WR_DF_RSP and rspLen == 0:
            print 'OK!'
        else:
            print 'rspCMD:', rspCMD, 'rspLen:', rspLen,
            print 'False!'
        page += 1
    print "Write data OK!", 20*"="  
      
    f.seek(0, os.SEEK_SET)    
    #check
    ff = open("data.check", 'wb')
    page = 0
    while f.tell() != fileSize:
        print "check page %s..."%(page),
        hexData = f.read(264)
        ser.write(pack('B', RD_CHECK))
        ser.write(pack('H', 4))
        ser.write(pack('H', page))#which page
        ser.write(pack('H', len(hexData)))
        print "cmd send ok,",
        rspData = ser.read(1)
        rspCMD, = unpack('B', rspData)
        rspData = ser.read(2)
        rspLen, = unpack('H', rspData)
        rspData = ser.read(len(hexData))
        print "rsp ok," ,       
        if rspCMD == RD_CHECK_RSP and rspLen == len(hexData):
            ff.write(rspData)
            if cmp(hexData, rspData) == 0:
                print "Check OK!", 10*"="
            else:
                print "Check False!",10*"="
            page += 1
        else:
            print 'rspCMD:', rspCMD, 'rspLen:', rspLen, 'hexData len:', len(hexData)
            break
    ff.close()
    print "Check data Finish!", 20*"=" 
    
    print 'time:', time.time() - t_org, 's'
    print "ALL OK!"