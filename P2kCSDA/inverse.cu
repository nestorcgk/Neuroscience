#include <stdio.h>
#include <cuda.h>
#include "magma.h"
#include "magma_lapack.h"
int main( int argc, char** argv ){
magma_init (); magma_timestr_t float gpu_time ,
//
initialize Magma
start , end;
magma_int_t magma_int_t magma_int_t m = 8192; magma_int_t mm=m*m; float *a;
float *d_a;
float *d_r;
float *d_c; magma_int_t ione = 1; magma_int_t ISEED [4] = magma_err_t err;
// changed // a-
*dwork ldwork;
// dwork - workspace // size of dwork of indices of inter- rows; a - mxm matrix // size of a, r, c mxm matrix on the host
;
*piv, info; // piv - array
{0 ,0 ,0 ,1}; alpha = 1.0;
beta = 0.0;
// //
start = get_current_time ();
magma sgetrf gpu( m, m, d a, m, piv, &info);
// d_a- // d_r- // d_c-
mxm matrix a on mxm matrix r on mxm matrix c on
the device the device the device
// seed
const float
const float
ldwork = m * magma_get_sgetri_nb(
// allocate matrices
err = magma_smalloc_cpu( &a , mm );
err = magma_smalloc( &d_a, mm );
err = magma_smalloc( &d_r, mm );
err = magma_smalloc( &d_c, mm );
err = magma_smalloc( &dwork, ldwork);// dev. mem. for ldwork piv=(magma_int_t*)malloc(m*sizeof(magma_int_t));// host mem.
// generate random matrix a // for piv lapackf77_slarnv(&ione,ISEED,&mm,a); // random a magma_ssetmatrix( m, m, a, m, d_a, m ); // copy a -> d_a magmablas_slacpy(’A’,m,m,d_a,m,d_r,m); // copy d_a -> d_r
// find the inverse matrix: a_d*X=I using the LU factorization // with partial pivoting and row interchanges computed by
// magma_sgetrf_gpu; row i is interchanged with row piv(i);
// d_a -mxm matrix; d_a is overwritten by the inverse
magma sgetri gpu(m,d a,m,piv,dwork,ldwork,&info);
gpu_time=GetTimerValue(start,end)/1e3; // Magma time magma_sgemm(’N’,’N’,m,m,m,alpha,d_a,m,d_r,m,beta,d_c,m); printf("magma_sgetrf_gpu + magma_sgetri_gpu time: %7.5f sec.\
alpha =1 beta =0 m); // workspace size
// host memory for a // device memory for a // device memory for r // device memory for c
       end = get_current_time ();
 magma_sgetmatrix( m, m, d_c, m, a, m ); printf("upper left corner of a^-1*a:\n"); magma_sprint( 4, 4, a, m );
free(a);
free(piv);
\n",gpu_time);
// part of a^-1*a // free host memory // free host memory
 
4.3 LU decomposition and solving general linear systems 144
 
magma_free(d_a); magma_free(d_r); magma_free(d_c); magma_finalize (); return 0;
}