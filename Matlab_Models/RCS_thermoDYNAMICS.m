
%RCS Thermodynamic Model
%Erin Schmidt 
clear
clc
clf

%USAGE NOTE:for testing change p0, pc, eta, At to the appropriate values

%Assumptions
%   *Real gas effects are only modeled w/ Z factors
%   *Compressibility effects are negligible on the low pressure-side
%   *Tank emptying is assumed to be an adiabatic, reversible process
%   *Nozzle perfectly expands the gas with no losses of any kind

%Fundimental Constants
R=297; %nitrogen gas constant [J/(Kg*K)]
k=1.4; %ratio of specific heats
g=9.81; %acceleration of gravity [m/s^2]
a=0.142666; %nitrogen van der Waal constant [Pa*m^6/mol^2] 
b=3.913E-5; %nitrogen van der Waal constant [m^3/mol] 
M=28.01/1000; %nitrogen molecular mass [kg/mol] 
Rbar=8.3145; %universal gas constant [Pa*m^3/K*mol]
stdden=1.2754;%density of air at 60F and 14.7 psia [kg/m^3]

%Design Constants
pe=101.3E3; %exit pressure (i.e. ambient pressure at sea level) [Pa] 
V=0.002; %tank volume (assumed to be a COTS 0.6 L pressure tank) [m^3] 
alpha=0.262; %cone half angle [radians]
lambda=(1+cos(alpha))/2; %nozzle correction factor [units]
n=1; %n nozzles
dutycycle=1; %*100% percent of each unit time that the valve is open
eta=1.2;%Expansion ratio
pc=200/1.450377E-4; %low-side (i.e. regulated) pressure [pa]
At=(.08*0.0254)^2*3.14159; %throat area [m^2], currently .08 in
Ae=At*eta; %nozzle exit area [m^2]

%Initial Conditions
T0=293;%initial tank temperature in K
p0=4500/1.450377E-4;%initial tank pressure in Pa
syms Vm Z m rhoTank
S=solve(rhoTank==m/V, Vm==M/rhoTank, Z==Vm/(Vm-b)-a/(Rbar*T0*Vm), m==p0*V/(R*T0*Z));
Z=real(vpa(S.Z(1)));
m=real(vpa(S.m(1)));

%Initialize loop
T=T0;
p=p0;
pf=p0;
t=0;
rho=pc/(R*T0);
rhoTank=m/V;

%Outputs

    %TODO
    % >> can include function for pe changing with altitude
    % >> Joule thompson losses/minor losses in solenoid?
    
while T>80
    Vm=M/rhoTank; %molar Volume of Nitrogen (inside the tank)
    Z=Vm/(Vm-b)-a/(Rbar*T*Vm); %compressibility factor Z
    pf=m*R*T0*Z/V; %tank pressure [Pa]
    rhoTank=m/V; %p/(R*T0); %tank density [kg/m^3]
    rho=pc/(R*T0); %low-side density [kg/m^3]

    mdotF=At*pc*sqrt(2*k/(k-1)*1/(R*T)*(pe/pc)^(2/k)*(1-(pe/pc)^((k-1)/k)));
    m=m-mdotF*n*dutycycle*1/10; %propellant mass [kg]
    T=T0*(pf/p)^((k-1)/k); %tank temperature [K]
    Tf=9/5*(T-273)+32; %tank temperature [F]
    
    %for determining solenoid flow coefficients
    SGsol=rho/stdden; %specific gravity of nitrogen on the low side
    qsol=1763*mdotF/sqrt(SGsol);
    pcpsi=pc*1.450377E-4;
    %Cvsol=2*qsol*sqrt(SGsol)/pcpsi;
    deltaPsol=pc-pe;
    Ysol=1-(deltaPsol/pc)/1.5;
    Cvsol=qsol*sqrt(SGsol*(Tf+460))/(22.67*pcpsi*Ysol*sqrt(deltaPsol/pc));
    
    %for determining regulator flow coefficients
    SGreg=rhoTank/stdden; %specific gravity of nitrogen on the high side
    qreg=1763*mdotF/sqrt(SGreg);
    pfpsi=pf*1.450377E-4
    deltaPreg=pf-pc;
    Yreg=1-(deltaPreg/pf)/1.5;
    Cvreg=qreg*sqrt(SGreg*(Tf+460)*Z)/(22.67*pfpsi*Yreg*sqrt(deltaPreg/pf));
    
    Ve=sqrt(2*k/(k-1)*R*T*(1-(pe/pc)^((k-1)/k))); %exhaust velocity [m/s]
    isp=Ve/g; %specific impulse [s]
    F=lambda*mdotF*Ve;%thrust per nozzle [N]
    p=pf;
    t=t+1/10 %time [s]
    T0=T;
   
    %Plots
    hold all;
    subplot(4,3,1);
    plot(t,T, 'r');
    xlabel('time (s)');
    ylabel('temperature (K)');
    
    hold all;
    subplot(4,3,2);
    plot(t,pfpsi, 'b');
    xlabel('time (s)');
    ylabel('pressure (psi)');
    
    hold all;
    subplot(4,3,3);
    plot(t,isp, 'g');
    xlabel('time (s)');
    ylabel('isp (s)');
    
    hold all;
    subplot(4,3,4);
    plot(t,F, 'm');
    xlabel('time (s)');
    ylabel('thrust (N)');
    
    hold all;
    subplot(4,3,5);
    plot(t,m, 'k');
    xlabel('time (s)');
    ylabel('propellant mass (kg)');
    
    hold all;
    subplot(4,3,6);
    plot(p*Vm/(Rbar*T),Z, 'c');
    xlabel('p*Vm/T*Runiversal (units)');
    ylabel('compressibility factor');
    
    hold all;
    subplot(4,3,7);
    plot(t,mdotF, 'r');
    xlabel('time (s)');
    ylabel('mass flow rate (kg/s)');
    
    hold all;
    subplot(4,3,8);
    plot(t,Z, 'c');
    xlabel('time (s)');
    ylabel('compressibility factor');
    
    hold all;
    subplot(4,3,9);
    plot(t,Cvreg, 'r');
    xlabel('time (s)');
    ylabel('Cv regulator');
    
    hold all;
    subplot(4,3,10);
    plot(t,Cvsol, 'b');
    xlabel('time (s)');
    ylabel('Cv solenoid');
end

t
p
T
m
ppsi=p*0.000145037738
