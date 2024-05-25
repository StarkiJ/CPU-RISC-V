#插入排序
main:
    addi    x5, x0, 0
loop1:  #从前往后一个个插入
    sw      x5, 56(x0)
    lw      x7, 4(x5)
    beq     x7, x0, end
loop2:  #从后往前找到合适的位置
    lw      x6, 0(x5)
    bge     x7, x6, next
    sw      x6, 4(x5)
    addi    x5, x5, -4
    bge     x5, x0, loop2

next:
    sw      x7, 4(x5)
    lw      x5, 56(x0)
    addi    x5, x5, 4
    jal     x0, loop1
    
end:
    lw      x10, 0(x0)
    lw      x11, 4(x0)
    lw      x12, 8(x0)
    lw      x13, 12(x0)
    lw      x14, 16(x0)
    lw      x15, 20(x0)
    lw      x16, 24(x0)
    lw      x17, 28(x0)
    jal     x0,  end