% S2.3: Model training – using the model for the projection horizon


% The below code runs the final model, producing a plot of the projected percentiles, stores the ensemble of projections in the table ‘Ensemble’, and the annual 5th, 25th, 50th, 75th and 95th price percentiles in the table ‘Percentiles’. 
% These percentiles should be saved externally and used in the techno-economic, sensitivity and uncertainty analyses. 
% As before, the ‘shade’ function from the MATLAB file exchange is used to generate the shaded plots 



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
    X2_train_LSTM{1} = cat(2,X2_train',X2_val');
    Y2_train_LSTM{1} = cat(2,Y2_train',Y2_val');
    numResponses = 12;
    m = round((size(z,1)-a)/12);
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
% The model operates recursively, i.e previously projected values become inputs to the model
         Xpred{1} = cat(2,X2_train_LSTM{1},cat(1,Y2_train_LSTM{1}(:,end)',...
(crude(train+val+c:train+val+c+11))'));
 
% Ypred = network projection based on Xpred                             
         Ypred = predict(net,Xpred);
         X2_train_LSTM{1} = cat(2,X2_train_LSTM{1},...
 cat(1,Xpred{1}(1,end-11:end),...
 (crude(train+val+c:train+val+c+11))'));                             
         Y2_train_LSTM{1} = cat(2,Y2_train_LSTM{1},Ypred{1}(:,end-11:end));
         
         c = c + 12;
    end
 
% Ypred2 = projections on the validation set
% Ypred3 = projections up to the end of the projection horizon
     Ypred2 = X2_train_LSTM{1}(1,train+1:train+val);
     Ypred3 = X2_train_LSTM{1}(1,:);
 
     Ypreds = cat(1,Ypreds,Ypred2);
     Ypreds3 = cat(1,Ypreds3,Ypred3);
end

% Calculating yearly percentiles of the ensemble projections for the entire data series
 t_q = [];
 for q = 1:((size(Ypreds3,2))/12)
     q = q*12;
     T = cat(1,Ypreds3(:,q-11),Ypreds3(:,q-10),Ypreds3(:,q-9),Ypreds3(:,q-8),...
         Ypreds3(:,q-7),Ypreds3(:,q-6),Ypreds3(:,q-5),Ypreds3(:,q-4),...
  Ypreds3(:,q-3),Ypreds3(:,q-2),Ypreds3(:,q-1),Ypreds3(:,q));
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

Percentiles = array2table(((t_q*std_com)+mean_com),'VariableNames',...
    {'5th','25th','50th','75th','95th'});
Ensemble_Projections = (Ypreds3'*std_com)+mean_com;
Date = z;
Ensemble = table(Date,Ensemble_Projections);
 
% Plot historic data
z_p = z(1:q);
x_p = xplot(1:q);
plot(z_p,x_p,'k');
hold on;
 
% Plotting projections
shade(z_p,q1,z_p,q3,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 1 1]);
shade(z_p,q5,z_p,q3,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 1 1]);
shade(z_p,q2,z_p,q3,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 0 0]);
shade(z_p,q3,z_p,q4,'linestyle','none','FillType',[2 1;1 2],'FillColor', [1 0 0;1 0 0],'Color',[1 0 0]);
Coloralpha = 0.1;
plot(z_p,q3,'r','linewidth',1);
plot(z_p,x_p,'k');
 
% Graph formatting
 
% Create dashed line to signify end of historic data
TrainX = [z_p(a+12),z_p(a+12)];
TrainY = [-10,10];
plot(TrainX,TrainY,'--','Color',[0.5 0.5 0.5],'linewidth',1);
 
% Label historic and projected sections of plot
Hist = z_p(round((train+val)/2)-36);
Proj = z_p(((size(z,1)-(train+val))/2)+(train+val)-36);
txt2 = {'Historic','Projected'};
text([Hist Proj],[2.7 2.7],txt2);
 
alpha = 0.25;
ylim([-3,3]);
xlabel('Year');
ylabel('Standardised price ($)'); 
legend({'Historic data'},'Location','south')


