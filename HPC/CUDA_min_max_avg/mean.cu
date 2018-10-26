#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda.h>

// CUDA kernel. Each thread takes care of one element of c
__global__ void vecAdd(double *a, double *b, double *c, int n)
{
    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;			// get global index

    // Make sure we do not go out of bounds
    if (id < n)
        c[id] = a[id] + b[id];
}

int main( )
{

    //int n = 100000;
	int n=5;			// Size of vectors


    double *h_a;		// Host input vector
    double *h_b;		// Host input vector


    double *h_c;		//Host output vector


    double *d_a;		// Device input vector
    double *d_b;		// Device input vector

    double *d_c;		 //Device output vector


    size_t bytes = n*sizeof(double);		 // Size, in bytes, of each vector

    // Allocate memory for each vector on host
    h_a = (double*)malloc(bytes);
    h_b = (double*)malloc(bytes);
    h_c = (double*)malloc(bytes);

    // Allocate memory for each vector on GPU
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    int i;

    // Initialize vectors on host
    for( i = 0; i < n; i++ ) {

	h_a[i]=i;
	h_b[i]=i;

    }

    // Copy host vectors to device
    cudaMemcpy( d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy( d_b, h_b, bytes, cudaMemcpyHostToDevice);

    int blockSize, gridSize;

    // Number of threads in each thread block
    blockSize = 1024;

    // Number of thread blocks in grid
    gridSize = (int)ceil((float)n/blockSize);

    // Execute the kernel
    vecAdd<<<gridSize, blockSize>>>(d_a, d_b, d_c, n);

    // Copy array back to host
    cudaMemcpy(h_c,d_c, bytes, cudaMemcpyDeviceToHost );

    // Sum up vector c and print result divided by n, this should equal 1 within error
    double sum = 0;
//    for(i=0;i<n;i++)
//    	printf("%f ",h_c[i]);
    for(i=0; i<n; i++){
        sum += h_c[i];
    }
    printf("Average mean of 2 vectors: %f\n", sum/n);

    // Release device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Release host memory
    free(h_a);
    free(h_b);
    free(h_c);

    return 0;
}
