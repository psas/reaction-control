rho = 0.59;  %kg/m^3
v = 664.2; %m/s
Cl = .32; %nasa chart for altitude of 
A_fin = .3; % m^2
m = 70 % kg
AoA= 2*pi()/180 % degrees
F=0.5*rho*(v^2)*A_fin*Cl*sin(AoA)  %N
r=.14;  % m
I=m*r^2


%for determining State Space matrix
Num= [F];
Den= [I/r 0 0];

[A,B,C,D] = tf2ss(Num,Den)

