#include<stdio.h>
#include <stdlib.h>

typedef struct Vehicle_s {
int x1, y1;
} Vehicle;
Vehicle __init__$Vehicle(Vehicle *self){
self = (Vehicle*) malloc(sizeof(Vehicle));

}
int startVehicle$Vehicle(Vehicle *self, int velocity){{
self->x1=5;
return 5;}
}
void stopVehicle$Vehicle(Vehicle *self){
}
typedef struct Flying_s {
int x2, y2;
} Flying;
Flying __init__$Flying(Flying *self){
self = (Flying*) malloc(sizeof(Flying));

}
int fly$Flying(Flying *self){{
return 5;}
}
typedef struct Airplane_s {
Vehicle* $Vehicle;
Flying* $Flying;
int x;
Vehicle *v1, *v2, *v3;
} Airplane;
Airplane __init__$Airplane(Airplane *self){
self = (Airplane*) malloc(sizeof(Airplane));
{
__init__$Vehicle(self->$Vehicle);
__init__$Flying(self->$Flying);
self->x=2;}
}
void lowAltitude$Airplane(Airplane *self, int alt){
int xz, xy;{
self->$Vehicle->x1=5;
__init__$Vehicle(self->v1);
__init__$Vehicle(self->v2);
startVehicle$Vehicle(self->v1,51);
startVehicle$Vehicle(self->v2,61);
while(5<4){
if(3>2){
printf("%d\n", 1);}
else{
scanf("%d", &self->$Flying->x2);}}}
}
void highAltitude$Airplane(Airplane *self, int alt){{
lowAltitude$Airplane(self,5);
fly$Flying(self->$Flying);
self->x=startVehicle$Vehicle(self->v3,5);}
}
typedef struct Car_s {
Vehicle* $Vehicle;
int x3, y3;
int doors, n;
Airplane *vx;
} Car;
Car __init__$Car(Car *self, Vehicle *a){
self = (Car*) malloc(sizeof(Car));
{
__init__$Vehicle(self->$Vehicle);}
}
void makeHorn$Car(Car *self){
}
typedef struct Jeep_s {
Car* $Car;
int x8, x9;
} Jeep;
Jeep __init__$Jeep(Jeep *self){
self = (Jeep*) malloc(sizeof(Jeep));
{
self->$Car->$Vehicle->x1=5;}
}
int jeepemall$Jeep(Jeep *self, int x0){{
self->x8=5;
return self->x8;}
}
int testest$Jeep(Jeep *self){{
self->x8=jeepemall$Jeep(self,5);
__init__$Airplane(self->$Car->vx);
self->x9=startVehicle$Vehicle(self->$Car->$Vehicle,startVehicle$Vehicle(self->$Car->vx->$Vehicle,4)+(jeepemall$Jeep(self,fly$Flying(self->$Car->vx->$Flying))*3));
return self->x8;}
}
typedef struct Motorcycle_s {
Vehicle* $Vehicle;
} Motorcycle;
Motorcycle __init__$Motorcycle(Motorcycle *self){
self = (Motorcycle*) malloc(sizeof(Motorcycle));

}
void makeSouza$Motorcycle(Motorcycle *self, int time, int height){
int x4, y4;{
x4=2;
y4=1;}
}
void testlast$Motorcycle(Motorcycle *self, Car *c){
int x5;{
x5=1;}
}
Jeep *v1;
Vehicle *v2;
Motorcycle *m1;
Airplane *a1;
int x, y;
int main(){{
__init__$Jeep(v1);
__init__$Vehicle(v2);
__init__$Motorcycle(m1);
__init__$Airplane(a1);
startVehicle$Vehicle(v1->$Car->$Vehicle,5);
startVehicle$Vehicle(v2,6);
x=startVehicle$Vehicle(v1->$Car->$Vehicle,3);
y=x;
while(5<9){
if(3>2){
printf("%d\n", 1);}
else{
scanf("%d", &x);}}
testlast$Motorcycle(m1,v1->$Car);
startVehicle$Vehicle(m1->$Vehicle,4);
makeSouza$Motorcycle(m1,10,4);}
}