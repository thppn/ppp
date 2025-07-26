# ppp



For the purpose of Compilers II lesson in the CSE Dept @ University of Ioannina `ppp` was developed as an OOP language compiling to C code. In this repository the project is refactored from scratch according to the initial requirements.



### A simple ppp program looks like this 

```

class Fruit:
    int kg;;
    def __init__(self, int kg): Fruit
        self.kg = kg
    ;;

    def high(self, int kg): -
        self.kg = self.kg + kg
    ;;

    def low(self, int kg): -
        self.kg = self.kg - kg
    ;;


class Apple inherits Fruit:
    int type;;

    def __init__(self, int type): Apple
        self.type = type
    ;;

class Main:
    int x;
    Apple y;;

    def main(self): -
        $Apple(self.y, 4);
        self.x = 4 + 2 * 7 + 8 * (9 * 3 + 2) + 4 +8;
        print self.x
    ;;

```



## How to run

### Activate Python environment for ANTLR4 python runtime

`source venv/bin/activate`



### Download [ANTLR4](https://www.antlr.org/download.html) runtime jar and compile grammar

`java -jar antlr/antlr-4.13.2-complete.jar -Dlanguage=Python3 -o grammar ./ppp.g4`



### Compile ppp example program

`python main.py examples/fruits/fruits.ppp`



## Compile final file and execute

`gcc output.c \&\& ./a.out`

