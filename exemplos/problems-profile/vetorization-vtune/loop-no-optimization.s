	.file	"loop-no-optimization.c"
	.text
	.p2align 4,,15
	.globl	add_no_optimization_d
	.type	add_no_optimization_d, @function
add_no_optimization_d:
.LFB6:
	.cfi_startproc
	testl	%ecx, %ecx
	je	.L1
	cmpl	$1, %ecx
	je	.L6
	movl	%ecx, %r8d
	xorl	%eax, %eax
	shrl	%r8d
	salq	$4, %r8
	.p2align 4,,10
	.p2align 3
.L4:
	movupd	(%rsi,%rax), %xmm2
	movupd	(%rdx,%rax), %xmm0
	addpd	%xmm2, %xmm0
	mulpd	%xmm2, %xmm0
	sqrtpd	%xmm0, %xmm0
	movups	%xmm0, (%rdi,%rax)
	addq	$16, %rax
	cmpq	%rax, %r8
	jne	.L4
	movl	%ecx, %eax
	andl	$-2, %eax
	cmpl	%eax, %ecx
	je	.L12
.L3:
	movsd	(%rsi,%rax,8), %xmm1
	movsd	(%rdx,%rax,8), %xmm0
	addsd	%xmm1, %xmm0
	mulsd	%xmm1, %xmm0
	sqrtsd	%xmm0, %xmm0
	movsd	%xmm0, (%rdi,%rax,8)
.L1:
	ret
	.p2align 4,,10
	.p2align 3
.L12:
	ret
.L6:
	xorl	%eax, %eax
	jmp	.L3
	.cfi_endproc
.LFE6:
	.size	add_no_optimization_d, .-add_no_optimization_d
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
