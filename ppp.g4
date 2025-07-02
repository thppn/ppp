grammar ppp;

@parser::members {

table = {}
inherit = {}
stack = []

def addScope(self, scope):
 self.stack.append(scope)
 if scope not in self.table.keys():
  self.table[scope] = {}

def findScope(self, entityName, scopePath:list):
 currentScope = scopePath[-1]
 if entityName in self.table[currentScope].keys():
  return scopePath, self.table[currentScope][entityName]
 for upperScope in self.inherit[currentScope]:
  entity = self.findScope(entityName, scopePath+[upperScope])
  if entity is not None: return entity

def searchInherit(self, parameterClass , argumentClassList):
 if parameterClass in argumentClassList:
   return [parameterClass]
 for argumentClass in argumentClassList:
   upperClassList = self.inherit[argumentClass]
   for upperClass in upperClassList:
     return [upperClass] + self.searchInherit(parameterClass, self.inherit[upperClass])  
 return []


def checkArguments(self, parameterType, argumentType , argument):
  if len(parameterType) != len(argumentType):
    self.error('', '',self.stack[-1]+' wrong arguments')
  for i in range(0, len(parameterType)):
    if parameterType[i] != argumentType[i]:
      if (self.inherit[argumentType[i]]):
        argumentClassPathList = self.searchInherit(parameterType[i], [argumentType[i]])
        if argumentClassPathList[-1] == parameterType[i]:
          argument[i] = [argument[i]] + argumentClassPathList
        else:
          self.error('', argumentType[i], parameterType[i]+' was expected')
      else:
        self.error('', argumentType[i], parameterType[i]+' was expected')
  return argument

def getVariable(self, variableName):
  variableEntity=self.findScope(variableName, [self.stack[-1]])
  if not variableEntity: 
        return (False, 'not in scope')
  variableClassPathList, variableType = variableEntity
  variableClassPath = ['$'+upperClass for upperClass in variableClassPathList[2:]]                    
  variableList=variableClassPath+[variableName]
  if len(variableClassPathList) > 1 and variableClassPathList[1] != 'main':
        variableList = ['self']+variableList
  return (variableList, variableEntity)

def getFunction(self, functionName, parameterType:list, argumentList:list, currentScope:list, d=2):
  functionEntity=self.findScope(functionName, currentScope)
  if not functionEntity: 
        return (False,'not in currentScope', None)
  functionClassPathList,functionType = functionEntity
  self.checkArguments(functionType[1:-1], parameterType, argumentList)
  pppFunctionName=functionName+'$'+functionClassPathList[-1]
  functionClassPath = ['$'+upperClass for upperClass in functionClassPathList[d:]]
  if len(functionClassPathList) > 1 and functionClassPathList[1] != 'main': 
    functionClassPath = ['self'] +functionClassPath
  return (pppFunctionName, [functionClassPath], functionEntity)

def getDFunction(self, variableName, functionName, functionType:list, argument:list):
  variableList, variableEntity = self.getVariable(variableName)
  variableClassPathList, variableType = variableEntity

  pppFunctionName, functionClassPath, functionEntity = self.getFunction(functionName, functionType, argument, [variableType], 1)
  functionClassPathList, functionType = functionEntity
  
  functionClassPath2 = ['$'+upperClass for upperClass in functionClassPathList[1:]]
  variableClassPath = ['$'+upperClass for upperClass in variableClassPathList[2:]]
 
  dFunctionClassPath=[variableClassPath+[variableName]+functionClassPath2]+argument

  if len(variableClassPathList) > 1 and variableClassPathList[1] != 'main': 
    dFunctionClassPath[0] = ['self'] +dFunctionClassPath[0]
  
  return (pppFunctionName, dFunctionClassPath, functionEntity)

def error(self, line, token, message):
 print(str(line)+': '+token+' '+message)
 quit()

def printTable(self):
 for pppClass in self.table:
  print('\nScope: '+pppClass)
  for pppSymbol in self.table[pppClass]:
   print(variable,self.table[pppClass][pppSymbol])

def printInherit(self):
 for pppClass in self.inherit:
  print('\nClass: '+pppClass)
  for pppParentClass in self.inherit[pppClass]:
   print(pppParentClass)


}

