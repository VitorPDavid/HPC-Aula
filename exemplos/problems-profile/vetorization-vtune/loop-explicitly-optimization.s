	.file	"loop-explicitly-optimization.c"
	.text
	.p2align 4,,15
	.globl	add_explicitly_optimization_d
	.type	add_explicitly_optimization_d, @function
add_explicitly_optimization_d:
.LFB5168:
	.cfi_startproc
	testl	%ecx, %ecx
	je	.L8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L3:
	movl	%eax, %r8d
	addl	$4, %eax
	vmovapd	(%rsi,%r8,8), %ymm1
	vaddpd	(%rdx,%r8,8), %ymm1, %ymm0
	vmulpd	%ymm1, %ymm0, %ymm0
	vsqrtpd	%ymm0, %ymm0
	vmovapd	%ymm0, (%rdi,%r8,8)
	cmpl	%eax, %ecx
	ja	.L3
	vzeroupper
.L8:
	ret
	.cfi_endproc
.LFE5168:
	.size	add_explicitly_optimization_d, .-add_explicitly_optimization_d
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
