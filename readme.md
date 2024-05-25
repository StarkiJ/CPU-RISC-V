# CPU by RISC-V

While working on the project completely and independently has been a great help in understanding the course, using github to help yourself is also an option.  

This is the reward for learning to use github, I hope you can inherit the open source spirit, we all stand on the shoulders of giants.  

The computer is a free and boundless field.  

Good luck.

武汉大学2023年夏季小学期，弘毅班

## 单周期CPU实验代码

这个简单，依葫芦画瓢跟着做，选择低空飞过将止步于此

## 可冒险的流水线CPU实验代码

注意：由于是在前期单周期cpu项目的基础上完成，所以项目内文件名仍为“singlecyclecpu” ，但实际上为可冒险流水线CPU，即pipelinecpu  

为提升下板时动画速度，已在clk_div中改变频率，如下：

    //assign Clk_CPU=(SW2)? clkdiv[24] : clkdiv[3];
    assign Clk_CPU=(SW2)? clkdiv[16] : clkdiv[0];

流水线验收时间：2023.06.30 下午  

.coe文件在pipelinecpu\singlecyclecpu.srcs\sources_1\ip中，  
目前使用的是自己写的“插入排序”测试小程序：D_my_mem2.coe ， I_my_mem2.coe
它的汇编代码文件为：my_test2.asm  
(名字中有“2”是因为之前写过一版但放弃了，最终使用的是第二版)  

测试小程序验收时间：2023.07.03 上午  
