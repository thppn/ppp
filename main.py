import sys
from antlr4 import *
from grammar.pppLexer import pppLexer
from grammar.pppParser import pppParser
from ppp import ppp

def main(argv):
    input_stream = FileStream(argv[1])
    lexer = pppLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = pppParser(stream)
    tree = parser.startRule()
    walker = ParseTreeWalker()
    walker.walk(ppp(), tree)

if __name__ == '__main__':
    main(sys.argv)

