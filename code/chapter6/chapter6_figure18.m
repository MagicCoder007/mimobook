%This Matlab script can be used to reproduce Figure 6.18 in the textbook:
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


%Select range of the number of antennas
M = 10;

%Select the angles-of-arrival for the different users
varphi = [-pi/16 -pi/32 0 pi/24];

%Extract the number of users
K = length(varphi);

%Select the range of SNR values
SNRdB = -10:30;
SNR = db2pow(SNRdB);


%Prepare to save simulation results
sumrate_LMMSE = zeros(length(SNR),1);
sumrate_MRC = zeros(length(SNR),1);
sumrate_ZF = zeros(length(SNR),1);


%% Generate rate region with different number of antennas

%Generate array responses with a ULA
H = [exp(-1i*2*pi*(0:M-1)'*sin(varphi(1))/2) exp(-1i*2*pi*(0:M-1)'*sin(varphi(2))/2) exp(-1i*2*pi*(0:M-1)'*sin(varphi(3))/2) exp(-1i*2*pi*(0:M-1)'*sin(varphi(4))/2)];


%Compute the sum rates with different linear processing schemes
for s = 1:length(SNR)
    
    %MRC matrix
    W_MRC = H;
    
    %ZF matrix
    W_ZF = H/(H'*H);
    
    %Compute the sum rates
    for k = 1:K
        
        sumrate_LMMSE(s) = sumrate_LMMSE(s) + log2(1+SNR(s)*real(H(:,k)'*((SNR(s)*(H*H'-H(:,k)*H(:,k)')+eye(M))\H(:,k))));
        
        sumrate_ZF(s) = sumrate_ZF(s) + real(log2(1+SNR(s)*abs(H(:,k)'*W_ZF(:,k))^2/(W_ZF(:,k)'*(SNR(s)*(H*H'-H(:,k)*H(:,k)')+eye(M))*W_ZF(:,k))));
        
        sumrate_MRC(s) = sumrate_MRC(s) + real(log2(1+SNR(s)*abs(H(:,k)'*W_MRC(:,k))^2/(W_MRC(:,k)'*(SNR(s)*(H*H'-H(:,k)*H(:,k)')+eye(M))*W_MRC(:,k))));
        
    end
    
end


%Plot simulation results
set(groot,'defaultAxesTickLabelInterpreter','latex');

figure;
hold on; box on; grid on;
plot(SNRdB,sumrate_LMMSE,'b-','LineWidth',2);
plot(SNRdB,sumrate_ZF,'r-.','LineWidth',2);
plot(SNRdB,sumrate_MRC,'k--','LineWidth',2);
xlabel('SNR [dB]','Interpreter','latex');
ylabel('Sum rate [bit/symbol]','Interpreter','latex');
set(gca,'fontsize',16);
legend({'LMMSE','ZF','MRC'},'Interpreter','latex','Location','NorthWest');
ylim([0 40]);
