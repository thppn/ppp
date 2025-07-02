import sys

from antlr4 import *
from pppLexer import pppLexer
from pppParser import pppParser
from ppp import ppp

def main(argv):
    input_stream = FileStream(argv[1])
    lexer = pppLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = pppParser(stream)
    tree = parser.startRule()

    pppListener = ppp(argv[2])
    #pppListener.cc = '/usr/bin/gcc'
    
    walker = ParseTreeWalker()
    walker.walk(pppListener, tree)


if __name__ == '__main__':
    main(sys.argv)

