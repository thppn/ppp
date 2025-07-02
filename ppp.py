from pppListener import pppListener
import os

class ppp(pppListener):
    
    def __init__(self, cFile):

        self.cFile = cFile

        self.cCompiler = None
        self.mallocBuffer = None

        self.argumentFlag = False
        
        self.exprBuffer = []
        self.condBuffer = []
        self.argumentBuffer = []
        self.cLines = ['#include<stdio.h>\n','#include <stdlib.h>\n']

    def __del__(self):
        f = open(self.cFile+'.c', "w+")
        f.writelines(self.cLines)
        f.close()

        if self.cCompiler:  os.system(self.cCompiler+' '+self.cFile+'.c -o '+self.cFile+'.out')
        print(self.cFile+" compilation completed!")

    def enterClass_def(self, ctx):
        self.className = str(ctx.className.getText())
        self.cLines.append("\n"+"typedef struct "+self.className+'_s '+"{")
        for upperClass in ctx.upperClasses: self.cLines.append("\n"+upperClass+"* $"+upperClass+";")
    
    def enterMethod_main_def(self, ctx):
        self.cLines.append("\n"+"int main()")

    def enterConstructor_def(self, ctx):
        constructorName = self.className+' '+ctx.pppConstructor.replace('@','$')
        self.cLines.append("\n"+constructorName)
        self.mallocBuffer = '\nself = ('+self.className+'*) malloc(sizeof('+self.className+'));\n'

    def enterParameters(self, ctx):
        self.cLines.append("(")
    def exitParameters(self, ctx):
        self.cLines.append(")")
        
    def enterParlist(self, ctx):
        self.cLines.append(self.className+' *self')
    def exitParlist(self, ctx):
        for param in range(0, len(ctx.parameterList)):
            if ctx.parlistType[param] == 'int':  #All except default
                self.cLines.append(', '+ctx.parlistType[param]+' '+ctx.parameterList[param])
            else:
                self.cLines.append(', '+ctx.parlistType[param]+' *'+ctx.parameterList[param])

    def enterDecl_line(self, ctx):
        if ctx.varType.getText() != 'int': #All except default
            newVarList = ['*'+var for var in ctx.varList]
        else:
            newVarList = ctx.varList
        self.cLines.append("\n"+ctx.varType.getText()+' '+', '.join(newVarList)+';')

    def enterClass_body(self, ctx):
        self.cLines.append("\n"+"} "+self.className+";")

    def enterMethod_def(self, ctx):
        methodName = ctx.return_type().getText().replace('-','void')+" "+ctx.pppMethod.replace('@','$')
        self.cLines.append("\n"+methodName)

    def enterInput_stat(self, ctx):
        self.cLines.append("\n"+'scanf("%d", &'+'->'.join(ctx.idList))
    def exitInput_stat(self, ctx):
        self.cLines.append(');')

    def enterPrint_stat(self, ctx):
        self.cLines.append("\n"+'printf("%d\\n", ')
    def exitPrint_stat(self, ctx):
        self.cLines.append(');')

    def enterReturn_stat(self, ctx):
        self.cLines.append("\n"+'return ')
    def exitReturn_stat(self, ctx):
        self.cLines.append(';')

    def enterAssignment_stat(self, ctx):
        if ctx.idList is None: #contructor
            constructorName, argumentTypeList, argumentList = ctx.exprList
            self.cLines.append("\n"+"__init__$"+constructorName+'(')
            if len(argumentTypeList) == 0 or not(argumentTypeList[0] == constructorName):
                self.cLines.append('self->$'+constructorName)
            else:
                self.argumentFlag = True
            for argument in argumentList:
                if type(argument) is list:
                    self.argumentBuffer.append(argument)
        else:
            self.cLines.append("\n"+'->'.join(ctx.idList) + '=')

    def exitAssignment_stat(self, ctx):
        if ctx.idList is None:
            self.cLines.append(')')
        self.cLines.append(';')
    
    def enterFactor(self, ctx):
        if ctx.case == 1:#value
            self.exprBuffer.append(ctx.factorString)
        elif ctx.case == 2:
            self.exprBuffer.append('(')
        elif ctx.case == 3:#id
            classPath = '->'.join(ctx.factorArgument)
            for argument in self.argumentBuffer:
                if classPath == argument[0]:
                    classPath += '->$'+'->$'.join(argument[1:])
                    self.argumentBuffer.remove(argument)
                    break
            self.exprBuffer.append(classPath)
        else:#function 4 or 5
            classPath = '->'.join(ctx.factorArgument[0])
            argumentList = ctx.factorArgument[1:]
            for argument in argumentList:
                if type(argument) is list:
                    self.argumentBuffer.append(argument)
            self.exprBuffer.append(ctx.factorString+'('+classPath)
            
    def exitFactor(self, ctx):
        if ctx.case == 2 or ctx.case > 3: #case 2, 4, 5
            self.exprBuffer.append(')')
            
    def enterDirect_call_stat(self, ctx):
        classPath = '->'.join(ctx.functionClassPath[0])
        argumentList = ctx.functionClassPath[1:]
        for argument in argumentList:
            if type(argument) is list:
                self.argumentBuffer.append(argument)
        self.cLines.append("\n"+ctx.functionName+'('+classPath)
        
    def exitDirect_call_stat(self, ctx):
        self.cLines.append(');')

    def enterIf_stat(self, ctx):
        self.cLines.append("\n"+'if')

    def enterElse_part(self, ctx):
        if ctx.elseFlag:
            self.cLines.append("\n"+'else')

    def enterWhile_stat(self, ctx):
        self.cLines.append("\n"+'while') 

    def enterMul_oper(self, ctx):
        self.exprBuffer.append(ctx.getText())

    def enterAdd_oper(self, ctx):
        self.exprBuffer.append(ctx.getText())

    def exitExpression(self, ctx):
        self.cLines.append(''.join(self.exprBuffer))
        self.exprBuffer = []

    def enterMethod_body(self, ctx):
        self.cLines.append('{')
        if self.mallocBuffer:
            self.cLines.append(self.mallocBuffer)
            self.mallocBuffer = ''

    def exitMethod_body(self, ctx):
        self.cLines.append('\n}')

    def enterStatements(self, ctx):
        self.cLines.append('{')

    def exitStatements(self, ctx):
        self.cLines.append('}')

    def enterCondition(self, ctx):
        self.cLines.append('(')
        for conditionOr in range(ctx.orCount):
            self.condBuffer.append('||')

    def exitCondition(self, ctx):
        if not self.condBuffer:
            self.cLines.append(')')
        
    def enterRel_oper(self, ctx):
        self.cLines.append(ctx.getText())
    
    def enterArgitem(self, ctx):
        if not self.argumentFlag:
            self.exprBuffer.append(',')
        self.argumentFlag=False

    def enterBoolterm(self, ctx):
        for conditionAnd in range(ctx.andCount):
            self.condBuffer.append('&&')
    
    def enterBoolfactor(self, ctx):
        if(ctx.boolfactorCase == 1):
            self.cLines.append('!')
        if(ctx.boolfactorCase != 3):
            self.condBuffer.append(')')
            
    def exitBoolfactor(self, ctx):
        if self.condBuffer:
            self.cLines.append(self.condBuffer.pop())

