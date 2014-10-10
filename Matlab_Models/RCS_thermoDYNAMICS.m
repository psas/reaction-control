%RCS Thermodynamic Model
%Erin Schmidt 

%Assumptions
%   *Real gas effects are only modeled w/ Z factors
%   *Compressibility effects are negligible on the low pressure-side
%   *Tank emptying is assumed to be an adiabatic, reversible process
%   *Nozzle perfectly expands the gas with no losses of any kind

%Usage note: if the tank volume (or inital tank pressure is changed),
%several constants will have to be recomputed.

%Fundimental Constants
R=297; %nitrogen gas constant [J/(Kg*K)]
k=1.4; %ratio of specific heats
g=9.81; %acceleration of gravity [m/s^2]
a=0.142666; %nitrogen van der Waal constant [Pa*m^6/mol^2] 
b=3.913E-5; %nitrogen van der Waal constant [m^3/mol] 
M=28.01/1000; %molecular mass [kg/mol] 
Rbar=8.3145; %universal gas constant [Pa*m^3/K*mol]
stdden=1.2754;%density of air at 60F and 14.7 psia [kg/m^3]

%Design Constants
pe=101.3E3; %exit pressure (i.e. ambient pressure at sea level) [Pa] 
pcpsi=60; %low-side (i.e. regulated) pressure [psi]
pc=pcpsi/1.450377E-4; %low-side pressure [Pa]
V=0.001; %tank volume (assumed to be a COTS 1 L pressure tank) [m^3] 
alpha=0.262; %cone half angle [radians]
lambda=(1+cos(alpha))/2; %nozzle correction factor [units]
%mdot=0.0132; Suggested by nozzle model Not actually constant
n=1; %n nozzles
dutycycle=1; %*100% percent of each unit time that the valve is open
Q=3.3324E-3*n*dutycycle; %volumetric flow rate (constant with time, varies across regulator) [m^3/s], is this for the reg or sol?
Ae=4.374E-5; %nozzle exit area [m^2]
%Qscfm=Q*15852;%volumetric flow rate in SCFPM

%Initial Conditions
Z=1.15;
T0=293;%initial tank temperature in K
p0=3.103E7;%initial tank pressure in Pa (4500 psi) (31MPa)
m=0.3101; %0.404 %initial propellant mass in kg

%m=p0*V/(R*T0*Z) %for correcting inital conditions

%Initialize loop
T=T0;
p=p0;
pf=p0;
t=0;
rho=pc/(R*T0);
rhoTank=m/(V); %p/(R*T0);

%Outputs

    %TODO
    % >> can include function for pe changing with altitude
    % >> recheck flow coefficient equation
    % >> fix graphs
    % >> Joule thompson losses/minor losses in solenoid?
    % >> recheck nozzle exit area
    % >> pressure change is related to flow rates via Cv

while T>80
    Vm=M/rhoTank; %molar Volume of Nitrogen (inside the tank)
    Z=Vm/(Vm-b)-a/(Rbar*T*Vm); %compressibility factor Z
    pf=m*R*T0*Z/V; %tank pressure [Pa]
    rhoTank=m/(V); %p/(R*T0); %tank density [kg/m^3]
    rho=pc/(R*T0); %low-side density [kg/m^3]
   
    mdot=rho*Q/10; %mass flow rate from tank [kg/s]
    mdotF=rho*Q/(n*10*dutycycle); %mass flow rate seen by any given thruster [kg/s]
    m=m-mdot; %propellant mass [kg]
    T=T0*(pf/p)^((k-1)/k); %tank temperature [K]
    Tf=9/5*(T-273)+32; %tank temperature [F]
    Qtank=mdot/rhoTank %volumetric flow rate on the high side [m^3/s]
        
    SGsol=rho/stdden; %specific gravity of nitrogen on the low side
    qsol=1763*mdotF/sqrt(SGsol);
    pcpsi=pc*1.450377E-4;
    deltaPsol=pc-pe;
    Ysol=1-(deltaPsol/pc)/1.5;
    Cvsol=qsol*sqrt(SGsol*(Tf+460))/(22.67*pcpsi*Ysol*sqrt(deltaPsol/pc));
    
    SGreg=rhoTank/stdden; %specific gravity of nitrogen on the low side
    qreg=1763*mdot/sqrt(SGreg);
    pfpsi=pf*1.450377E-4
    deltaPreg=pf-pc;
    Yreg=1-(deltaPreg/pf)/1.5;
    Cvreg=qreg*sqrt(SGreg*(Tf+460)*Z)/(22.67*pfpsi*Yreg*sqrt(deltaPreg/pf));
    
    Ve=sqrt(2*k/(k-1)*R*T*(1-(pe/pc)^((k-1)/k))); %exhaust velocity [m/s]
    isp=Ve/g; %specific impulse [s]
    F=lambda*mdotF*Ve+(pc-pe)*Ae; %thrust per nozzle [N]
    InertialPart=lambda*mdot*Ve;
    PressurePart=(pc-pe)*Ae; 
    inertthrustratio=InertialPart/F; %part of the thrust which is inertial, these ratios change with altitude
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
    plot(t,p, 'b');
    xlabel('time (s)');
    ylabel('pressure (Pa)');
    
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
    subplot(4,3,8);
    plot(t,mdot, 'r');
    xlabel('time (s)');
    ylabel('mass flow rate (kg/s)');
    
    hold all;
    subplot(4,3,9);
    plot(t,Z, 'c');
    xlabel('time (s)');
    ylabel('compressibility factor');
    
    hold all;
    subplot(4,3,10);
    plot(t,Cvreg, 'r');
    xlabel('time (s)');
    ylabel('Cv regulator');
    
    hold all;
    subplot(4,3,11);
    plot(t,Cvsol, 'b');
    xlabel('time (s)');
    ylabel('Cv solenoid');
end

t
p
T
m
ppsi=p*0.000145037738