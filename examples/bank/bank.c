#include<stdio.h>
#include <stdlib.h>

typedef struct Employee_s {
int id, works;
} Employee;
Employee __init__$Employee(Employee *self, int id){
self = (Employee*) malloc(sizeof(Employee));
{
id=id;
self->works=0;}
}
void startWork$Employee(Employee *self){{
self->works=1;}
}
void stopWork$Employee(Employee *self){{
self->works=0;}
}
int getID$Employee(Employee *self){{
return self->id;}
}
typedef struct Bank_s {
Employee *e1, *e2, *e3, *e4;
int id;
} Bank;
Bank __init__$Bank(Bank *self, int id){
self = (Bank*) malloc(sizeof(Bank));
{
id=id;}
}
void showWorkingEmployee$Bank(Bank *self){
int in;{
in=-1;
while(in!=0){
if(in==1){
printf("%d\n", getID$Employee(self->e1));}
if(in==2){
printf("%d\n", getID$Employee(self->e2));}
if(in==3){
printf("%d\n", getID$Employee(self->e3));}
if(in==4){
printf("%d\n", getID$Employee(self->e4));}
scanf("%d", &in);}}
}
typedef struct Department_s {
Bank* $Bank;
int dept_id;
} Department;
Department __init__$Department(Department *self, int bank_id, int dept_id){
self = (Department*) malloc(sizeof(Department));
{
__init__$Bank(self->$Bank,bank_id);
dept_id=dept_id;}
}
typedef struct Teller_s {
Employee* $Employee;
int teller_id;
Department *dept;
} Teller;
Teller __init__$Teller(Teller *self, int id, int teller_id, Department *dept){
self = (Teller*) malloc(sizeof(Teller));
{
__init__$Employee(self->$Employee,id);
id=id;
teller_id=teller_id;
dept=dept;}
}
typedef struct Economic_s {
Department* $Department;
Teller *economicDepartmentTeller;
} Economic;
Economic __init__$Economic(Economic *self, int bank_id, int dept_id, Teller *deptTeller){
self = (Economic*) malloc(sizeof(Economic));
{
__init__$Department(self->$Department,1,2);
self->$Department->$Bank->id=bank_id;
dept_id=dept_id;
self->economicDepartmentTeller=deptTeller;}
}
typedef struct Security_s {
Employee* $Employee;
int security_id;
Department *dept;
} Security;
Security __init__$Security(Security *self, int id, int security_id, Department *dept){
self = (Security*) malloc(sizeof(Security));
{
__init__$Employee(self->$Employee,id);
security_id=security_id;
dept=dept;}
}
Bank *b1;
Teller *t1, *t2;
Security *s1;
Economic *ec1;
int main(){{
__init__$Bank(b1,1);
__init__$Teller(t1,1,2,ec1->$Department);}
}