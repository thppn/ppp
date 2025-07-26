# ppp



For the purpose of Compilers II lesson in the CSE Dept @ University of Ioannina `ppp` was developed as an OOP language compiling to C code. In this repository the project is refactored from scratch according to the initial requirements.



### A simple ppp program looks like this 

```
class Fibonacci:
    int x;;
    def __init__(self): Fibonacci;;

    def fib(self, int n): int
        if(n <= 1):
            return n;
        endif;
        return fib(n-1) + fib(n-2)
    ;;
class Main:
    int x, y ;
    Fibonacci f
    ;;

    def main(self): -
        $Fibonacci(self.f);
        input self.x;
        self.y = self.f.fib(self.x);
        print self.y
    ;;
```



## How to run


### Download [ANTLR4](https://www.antlr.org/download.html) jar and install python runtime

`pip install antlr4-python3-runtime`


### Compile grammar

`java -jar antlr/antlr-4.13.2-complete.jar -Dlanguage=Python3 -o grammar ./ppp.g4`


### Compile ppp example program

`python main.py examples/<program>/<program>.ppp`



## Compile final file and execute

`gcc output.c && ./a.out`