startRule
        :   classes 
        ;

classes
        :   class_def*
            class_main_def 
            EOF
        ;

class_def returns [list upperClasses]
        :       'class' className=class_name
                                        {self.addScope($class_name.text)}
                                        {$upperClasses=[]}

                ( 'inherits' class_name 
                                        {$upperClasses.append($class_name.text)}
                (',' class_name         
                                        {$upperClasses.append($class_name.text)} 
                )*  )? ':' 
                (declarations ';'';' )?
                                        {self.inherit[self.stack[-1]] = $upperClasses}
                class_body
                                        {self.stack.pop()}
        ;

class_main_def
        :   'class' ('main' | 'Main') ':' 
                                        {self.table['main'] = {}} 
                                        {self.addScope('main')}
                                        {self.inherit[self.stack[-1]] = []}
            (declarations ';'';')?
            main_body
            
        ;

class_name
        : ID
        ;

declarations
        :       decl_line (';' decl_line)* 
        ;

class_body
        :       ( constructor_def ';'';' )+( method_def ';'';')*
        ;

main_body
        :   method_main_def ';'';'
        ;

decl_line returns [list varList]
        :       varType=types ID                
                                        {self.table[self.stack[-1]][$ID.text] = $types.text}
                                        {$varList=[$ID.text]}
                (',' ID                 {self.table[self.stack[-1]][$ID.text] = $types.text}
                                        {$varList+=[$ID.text]} 
                )*
        ;

constructor_def returns [string pppConstructor]
        :       'def' '__init__'        {$pppConstructor="__init__@"+self.stack[-1]} {self.addScope($pppConstructor)}
                parameters ':' class_name
                                        {self.table[self.stack[-2]]['__init__'] = [self.stack[-2]]+$parameters.parameterType+[$class_name.text]}
                                        {self.inherit[self.stack[-1]] = [self.stack[-2]]}
                method_body
                                        {self.stack.pop()}
        ;

method_def returns [string pppMethod]
        :       'def' ID                {$pppMethod=$ID.text+"@"+self.stack[-1]} {self.addScope($pppMethod)}       
                parameters ':' return_type
                                        
                                        {self.table[self.stack[-2]][$ID.text] = [self.stack[-2]]+$parameters.parameterType+[$return_type.text]}
                                        {self.inherit[self.stack[-1]] = [self.stack[-2]]}
                method_body
                                        {self.stack.pop()}
        ;

method_main_def returns [string mainMethod]
        :       'def' 'main' '(' 'self' ')' ':' '-'
                                        {mainMethod=self.stack[-1]+"@main"} {self.addScope(mainMethod)}

                                        {self.table[self.stack[-2]]['main'] = ['self','-']}
                                        {self.inherit[self.stack[-1]] = [self.stack[-2]]}
                method_body
                                        {self.stack.pop()}
        ;

types
        :   class_name
        |   'int'
        ;

parameters returns [string parameterString, list parameterType]
        :   '(' parlist ')'             {$parameterString='('+$parlist.parlistString+')'} {$parameterType=$parlist.parlistType} 
        ;

method_body
        :       (declarations ';')? 
                (statements)?
        ;

return_type
        :   types        
        |   '-'                    
        ;

parlist returns [string parlistString, list parlistType, list parameterList]
        :       'self'                  {$parlistString,$parlistType,$parameterList='self',[],[]}
                (',' types ID           {$parlistString+=', '+$types.text+' '+$ID.text} {$parlistType.append($types.text)} {$parameterList.append($ID.text)}
                                        {self.table[self.stack[-1]][$ID.text] = $types.text}
                )*
        ;

statements
        :       statement (';' statement)*
        ;

statement
        :   assignment_stat             
        |   direct_call_stat             
        |   if_stat            
        |   while_stat    
        |   return_stat    
        |   input_stat      
        |   print_stat       
        ;

assignment_stat returns [list idList, list exprList]
        :   ('self.')? ID '='
                                        {$idList, idEntity=self.getVariable($ID.text)}
                                        {if not $idList: self.error($ID.line, $ID.text, idEntity)}
                 expression             {$exprList=[$expression.exprString]} 
        |  constructor_call           
                                        {argumentList = $constructor_call.argumentList}
                                        {argumentTypeList = $constructor_call.argumentTypeList}
                                        {if not self.stack[-1].split('@')[0] == '__init__': argumentTypeList = argumentTypeList[1:]}
                                        {if self.stack[-1] == 'main@main': argumentList = argumentList[1:]}
                                        {constructorEntity = self.getFunction('__init__', argumentTypeList, argumentList, [$constructor_call.constructorName])}
                                        {$exprList=[$constructor_call.constructorName,$constructor_call.argumentTypeList, argumentList]} 
        ;                               


direct_call_stat returns [string functionName, list functionClassPath]
        :   ( 'self.')? ID '.' func_call
                                        {pppFunctionName, classPath, pppEntity = self.getDFunction($ID.text,$func_call.functionName, $func_call.functionArgumentType, $func_call.functionArgument)}
                                        {if not pppFunctionName: self.error($func_call.start.line,$func_call.functionName,classPath) }
                                        {$functionName=pppFunctionName}{$functionClassPath=classPath}
        |   ('self.')? func_call
                                        {pppFunctionName, classPath, pppEntity=self.getFunction($func_call.functionName, $func_call.functionArgumentType, $func_call.functionArgument, [self.stack[-1]])}
                                        {if not pppFunctionName: self.error($func_call.start.line,$func_call.functionName,classPath)}
                                        {$functionName = pppFunctionName}{$functionClassPath=classPath}
        ;

if_stat
        :       'if' '(' condition ')' ':'                
                (statements ';')?      
                else_part
                'endif'
        ;

else_part returns [int elseFlag]
        :       'else' ':'    
                ( statements ';')?              {$elseFlag=1}
        |                                       {$elseFlag=0}
        ;

while_stat
        :       'while' '(' condition ')' ':'
                (statements)?
                'endwhile'
        ;

return_stat
        :   'return' expression
        ;

input_stat returns [list idList]
        :   'input'('self.')? ID                {$idList, variableEntity=self.getVariable($ID.text)}
                                                {if not $idList: self.error($ID.line, $ID.text, variableEntity)}
        ;

print_stat
        :   'print' expression 
        ;

expression returns [string exprString, string exprType]
        :       optional_sign term              {$exprString, $exprType=$optional_sign.text+$term.termString, $term.termType} 
                (add_oper term                  {$exprString+=$add_oper.text+$term.termString}    
                                                {if $term.termType != $exprType: self.error($term.start.line,$term.text,'different type expected')}
                )*
        ;

arguments returns [list argumentList, list argumentTypeList]
        :   '(' arglist ')'                     {$argumentList, $argumentTypeList = $arglist.argumentList, $arglist.argumentTypeList} 
        ;

condition returns [int orCount]
        :       {$orCount=0} boolterm ({$orCount+=1} 'or' boolterm)*
        ;

optional_sign
        :   add_oper
        |
        ;

term returns [string termString, string termType]
        :       factor                          {$termString=$factor.factorString} 
                                                {$termType=$factor.factorType}
                ( mul_oper factor               {$termString+=$mul_oper.text+$factor.factorString} 
                                                {if $factor.factorType != $termType: self.error($factor.start.line,$factor.text,'different type expected')}
                )*
        ;

add_oper
        :   '+' 
        |   '-'       
        ;

arglist returns [list argumentList, list argumentTypeList]
        :                                       {$argumentList, $argumentTypeList=[], []} 
                argitem                         {$argumentList+=[$argitem.argitemString]}
                                                {$argumentTypeList+=[$argitem.argitemType]}
                (',' argitem                    {$argumentList+=[$argitem.argitemString]}
                                                {$argumentTypeList+=[$argitem.argitemType]} 
                )*
        |                                       {$argumentList, $argumentTypeList=[], []} 
        ;

boolterm returns [int andCount]
        :       {$andCount=0} boolfactor ({$andCount+=1} 'and' boolfactor)*
        ;

factor returns [string factorString, list factorArgument, string factorType, string case]
        :   {$case=1} integer                             
                                                {$factorArgument, $factorString, $factorType = [], $integer.text, 'int'}
        |   {$case=2} '(' expression ')'         
                                                {$factorArgument, $factorString, $factorType = [], '('+$expression.exprString+')', $expression.exprType}                         
                                                
        |   {$case=3} ('self.')? ID
                                                {$factorArgument, factorEntity=self.getVariable($ID.text)}
                                                {if not $factorArgument: self.error($ID.line, $ID.text, factorEntity)}
                                                {$factorString=$factorArgument[0]}{$factorType = factorEntity[1]}
                                                
        |   {$case=4} ('self.')? ID '.' func_call
                                                {$factorString, $factorArgument, factorEntity = self.getDFunction($ID.text,$func_call.functionName, $func_call.functionArgumentType, $func_call.functionArgument)}
                                                {if not $factorString: self.error($func_call.start.line,$func_call.functionName,$factorArgument) }
                                                {$factorType = factorEntity[1][-1]}

        |   {$case=5} ('self.')? func_call
                                                {$factorString, $factorArgument, factorEntity = self.getFunction($func_call.functionName, $func_call.functionArgumentType, $func_call.functionArgument, [self.stack[-1]])}
                                                {if not $factorString: self.error($func_call.start.line, $func_call.functionName, $factorArgument) }
                                                {$factorType = factorEntity[1][-1]}

        ;

mul_oper
        :   '*'
        |   '/'
        ;

argitem returns [string argitemString, string argitemType]
        :   expression {$argitemString, $argitemType = $expression.exprString, $expression.exprType}
        ;

boolfactor returns [int boolfactorCase]
        :   'not' '[' condition ']'             {$boolfactorCase=1}
        |   '[' condition ']'                   {$boolfactorCase=2}   
        |   expression rel_oper expression      {$boolfactorCase=3}
        ;

integer
        :
            INTEGER
        ;

func_call returns [string functionName, list functionArgument, list functionArgumentType]
        :   ID arguments                        
        {$functionName, $functionArgument, $functionArgumentType = $ID.text, $arguments.argumentList, $arguments.argumentTypeList} 
        ;

constructor_call returns [string constructorName, list argumentList, list argumentTypeList]
        :   '$'class_name arguments             
        {$constructorName, $argumentList, $argumentTypeList = $class_name.text, $arguments.argumentList, $arguments.argumentTypeList} 
        ;

rel_oper
        :  '=='
        |   '<='
        |   '>='
        |   '>'
        |   '<'
        |   '!='
        ;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


WS: [ \t\r\n]+ -> skip;
COMMENTS: '#' ~[#]* '#' -> skip;
ID: ID_START (ID_CONTINUE)*;
INTEGER: NON_ZERO_DIGIT (DIGIT)* | '0'+;

fragment ID_START
        : [A-Z]
        | [a-z]
        ;

fragment ID_CONTINUE
        : '_'
        | [A-Z]
        | [a-z]
        | [0-9]
        ;

fragment NON_ZERO_DIGIT
        : [1-9]
        ;

fragment DIGIT
        : [0-9]
        ;
