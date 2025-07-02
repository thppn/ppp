#include<stdio.h>
#include <stdlib.h>

typedef struct Fibonacci_s {
int x;
} Fibonacci;
Fibonacci __init__$Fibonacci(Fibonacci *self){
self = (Fibonacci*) malloc(sizeof(Fibonacci));

}
int fib$Fibonacci(Fibonacci *self, int n){{
if(n<=1){
return 1;}
return fib$Fibonacci(self,n-1)+fib$Fibonacci(self,n-2);}
}
int x, y;
Fibonacci *f;
int main(){{
__init__$Fibonacci(f);
scanf("%d", &x);
y=fib$Fibonacci(f,x);
printf("%d\n", y);}
}