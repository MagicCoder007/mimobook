%This Matlab script can be used to reproduce Figure 6.15 in the textbook:
%Emil Bjornson and Ozlem Tugfe Demir (2024),
%"Introduction to Multiple Antenna Communications and Reconfigurable Surfaces", 
%Boston-Delft: Now Publishers, http://dx.doi.org/10.1561/9781638283157
%
%This is version 1.0 (Last edited: 2024-01-17)
%
%License: This code is licensed under the GPLv2 license. If you in any way
%use this code for research that results in publications, please cite our
%textbook as described above. You can find the complete code package at
%https://github.com/emilbjornson/mimobook

close all;
clear;

%Select the range of fraction of the power used by the users
fraction = linspace(0,1,1000);
fraction2 = 1-fraction;

%Bandwidth in MHz
B = 10;

%Select range of the number of antennas
Mvalues = [4 8];

%Select angles-of-arrival for the two users
varphi1 = -pi/20;
varphi2 = pi/20;

%Select SNRs of the two users (for M=1 antenna)
SNR1 = 10;
SNR2 = 5;


%% Generate rate region with different number of antennas

for m = 1:length(Mvalues)
    
    %Generate array responses with a ULA
    h1 = exp(-1i*pi*(0:Mvalues(m)-1)'*sin(varphi1));
    h2 = exp(-1i*pi*(0:Mvalues(m)-1)'*sin(varphi2));
    
    
    %Compute rates with linear processing by letting one user transmit at
    %maximum power and vary the power of the other user from zero to
    %maximum power
    rate1_linear = zeros(length(fraction)*2,1);
    rate2_linear = zeros(length(fraction)*2,1);
    
    for n = 1:length(fraction)
        
        rate1_linear(n) = B*log2(1+SNR1*real(h1'*((fraction(n)*SNR2*(h2*h2')+eye(Mvalues(m)))\h1)));
        rate2_linear(n) = B*log2(1+fraction(n)*SNR2*real(h2'*((SNR1*(h1*h1')+eye(Mvalues(m)))\h2)));
        
    end
    
    for n = 1:length(fraction)
        
        rate1_linear(n+length(fraction)) = B*log2(1+fraction2(n)*SNR1*real(h1'*((SNR2*(h2*h2')+eye(Mvalues(m)))\h1)));
        rate2_linear(n+length(fraction)) = B*log2(1+SNR2*real(h2'*((fraction2(n)*SNR1*(h1*h1')+eye(Mvalues(m)))\h2)));
        
    end
    
    rate1_linear_hull = [B*log2(1+SNR1*norm(h1).^2) B*log2(1+SNR1*real(h1'*((SNR2*(h2*h2')+eye(Mvalues(m)))\h1))) 0];
    rate2_linear_hull = [0 B*log2(1+SNR2*real(h2'*((SNR1*(h1*h1')+eye(Mvalues(m)))\h2))) B*log2(1+SNR2*norm(h2).^2)];
    
    
    %Compute points on the Pareto boundary of the rate region
    rate1_nonlinear = [B*log2(1+SNR1*norm(h1)^2) fraction2*B*log2(1+SNR1*norm(h1)^2)+fraction*B*log2(1+SNR1*real(h1'*((SNR2*(h2*h2')+eye(Mvalues(m)))\h1))) 0];
    rate2_nonlinear = [0 fraction2*B*log2(1+SNR2*real(h2'*((SNR1*(h1*h1')+eye(Mvalues(m)))\h2)))+fraction*B*log2(1+SNR2*norm(h2)^2) B*log2(1+SNR2*norm(h2)^2)];
    
    
    
    %Plot simulation results
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    
    figure;
    hold on; box on; grid on;
    plot(rate1_nonlinear,rate2_nonlinear,'k','LineWidth',2);
    plot(rate1_linear,rate2_linear,'b-.','LineWidth',2);
    plot(rate1_linear_hull,rate2_linear_hull,'r:','LineWidth',2);
    fill([0 rate1_nonlinear 0],[0 rate2_nonlinear 0],[252 243 161]/256);
    plot(rate1_nonlinear,rate2_nonlinear,'k','LineWidth',2);
    plot(rate1_linear,rate2_linear,'b-.','LineWidth',2);
    plot(rate1_linear_hull,rate2_linear_hull,'r:','LineWidth',2);
    xlabel('$R_1$ [Mbit/s]','Interpreter','latex');
    ylabel('$R_2$ [Mbit/s]','Interpreter','latex');
    set(gca,'fontsize',13);
    axis([0 70 0 70]);
    legend({'Non-linear','Linear','Linear (convex hull)'},'Interpreter','latex','Location','SouthWest')
    xticks(0:10:70);
    axis square
    max(rate1_linear+rate2_linear)/max(rate1_nonlinear+rate2_nonlinear)
end
