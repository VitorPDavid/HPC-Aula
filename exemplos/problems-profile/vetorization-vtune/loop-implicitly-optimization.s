	.file	"loop-implicitly-optimization.c"
	.text
	.p2align 4,,15
	.globl	add_implicitly_optimization_d
	.type	add_implicitly_optimization_d, @function
add_implicitly_optimization_d:
.LFB6:
	.cfi_startproc
	testl	%ecx, %ecx
	je	.L9
	pushq	%r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	xorl	%r8d, %r8d
	pushq	%r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	pushq	%rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	.p2align 4,,10
	.p2align 3
.L3:
	movl	%r8d, %eax
	leal	1(%r8), %r13d
	leal	2(%r8), %r12d
	salq	$3, %rax
	leaq	(%rdi,%r13,8), %r11
	leaq	(%rdi,%r12,8), %r10
	leaq	(%rsi,%rax), %rbx
	leaq	(%rdx,%rax), %r14
	addq	%rdi, %rax
	movupd	16(%r14), %xmm0
	movupd	16(%rbx), %xmm2
	leal	3(%r8), %ebp
	addl	$4, %r8d
	movupd	(%r14), %xmm1
	movupd	(%rbx), %xmm3
	leaq	(%rdi,%rbp,8), %r9
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1
	movups	%xmm0, 16(%rax)
	movups	%xmm1, (%rax)
	movsd	(%rax), %xmm0
	mulsd	(%rbx), %xmm0
	movsd	%xmm0, (%rax)
	movsd	(%r11), %xmm0
	mulsd	(%rsi,%r13,8), %xmm0
	movsd	%xmm0, (%r11)
	movsd	(%r10), %xmm0
	mulsd	(%rsi,%r12,8), %xmm0
	movsd	%xmm0, (%r10)
	movsd	(%r9), %xmm0
	mulsd	(%rsi,%rbp,8), %xmm0
	movsd	%xmm0, (%r9)
	sqrtsd	(%rax), %xmm0
	movsd	%xmm0, (%rax)
	sqrtsd	(%r11), %xmm0
	movsd	%xmm0, (%r11)
	sqrtsd	(%r10), %xmm0
	movsd	%xmm0, (%r10)
	sqrtsd	(%r9), %xmm0
	movsd	%xmm0, (%r9)
	cmpl	%r8d, %ecx
	ja	.L3
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L9:
	.cfi_restore 3
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	ret
	.cfi_endproc
.LFE6:
	.size	add_implicitly_optimization_d, .-add_implicitly_optimization_d
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
