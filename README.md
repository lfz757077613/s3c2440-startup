# s3c2440-startup
a startup file for s3c2440 compiled with armcc.
many people debug the s3c2440 with a wrong initial file,this file is contained in mdk,but it's not supported s3c2440 completely.
I also share the initial file fixed by myself.
with the initial file,anyone can debug the startup file in ram which is avoided to download to rom too many times.


s3c2440的启动文件，并且参照stm32写了中断向量表，提供了mdk中用来调试的ini文件，网上流传的都是s3c2410的调试文件，对有些地址线的配置不对。
