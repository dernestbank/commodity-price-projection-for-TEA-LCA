% session 2
% The below script codes the grid search for optimal hyper-parameters. 
% Three hyper-parameters, i.e. number of hidden units (HU), number of epochs (E), and initial learning rate (LR), are optimised. 
% The models are trained to minimise the mean squared error (MSE) between the projections and training data.
% Each combination of hyper-parameters is assessed based on the ensemble’s performance against the validation set. 
% The ensemble is evaluated based on the Continuous Rank Probability Score (CRPS) between the predicted and historical prices within the validation set. 



% % Model training - grid search for optimal hyper-parameters      
 
% Grid search: Hidden units (HU), epochs (E) and initial learn rate (LR)
% The initial values are based on results from the previously projected commodities
HU = [1,2,3];                       %1-500
E = [200,300,500];                  %100-1000
LR = [0.1,0.01,0.001];              %0.1-0.0000001  
            
% Setting up network           
for i = 1:size(HU,2)
    for j = 1:size(E,2)
        for k = 1:size(LR,2)
 
            Ypreds = [];
            for p=1:100
 
                h = randperm(HU(i));
                h = h(1);
 
                Ypred2 = [];
                Ypred3 = [];
 
                X2_train_LSTM{1} = [];
                Y2_train_LSTM{1} = [];
                X2_train_LSTM{1} = X2_train';
                Y2_train_LSTM{1} = Y2_train';
                numResponses = 12;
                m = round(val/12);
                c = 1;
                for n = 1:m
                    net = [];
                    layers = [ ...
                        sequenceInputLayer(2)
                        fullyConnectedLayer(2)
                        lstmLayer((h),'OutputMode','sequence')
                        fullyConnectedLayer(numResponses)
                        regressionLayer];
                    options = trainingOptions('adam', ...
                        'GradientThreshold',1, ...
                        'MaxEpochs',E(j), ...
                        'MiniBatchSize',1, ...
                        'InitialLearnRate',LR(k), ...
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
            end
 
            obs = ((X2_val(:,1)')*std_com)+mean_com;
            fcst = (Ypreds*std_com)+mean_com;
            [meanCRPS] = crps(fcst,obs);

% Calculating yearly percentiles of the ensemble projections for the entire data series
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
 
% Positions i,j,k reflect the HU,L2,LR parameters used in the grid search, respectively
            err_c_t = meanCRPS;                    
            err_val_c(i,j,k) = err_c_t;
        end
    end
end

