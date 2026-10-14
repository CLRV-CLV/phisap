.section .text
.global blob
.global blob_end
.global orig_slot
.global back_slot
.global lit_flag
.global lit_open
.global lit_ext
.global lit_dlopen
.global lit_caller
.global lit_path

// 整段搬进游戏的可执行空隙。路径和一次性标记放在可写内存里。
// openat 打开应用自己的库文件，再用 android_dlopen_ext(库 fd) 绕过命名空间。
blob:
    ldr x16, lit_flag
    cbz x16, go
    ldrb w17, [x16]
    cbnz w17, do_orig
    mov w17, #1
    strb w17, [x16]
go:
    stp x0, x1, [sp, #-16]!
    stp x2, x8, [sp, #-16]!
    stp x19, x30, [sp, #-16]!
    sub sp, sp, #64

    ldr x16, lit_open
    cbz x16, done
    mov x0, #-100
    ldr x1, lit_path
    mov w2, #0
    blr x16
    tbnz x0, #63, done
    mov w19, w0

    ldr x16, lit_ext
    cbz x16, done
    mov x2, sp
    stp xzr, xzr, [x2]
    stp xzr, xzr, [x2, #16]
    stp xzr, xzr, [x2, #32]
    mov w1, #16
    str w1, [x2]
    str w19, [x2, #28]
    ldr x0, lit_path
    mov w1, #2
    blr x16
done:
    add sp, sp, #64
    ldp x19, x30, [sp], #16
    ldp x2, x8, [sp], #16
    ldp x0, x1, [sp], #16
do_orig:
orig_slot:
    nop
back_slot:
    b orig_slot

.align 3
lit_flag:
    .quad 0
lit_open:
    .quad 0
lit_ext:
    .quad 0
lit_dlopen:
    .quad 0
lit_caller:
    .quad 0
lit_path:
    .quad 0
blob_end:

// 当作普通函数调用。先送库，再跳到原来的函数。不改已经在执行的指令。
.global gblob
.global gblob_end
.global g_flag
.global g_open
.global g_ext
.global g_path
.global g_real
gblob:
    bti c
    ldr x16, g_flag
    cbz x16, g_call
    ldrb w17, [x16]
    cbnz w17, g_call
    mov w17, #1
    strb w17, [x16]
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    sub sp, sp, #64
    ldr x16, g_open
    cbz x16, g_restore
    mov x0, #-100
    ldr x1, g_path
    mov w2, #0
    blr x16
    tbnz x0, #63, g_restore
    mov w19, w0
    ldr x16, g_ext
    cbz x16, g_restore
    mov x2, sp
    stp xzr, xzr, [x2]
    stp xzr, xzr, [x2, #16]
    stp xzr, xzr, [x2, #32]
    mov w1, #16
    str w1, [x2]
    str w19, [x2, #28]
    ldr x0, g_path
    mov w1, #2
    blr x16
g_restore:
    add sp, sp, #64
    ldp x19, x20, [sp], #16
    ldp x8, x30, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16
g_call:
    ldr x16, g_real
    br x16
.align 3
g_flag:
    .quad 0
g_open:
    .quad 0
g_ext:
    .quad 0
g_path:
    .quad 0
g_real:
    .quad 0
gblob_end:
