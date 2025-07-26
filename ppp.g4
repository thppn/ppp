grammar ppp;

@parser::members {
symbols = {}
scope = []

def add_scope(self, current, parents):
    self.scope += [current]
    self.symbols[current] = [{}, {}, parents]

def add_func(self, func, type='-'):
    c = self.scope[0]
    m = f'{func}@{c}'
    self.symbols[c][1][func] = type, self.symbols[m][1]
        
def add_par(self, type, var):
    self.add_var(type, var)
    c = self.scope[-1]
    self.symbols[c][1][var] = type
        
def add_var(self, type, var):
	scope = self.scope[-1]
	self.symbols[scope][0][var] = type

def save_symbols(self):
    import json
    with open("symbols.json", "w") as f:
        json.dump(self.symbols, f, indent=2)

}
startRule
        :   classes {self.save_symbols()}
        ;

classes
        :   class_def* 
            class_main_def
            EOF
        ;

class_def
        :   'class' current=class_name {p=[]}('inherits' class_name {p=[$class_name.text]} (',' class_name {p.append($class_name.text)} )*  )? ':'
                {self.add_scope($current.text, p or [])}
            (declarations ';'';')?
            class_body
                {self.scope.pop()}
        ;

class_main_def
        :   'class' ('main' | 'Main') ':'
                {self.add_scope("_main", [])}
            (declarations ';'';')?
            main_body
                {self.scope.pop()}
        ;

class_name
        : ID
        ;

declarations
        :   decl_line  (';' decl_line )*
        ;

class_body
        :   (constructor_def ';'';')+
            (method_def ';'';')*
        ;

main_body
        :   method_main_def ';'';'
        ;

decl_line
        :   types ID  {self.add_var($types.text, $ID.text)} (',' ID  {self.add_var($types.text, $ID.text)} )*
        ;

constructor_def
        :   'def' '__init__' {self.add_scope(f'__{self.scope[0]}__@{self.scope[0]}', [self.scope[0]])} 
            {self.add_par(self.scope[0], 'self');}
            parameters ':' class_name
            {self.add_func('__%s__' % self.scope[0])}
            method_body
        ;

method_def
        :   'def' ID {self.add_scope("%s@%s" % ($ID.text,self.scope[0]), [self.scope[0]])} parameters ':' 
            (types {self.add_func($ID.text, $types.text)} | '-' {self.add_func($ID.text)} )
            method_body
        ;

method_main_def
        :   'def' 'main' {self.add_scope('main@_main', [self.scope[0]])} '(' 'self' ')' ':' '-' {self.add_func("main")}
            method_body
        ;

types
        :   class_name
        |   'int'
        ;

parameters
        :   '(' parlist ')'
        ;

method_body
        :   (declarations ';')? 
            (statements)?   {self.scope.pop()}
        ;

return_type
        :   types
        |   '-'
        ;

parlist 
        :   'self' //eeeeedw
            (',' types ID {self.add_par($types.text, $ID.text);} )*
        ;

statements :   statement (';' statement )*
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

assignment_stat 
        :   ('self.')? ID  '=' expression
        |   constructor_call
        ;

direct_call_stat
        :   ('self.')? ID '.' func_call 
        |   ('self.')? func_call 
        ;

if_stat
        :   'if' '(' condition ')' ':'
            (statements ';' )?
            else_part
            'endif'
        ;

else_part
        :   'else' ':'
            ( statements ';' )?
        |
        ;

while_stat
        :   'while' '(' condition ')' ':'
            ( statements )?
            'endwhile'
        ;

return_stat
        :   'return' expression
        ;

input_stat 
        :   'input' ('self.')? ID
        ;

print_stat
        :   'print' expression
        ;

expression
        :   optional_sign term (add_oper term )*
        ;

arguments
        :   '(' arglist ')'
        ;

condition
        :   boolterm
            ('or' boolterm )*
        ;

optional_sign
        :   add_oper
        |
        ;

term
        :   factor  ( mul_oper factor )*
        ;

add_oper
        :   '+'
        |   '-'
        ;

arglist
        :   argitem (',' argitem )*
        |
        ;

boolterm
        :   boolfactor ( 'and' boolfactor )*
        ;

factor
        :   integer 
        |   '(' expression ')' 
        |   ('self.')? ID
        |   ('self.')? ID '.' func_call
        |   ('self.')? func_call
        ;

mul_oper
        :   '*'
        |   '/'
        ;

argitem
        :   expression
        ;

boolfactor
        :   'not' '[' condition ']'
        |   '[' condition ']'
        |   expression rel_oper expression
        ;

integer
        :
            INTEGER
        ;

func_call
        :   ID arguments
        ;

constructor_call
        :   '$'class_name
            arguments
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