y=1.4;%ratio of specific heats
for pcpsi=50%[40:.1:100] ;%Chamber Pressure [Psi]
pc=pcpsi/1.450377E-4%chamber pressure [Pa]
pe=14.7/1.450377E-4;%atmospheric pressure at sea level [Pa]
Me=sqrt(2/(y-1)*((pc/pe)^((y-1)/y)-1))%Mach number at nozzle exit
e=1/Me*sqrt((2/(y+1)*(1+(y-1)/2*Me^2))^((y+1)/(y-1)))%Area ratio Ae/At
hold all
plot(pc,e);
end
