from antlr4 import *
from grammar.pppListener import pppListener

class ppp(pppListener):

    def __init__(self):
        self.scope = []
        self.default_types = ['int', 'void']
        self.__load_symbols()
        self.o = ""
        self.defs = '#include <stdio.h>\n' + self.__create_structs()

    def __del__(self):
        with open("output.c", "w") as f:
            f.write(self.defs + self.o)

    def __get_define(self, name, type):
        self.defs += f'{type} {'$'.join([name, type] + self.scope)};\n'
        for parent in self.symbols[type][2]:
            self.__get_define(name, parent)

    def __set_define(self, path, name, type, d=0):
        new_path = f'{path}{f'->${type}' if d else ''}'
        self.o += f'{new_path} = &{'$'.join([name, type] + self.scope)};\n'
        for parent in self.symbols[type][2]:
            self.__set_define(new_path, name, parent, d+1)

    def __create_structs(self):
        structs = ""
        classes = self.__get_classes()
        for c in classes:
            declarations = self.symbols[c][0]
            ancestors = self.symbols[c][2]
            structs += 'typedef struct {\n'
            for a in ancestors: structs += f"   {a}* ${a};\n"
            for v in declarations:  structs += f"    {self.fix_type(declarations[v])} {v};\n"
            structs += '} %s;\n' % c
        return structs
    
    def __load_symbols(self):
        import json
        with open('symbols.json', 'r') as f:
            self.symbols = json.load(f)

    def __get_classes(self):
        return list(filter(lambda c: '@' not in c, self.symbols.keys()))

    # returns a local variable
    def __get_local_var(self, entry, scope):
        if entry in self.symbols[scope][0].keys():
            return entry, self.symbols[scope][0][entry]
                
    # returns a non local variable
    def __get_self_var(self, entry, current):
        if entry in self.symbols[current][0].keys():
            return f'{entry}', self.symbols[current][0][entry]
        for p in self.symbols[current][2]:
            ret = self.__get_self_var(entry, p)
            if ret: return '$'+p+'->'+ret[0], ret[1]
        return None

    def __get_scope(self, init, scope):
        parents = self.symbols[init][2]
        if scope in parents: 
            return f'${scope}'
        for p in parents:
            ret = self.__get_scope(p, scope)
            if ret: return f'${p}->{ret}'
        return None

    def initialize(self, path, name, type):
        self.__get_define(name, type)
        self.__set_define(path, name, type)

    # returns a variable
    def get_var(self, entry, is_self):
        if not is_self: 
            return self.__get_local_var(entry, '@'.join(reversed(self.scope)))
        var, var_type = self.__get_self_var(entry, self.scope[0])
        return ('self->' + var), var_type


    # returns the class of an entry
    def get_class(self, entry, scope, is_method=0):
        if entry in self.symbols[scope][is_method].keys():
            return scope
        for p in self.symbols[scope][2]:
            ret = self.get_class(entry, p, is_method)
            if ret: return ret
        return None
    
    # returns a method
    def get_method(self, method_id, scope):
        method_class = self.get_class(method_id, scope, 1)
        self.set_parlist(method_id, method_class)
        method_type = self.symbols[method_class][1][method_id][0]
        return f'{method_id}${method_class}', method_class, method_type
            
    def get_method_self(self, id, method_class, scope):
        if method_class == scope:
            return f"{id}" if id else 'self'
        scope_path = self.__get_scope(scope, method_class)
        return  f'{id}->{scope_path}' if id else f'self->{scope_path}'
    
    def set_parlist(self, method_id, method_class):
        self.parlist = list(reversed(self.symbols[method_class][1][method_id][1].values()))

    def check_scope(self, entry, entry_type):
        if entry_type != self.arg_type:
            if entry_type not in self.default_types:
                scope_path = self.__get_scope(entry_type, self.arg_type)
                if scope_path:
                    return f'{entry}->{scope_path}'
                else:
                    exit(f'error1 {entry} {entry_type} {self.arg_type} ')
            else:
                exit(f'error2 {entry} {entry_type} {self.arg_type}')
        
        return entry

    def fix_type(self, type):
        return type if type in self.default_types else f'{type}*'
    
    def enterClass_def(self, ctx):
        self.scope.append(ctx.current.getText())

    def exitClass_def(self, ctx):
        self.scope.pop()

    def enterClass_main_def(self, ctx):
        self.scope.append('_main')

    def exitClass_main_def(self, ctx):
        self.scope.pop()

    def exitMethod_main_def(self, ctx):
        self.scope.pop()

    def enterDecl_line(self, ctx):
        if len(self.scope) == 2:
            self.o+=''.join([self.fix_type(ctx.types().getText())]+[f' {i},' for i in ctx.ID()])[:-1]+';\n'

    def enterConstructor_def(self, ctx):
        self.scope.append(f'__{ctx.class_name().getText()}__')
        self.o+= f"void __{ctx.class_name().getText()}__({ctx.class_name().getText()}* self"

    def exitConstructor_def(self, ctx):
        self.scope.pop()

    def enterMethod_def(self, ctx):
        self.scope.append(ctx.ID().getText())
        method_type = ctx.types().getText() if ctx.types() else "void"
        self.o+=f"{self.fix_type(method_type)} {ctx.ID().getText()}${self.scope[0]}({self.scope[0]}* self" 

    def exitMethod_def(self, ctx):
        self.scope.pop()

    def enterMethod_main_def(self, ctx):
        self.scope.append('main')
        self.o+='void main()' 

    def enterMethod_body(self, ctx):
        self.o+=' {\n'
        if self.scope[0] == '_main':
            self.o+=f'_main __main__;_main *self=&__main__;\n'

    def exitMethod_body(self, ctx):
        self.o+='}\n'

    def enterReturn_type(self, ctx):
        self.o+='return'

    def enterParlist(self, ctx):
        self.o+=''.join([f', {j.getText()}{'' if j.getText() in self.default_types else '*'} {i}' for i, j in zip(ctx.ID(),ctx.types())])+')'

    def exitStatement(self, ctx):
        self.o+='\n' if self.o[-1] == '}' else ';\n'

    def enterAssignment_stat(self, ctx):
        if ctx.ID():
            id, self.arg_type = self.get_var(ctx.ID().getText(), 'self' in ctx.getText())
            self.o+=f"{id} = "
           

    def enterDirect_call_stat(self, ctx):
        id, scope = (self.get_var(ctx.ID().getText(), 'self' in ctx.getText())) if ctx.ID() else ("", self.scope[0])
        method, method_class, method_type = self.get_method(ctx.func_call().ID().getText(), scope)
        self.o+=f'{method}({self.get_method_self(id, method_class, scope)}'
 
    def enterIf_stat(self, ctx):
        self.o+='if'

    def exitIf_stat(self, ctx):
        self.o+='}'

    def enterElse_part(self, ctx):
        self.o+='} else {' if ctx.getText() else ""

    def enterWhile_stat(self, ctx):
        self.o+='while'

    def exitWhile_stat(self, ctx):
        self.o+='}'

    def enterReturn_stat(self, ctx):
        self.arg_type = self.symbols[self.scope[0]][1][self.scope[1]][0]
        self.o+='return '

    def enterInput_stat(self, ctx):
        id, self.arg_type = self.get_var(ctx.ID().getText(), 'self' in ctx.getText())
        self.o+=f'scanf("%d", &({id}))' 

    def enterPrint_stat(self, ctx):
        self.arg_type = 'int'
        self.o+='printf("%i\\n", '
    
    def exitPrint_stat(self, ctx):
        self.o+=')'

    def exitArguments(self, ctx):
        self.o+=')'

    def enterCondition(self, ctx):
        self.o+='('
        self._or = len(ctx.boolterm())-1

    def exitCondition(self, ctx):
        self.o+=') {\n'

    def enterAdd_oper(self, ctx):
        self.o+=ctx.getText()

    def enterFactor(self, ctx):
        if ctx.getText().isdigit():
            self.o += self.check_scope(ctx.getText(), 'int')
        elif ctx.ID() and ctx.func_call():
            id, id_type = self.get_var(ctx.ID().getText(), 'self' in ctx.getText())
            method, method_class, method_type = self.get_method(ctx.func_call().ID().getText(), id_type) 
            self.o+=f'{self.check_scope(method, method_type)}({self.get_method_self(id, method_class, id_type)}'
        elif ctx.ID():
            id, id_type = self.get_var(ctx.ID().getText(), 'self' in ctx.getText())
            self.o += self.check_scope(id, id_type)
        elif ctx.func_call(): 
            method, method_class, method_type = self.get_method(ctx.func_call().ID().getText(), self.scope[0]) 
            self.o += f'{self.check_scope(method, method_type)}({self.get_method_self('', method_class, self.scope[0])}'
        else:
            self.o += '('
    
    def exitFactor(self, ctx):
        if ctx.getText()[0] == '(': 
            self.o += ')'

    def enterMul_oper(self, ctx):
        self.o+=ctx.getText()
    
    def enterArgitem(self, ctx):
        if self.o[-1] != '(': self.o += ', '
        self.arg_type = self.parlist.pop()

    def enterRel_oper(self, ctx):
        self.o+=ctx.getText()

    def enterConstructor_call(self, ctx):
        class_name = ctx.class_name().ID().getText()
        self.set_parlist(f'__{class_name}__', class_name)
        inst, inst_type = ctx.arguments().arglist().getText().split(',')[0], self.parlist[-1]
        inst_name  = inst.split('.')[-1]
        inst_path = self.get_var(inst_name, 'self' in inst)[0]
        self.initialize(inst_path, inst_name, inst_type)
        self.o+=f"__{class_name}__("

    def enterRel_oper(self, ctx):
        self.o += ctx.getText()

    def enterBoolterm(self, ctx):        
        self._and = len(ctx.boolfactor())-1
    
    def exitBoolterm(self, ctx):
        if self._or:
            self._or -= 1
            self.o += '||'

    def enterBoolfactor(self, ctx):
        if ctx.getText()[0] == 'not':
            self.o += '!('
        elif ctx.getText()[0] == '[':
            self.o += '('
        else:
            self.arg_type = 'int'

    def exitBoolfactor(self, ctx):
        if ctx.getText()[0] == 'not' or ctx.getText()[0] == '(':
            self.o += ')'
        if self._and:
            self._and -= 1
            self.o += '&&'