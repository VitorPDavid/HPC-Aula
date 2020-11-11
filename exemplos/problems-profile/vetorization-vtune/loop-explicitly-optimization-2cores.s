	.file	"loop-explicitly-optimization-2cores.c"
	.text
	.p2align 4,,15
	.type	add_explicitly_optimization_2_cores_d._omp_fn.0, @function
add_explicitly_optimization_2_cores_d._omp_fn.0:
.LFB5171:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	.cfi_offset 13, -24
	.cfi_offset 12, -32
	.cfi_offset 3, -40
	movl	120(%rdi), %r13d
	andq	$-32, %rsp
	testl	%r13d, %r13d
	je	.L8
	movq	%rdi, %rbx
	call	omp_get_num_threads@PLT
	movl	%eax, %r12d
	call	omp_get_thread_num@PLT
	xorl	%edx, %edx
	movl	%eax, %edi
	leal	3(%r13), %eax
	shrl	$2, %eax
	divl	%r12d
	cmpl	%edx, %edi
	jb	.L3
.L6:
	movl	%eax, %ecx
	imull	%edi, %ecx
	addl	%ecx, %edx
	addl	%edx, %eax
	cmpl	%eax, %edx
	jnb	.L8
	imull	%r13d, %edi
	movq	112(%rbx), %r10
	movq	104(%rbx), %r9
	leal	0(,%rax,4), %esi
	movq	96(%rbx), %r8
	leal	0(,%rdx,4), %ecx
	movslq	%edi, %rax
	.p2align 4,,10
	.p2align 3
.L5:
	movl	%ecx, %edx
	addl	$4, %ecx
	addq	%rax, %rdx
	vmovapd	(%r9,%rdx,8), %ymm1
	vmovapd	(%r10,%rdx,8), %ymm2
	vaddpd	%ymm2, %ymm1, %ymm0
	vmulpd	%ymm1, %ymm0, %ymm0
	vsqrtpd	%ymm0, %ymm0
	vmovapd	%ymm0, (%r8,%rdx,8)
	cmpl	%ecx, %esi
	ja	.L5
	vmovapd	%ymm1, (%rbx)
	vmovapd	%ymm2, 32(%rbx)
	vmovapd	%ymm0, 64(%rbx)
	vzeroupper
.L8:
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
	.p2align 4,,10
	.p2align 3
.L3:
	.cfi_restore_state
	addl	$1, %eax
	xorl	%edx, %edx
	jmp	.L6
	.cfi_endproc
.LFE5171:
	.size	add_explicitly_optimization_2_cores_d._omp_fn.0, .-add_explicitly_optimization_2_cores_d._omp_fn.0
	.p2align 4,,15
	.type	add_explicitly_optimization_4_cores_d._omp_fn.1, @function
add_explicitly_optimization_4_cores_d._omp_fn.1:
.LFB5172:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	.cfi_offset 13, -24
	.cfi_offset 12, -32
	.cfi_offset 3, -40
	movl	120(%rdi), %r13d
	andq	$-32, %rsp
	testl	%r13d, %r13d
	je	.L18
	movq	%rdi, %rbx
	call	omp_get_num_threads@PLT
	movl	%eax, %r12d
	call	omp_get_thread_num@PLT
	xorl	%edx, %edx
	movl	%eax, %edi
	leal	3(%r13), %eax
	shrl	$2, %eax
	divl	%r12d
	cmpl	%edx, %edi
	jb	.L13
.L16:
	movl	%eax, %ecx
	imull	%edi, %ecx
	addl	%ecx, %edx
	addl	%edx, %eax
	cmpl	%eax, %edx
	jnb	.L18
	imull	%r13d, %edi
	movq	112(%rbx), %r10
	movq	104(%rbx), %r9
	leal	0(,%rax,4), %esi
	movq	96(%rbx), %r8
	leal	0(,%rdx,4), %ecx
	movslq	%edi, %rax
	.p2align 4,,10
	.p2align 3
.L15:
	movl	%ecx, %edx
	addl	$4, %ecx
	addq	%rax, %rdx
	vmovapd	(%r9,%rdx,8), %ymm1
	vmovapd	(%r10,%rdx,8), %ymm2
	vaddpd	%ymm2, %ymm1, %ymm0
	vmulpd	%ymm1, %ymm0, %ymm0
	vsqrtpd	%ymm0, %ymm0
	vmovapd	%ymm0, (%r8,%rdx,8)
	cmpl	%ecx, %esi
	ja	.L15
	vmovapd	%ymm1, (%rbx)
	vmovapd	%ymm2, 32(%rbx)
	vmovapd	%ymm0, 64(%rbx)
	vzeroupper
.L18:
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
	.p2align 4,,10
	.p2align 3
.L13:
	.cfi_restore_state
	addl	$1, %eax
	xorl	%edx, %edx
	jmp	.L16
	.cfi_endproc
.LFE5172:
	.size	add_explicitly_optimization_4_cores_d._omp_fn.1, .-add_explicitly_optimization_4_cores_d._omp_fn.1
	.p2align 4,,15
	.type	add_explicitly_optimization_8_cores_d._omp_fn.2, @function
