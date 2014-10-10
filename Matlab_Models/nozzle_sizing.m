%Nozzzle expansion ratio calculator
%Constant
y=1.4;                                                 %ratio of specific heats

%Expansion ratio and Mach number at exit as a function of chamber pressure
for pcpsi=[40:.5:500];                                 %Chamber Pressure [Psi]
pc=pcpsi                                               %chamber pressure [Pa]
pe=14.7;                                               %atmospheric pressure at sea level [Pa]
Me=sqrt((2*(pc/pe)^((y-1)/y)-2)/(y-1)); %Mach number at nozzle exit
e=(1/Me)*sqrt(2/(y+1)*(1+(y-1)/2*Me^2))^((y+1)/(y-1)); %Area ratio Ae/At


hold all
subplot(1,2,1);
plot(pc,e, 'b');
xlabel('Chamber Pressure (psia)');
ylabel('Expansion ratio (units)')

hold all
subplot(1,2,2);
plot(pc,Me, 'r');
xlabel('Chamber Pressure (psia)');
ylabel('Mach number (units)')
end
