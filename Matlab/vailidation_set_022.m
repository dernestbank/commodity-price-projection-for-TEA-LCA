

% 2.2 Model training – validation set using optimal hyper-parameters
% The optimal hyper-parameters, determined during the grid search, inform the HU, E and LR values utilised in the below script. 
% Running the following script will give rise to the CRPS between the real and predicted values based on the unseen validation set, producing a plot representing the predictions overlaid onto the historic data. 
% The ‘shade’ function from the MATLAB file exchange is used to generate the shaded plots (Tordera, 2018).


% Running validation set - use of optimal hyper-parameters
 
% HU, L2, LR selected from grid search
HU = [1];                   
EP = [500];   
LR = [0.1];
 
Ypreds = [];
Ypreds3 = [];
 
% Setting up network           
for p=1:100
    
    h = randperm(HU);
    h = h(1);
    
    Ypred2 = [];
    Ypred3 = [];
 
    X2_train_LSTM{1} = [];
    Y2_train_LSTM{1} = [];
    X2_train_LSTM{1} = cat(2,X2_train');
    Y2_train_LSTM{1} = cat(2,Y2_train');
    numResponses = 12;
    m = round(val/12)+1;
    c = 1;
    for n = 1:m
        net = [];
        layers = [ ...
            sequenceInputLayer(2)
            fullyConnectedLayer(2)
            lstmLayer(h,'OutputMode','sequence')
            fullyConnectedLayer(numResponses)
            regressionLayer];
        options = trainingOptions('adam', ...
            'GradientThreshold',1, ...
            'MaxEpochs',EP, ...
            'MiniBatchSize',1, ...
            'InitialLearnRate',LR, ...
            'Shuffle','every-epoch');
        net = trainNetwork(X2_train_LSTM,Y2_train_LSTM,layers,options);

% Initialise real values
% Xpred = values to be predicted by the network
% The model operates recursively, i.e. previously projected values become inputs to the model
                     Xpred{1} = cat(2,X2_train_LSTM{1},...
                                cat(1,Y2_train_LSTM{1}(:,end)',...
     (crude(train+c:train+c+11))'));
 
% Ypred = network projection based on Xpred                             
                     Ypred = predict(net,Xpred);
                     X2_train_LSTM{1} = cat(2,X2_train_LSTM{1},...
cat(1,Xpred{1}(1,end-11:end),...
(crude(train+c:train+c+11))'));                             
                     Y2_train_LSTM{1} = cat(2,Y2_train_LSTM{1},...
Ypred{1}(:,end-11:end));
 
                     c = c + 12;
                end
 
 
% Ypred2 = projections on the validation set
% Ypred3 = projections up to the end of the projection horizon
     Ypred2 = X2_train_LSTM{1}(1,train+1:train+val);
     Ypred3 = X2_train_LSTM{1}(1,:);
 
     Ypreds = cat(1,Ypreds,Ypred2);
     Ypreds3 = cat(1,Ypreds3,Ypred3);
end
 
obs = ((X2_val(:,1)')*std_com)+mean_com;
fcst = (Ypreds*std_com)+mean_com;
[meanCRPS] = crps(fcst,obs);
  
% Calculating yearly percentiles of the ensemble projections for the validation set
             y_q =[];
             for q = 1:((size(Ypreds,2))/12)
                 q = q*12;
                 Y = cat(1,Ypreds(:,q-11),Ypreds(:,q-10),Ypreds(:,q-9),...
                     Ypreds(:,q-8),Ypreds(:,q-7),Ypreds(:,q-6),...
                     Ypreds(:,q-5),Ypreds(:,q-4),Ypreds(:,q-3),...
                     Ypreds(:,q-2),Ypreds(:,q-1),Ypreds(:,q));
                 YQ = quantile(Y,[0.05 0.25 0.50 0.75 0.95]);
                 YQ_12=repmat(YQ,12,1);
                 y_q = cat(1,y_q,YQ_12);
             end

% Calculating yearly percentiles of the ensemble projections for the entire data series
 t_q =[];
 for q = 1:((size(Ypreds3,2))/12)
     q = q*12;
     T = cat(1,Ypreds3(:,q-11),Ypreds3(:,q-10),Ypreds3(:,q-9),...
         Ypreds3(:,q-8),Ypreds3(:,q-7),Ypreds3(:,q-6),...
         Ypreds3(:,q-5),Ypreds3(:,q-4),Ypreds3(:,q-3),...
         Ypreds3(:,q-2),Ypreds3(:,q-1),Ypreds3(:,q));
     TQ = quantile(T,[0.05 0.25 0.50 0.75 0.95]);
     TQ_12=repmat(TQ,12,1);
     t_q = cat(1,t_q,TQ_12);
 end
 

% Assign q1, q2, q3, q4, and q5 to predicted percentiles
q1 = double(t_q(:,1));
q2 = double(t_q(:,2));
q3 = double(t_q(:,3));
q4 = double(t_q(:,4));
q5 = double(t_q(:,5));
 
 
% Plot historic data
zplot = z(1:size(q1,1));
xplot = xplot(1:size(q1,1));
plot(zplot,xplot,'k');
hold on;
 
% Plotting projections
shade(zplot,q1,zplot,q3,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 1 1]);
shade(zplot,q5,zplot,q3,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 1 1]);
shade(zplot,q2,zplot,q3,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 0 0]);
shade(zplot,q3,zplot,q4,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 0 0]);
Coloralpha = 0.1;
plot(zplot,q3,'r','linewidth',1);
plot(zplot,xplot,'k');
 
% Graph formatting
 
% Create dashed line to signify end of historic data
TrainX = [z(train),z(train)];
TrainY = [-10,10];
plot(TrainX,TrainY,'--','Color',[0.5 0.5 0.5],'linewidth',1);
 
% Label historic and projected sections of plot
Train = z(round(train/4));
Val = z(round(val/2)+(train));
txt2 = {'Training','Validation'};
text([Train Val],[2.7 2.7],txt2);

alpha = 0.25;
ylim([-3,3]);
xlabel('Year');
ylabel('Standardised price ($)'); 
legend({'Historic data'},'Location','south')