add_explicitly_optimization_8_cores_d._omp_fn.2:
.LFB5173:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	.cfi_offset 13, -24
	.cfi_offset 12, -32
	.cfi_offset 3, -40
	movl	120(%rdi), %r13d
	andq	$-32, %rsp
	testl	%r13d, %r13d
	je	.L27
	movq	%rdi, %rbx
	call	omp_get_num_threads@PLT
	movl	%eax, %r12d
	call	omp_get_thread_num@PLT
	xorl	%edx, %edx
	movl	%eax, %edi
	leal	3(%r13), %eax
	shrl	$2, %eax
	divl	%r12d
	cmpl	%edx, %edi
	jb	.L22
.L25:
	movl	%eax, %ecx
	imull	%edi, %ecx
	addl	%ecx, %edx
	addl	%edx, %eax
	cmpl	%eax, %edx
	jnb	.L27
	imull	%r13d, %edi
	movq	112(%rbx), %r10
	movq	104(%rbx), %r9
	leal	0(,%rax,4), %esi
	movq	96(%rbx), %r8
	leal	0(,%rdx,4), %ecx
	movslq	%edi, %rax
	.p2align 4,,10
	.p2align 3
.L24:
	movl	%ecx, %edx
	addl	$4, %ecx
	addq	%rax, %rdx
	vmovapd	(%r9,%rdx,8), %ymm1
	vmovapd	(%r10,%rdx,8), %ymm2
	vaddpd	%ymm2, %ymm1, %ymm0
	vmulpd	%ymm1, %ymm0, %ymm0
	vsqrtpd	%ymm0, %ymm0
	vmovapd	%ymm0, (%r8,%rdx,8)
	cmpl	%ecx, %esi
	ja	.L24
	vmovapd	%ymm1, (%rbx)
	vmovapd	%ymm2, 32(%rbx)
	vmovapd	%ymm0, 64(%rbx)
	vzeroupper
.L27:
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
	.p2align 4,,10
	.p2align 3
.L22:
	.cfi_restore_state
	addl	$1, %eax
	xorl	%edx, %edx
	jmp	.L25
	.cfi_endproc
.LFE5173:
	.size	add_explicitly_optimization_8_cores_d._omp_fn.2, .-add_explicitly_optimization_8_cores_d._omp_fn.2
	.p2align 4,,15
	.globl	add_explicitly_optimization_2_cores_d
	.type	add_explicitly_optimization_2_cores_d, @function
add_explicitly_optimization_2_cores_d:
.LFB5168:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	shrl	%ecx
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	andq	$-32, %rsp
	subq	$160, %rsp
	movq	%rdi, 24(%rsp)
	vmovq	24(%rsp), %xmm1
	leaq	add_explicitly_optimization_2_cores_d._omp_fn.0(%rip), %rdi
	movl	%ecx, 152(%rsp)
	xorl	%ecx, %ecx
	vpinsrq	$1, %rsi, %xmm1, %xmm0
	movq	%rdx, 144(%rsp)
	leaq	32(%rsp), %rsi
	movl	$2, %edx
	vmovaps	%xmm0, 128(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 32(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 64(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 96(%rsp)
	vzeroupper
	call	GOMP_parallel@PLT
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5168:
	.size	add_explicitly_optimization_2_cores_d, .-add_explicitly_optimization_2_cores_d
	.p2align 4,,15
	.globl	add_explicitly_optimization_4_cores_d
	.type	add_explicitly_optimization_4_cores_d, @function
add_explicitly_optimization_4_cores_d:
.LFB5169:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	shrl	$2, %ecx
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	andq	$-32, %rsp
	subq	$160, %rsp
	movq	%rdi, 24(%rsp)
	vmovq	24(%rsp), %xmm1
	leaq	add_explicitly_optimization_4_cores_d._omp_fn.1(%rip), %rdi
	movl	%ecx, 152(%rsp)
	xorl	%ecx, %ecx
	vpinsrq	$1, %rsi, %xmm1, %xmm0
	movq	%rdx, 144(%rsp)
	leaq	32(%rsp), %rsi
	movl	$4, %edx
	vmovaps	%xmm0, 128(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 32(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 64(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 96(%rsp)
	vzeroupper
	call	GOMP_parallel@PLT
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5169:
	.size	add_explicitly_optimization_4_cores_d, .-add_explicitly_optimization_4_cores_d
	.p2align 4,,15
	.globl	add_explicitly_optimization_8_cores_d
	.type	add_explicitly_optimization_8_cores_d, @function
add_explicitly_optimization_8_cores_d:
.LFB5170:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	shrl	$3, %ecx
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	andq	$-32, %rsp
	subq	$160, %rsp
	movq	%rdi, 24(%rsp)
	vmovq	24(%rsp), %xmm1
	leaq	add_explicitly_optimization_8_cores_d._omp_fn.2(%rip), %rdi
	movl	%ecx, 152(%rsp)
	xorl	%ecx, %ecx
	vpinsrq	$1, %rsi, %xmm1, %xmm0
	movq	%rdx, 144(%rsp)
	leaq	32(%rsp), %rsi
	movl	$8, %edx
	vmovaps	%xmm0, 128(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 32(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 64(%rsp)
	vxorpd	%xmm0, %xmm0, %xmm0
	vmovapd	%ymm0, 96(%rsp)
	vzeroupper
	call	GOMP_parallel@PLT
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5170:
	.size	add_explicitly_optimization_8_cores_d, .-add_explicitly_optimization_8_cores_d
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
