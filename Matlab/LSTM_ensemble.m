
% Column A contains the date corresponding to the start of the historic dataset to the end of the desired projection horizon (e.g., 01/01/2009 to 01/12/2046).
% Column B contains the standardised price data for the commodity being projected (e.g., 01/01/2009-01/12/2020). The remaining cells, where the data is to be projected are empty. 
% Column C contains the standardised historic and EIA’s projected crude oil prices for the desired projection horizon.
% Cell F3 contains the mean of the historic data for the commodity price data. 
% Cell F3 contains the standard deviation of the original historic data for the commodity price data.


% Processing historic data
clc;
clear all;
 
% Select file containing historic data
filename = 'Butane';
A = readtable('Butane.xlsx');
 
% Set x = column containing standardised data
x = xlsread(filename,'B:B');
 
% Set z = column containing dates of historic data and projection horizon
% (i.e 01/01/2008-01/01/2042)
z = table2array(A(:,1));
 
% Set xplot = column containing standardised data
xplot = table2array(A(:,2));
crude = table2array(A(:,3));
 
% Set std_com = cell containing the commodity's standard deviation
% Set mean_com = cell containing the commodity's mean
std_com = xlsread(filename,'F3:F3');
mean_com = xlsread(filename,'E3:E3');
 
X2 = x;
Y2 = [];
 
for a = 1:size(X2,1)-12
    Y2(a,:) = cat(1,x(a+1),x(a+2),x(a+3),x(a+4),x(a+5),x(a+6),x(a+7),...
        x(a+8),x(a+9),x(a+10),x(a+11),x(a+12));
end
 
X2 = X2(1:(size(Y2,1)));
 
% Assign training and validation sets based on horizon length and data availability
free_run = (size(z,1)-size(X2,1))/size(z,1);
val = round(free_run*size(X2,1))+2;
train = round(size(X2,1)-val);
 
X2_train = cat(2,X2(1:train),crude(1:train));
X2_val = cat(2,X2(train+1:val+train),crude(train+1:val+train));
 
Y2_train = Y2(1:train,:);
Y2_val = Y2(train+1:val+train,:);
