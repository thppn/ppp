\# ppp



For the purpose of Compilers II lesson in the Computer Science and Engineering Department at University of Ioannina ppp was developed as an OOP language compiling to C code. In this repository the compiler is refactored from scratch according to the initial requirements.



\## How to run

\#Activate Python environment for ANTLR4 python runtime

`source venv/bin/activate`



\## Download \[ANTLR4](https://www.antlr.org/download.html) runtime jar and compile grammar

`java -jar antlr/antlr-4.13.2-complete.jar -Dlanguage=Python3 -o grammar ./ppp.g4`



\## Compile ppp example program

`python main.py examples/fruits/fruits.ppp`



\## Compile final file and execute

`gcc output.c \&\& ./a.out`

