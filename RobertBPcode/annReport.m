% Robert Brockman II - S00285133
% COMP 502 Spring 2013
% Homework 5
%
% annReport.m - Report object generated when training an ANN.
%
classdef annReport < handle % Objects are passed by reference

    properties
        recordNumber = 0; % Current number of records stored in the report.
        reportingInterval % Epochs per reporting interval
        epochSize = 1; % Number of data points per epoch.
        
        maxRecords; % Maximum number of records the report can store.
        

        trainError % Array stores training error for each record.
        testError % Array stores test error for each record.
        trainAccuracy % Array stores training accuracy for each record.
        classificationAccuracy % Array stores classification accuracy for each record.
       
    end
    
    methods
        function obj=annReport(maxRecords, reportingInterval, epochSize)
            obj.maxRecords = maxRecords;
            obj.reportingInterval = reportingInterval;
            obj.epochSize = epochSize;
           
            obj.trainError = zeros(maxRecords,1);
            obj.testError = zeros(maxRecords,1);
            obj.trainAccuracy = zeros(maxRecords,1);
            obj.classificationAccuracy = zeros(maxRecords,1);
        end
        
        function addRecord(obj,trainError,testError,trainAccuracy,classificationAccuracy)
            obj.recordNumber = obj.recordNumber +1;
            
            disp('Epoch:');
            disp(obj.recordNumber*obj.reportingInterval);
            
            disp('Train RMS Error:');
            disp(trainError);
                       
            disp('Test RMS Error:');
            disp(testError);
            
            disp('Training Accuracy:');
            disp(trainAccuracy);            
            
            disp('Test Accuracy:');
            disp(classificationAccuracy);
                          
            obj.trainError(obj.recordNumber) = trainError;
            obj.testError(obj.recordNumber) = testError;
            obj.trainAccuracy(obj.recordNumber) = trainAccuracy;
            obj.classificationAccuracy(obj.recordNumber) = classificationAccuracy;
                         
        end
        
        
        function plotSampleError(obj,outputfile,plotTitle)
            figure(1);
            % Note that the epoch number scale starts at the first
            % reporting period.
            plot(obj.reportingInterval:obj.reportingInterval:obj.recordNumber*obj.reportingInterval,obj.trainError(1:obj.recordNumber),'-k',...
            obj.reportingInterval:obj.reportingInterval:obj.recordNumber*obj.reportingInterval,obj.testError(1:obj.recordNumber),'-r');
            xlabel(['Epoch Number (Epoch size = ' int2str(obj.epochSize) ', m = ' int2str(obj.reportingInterval) ' epochs)']);
            xlim([obj.reportingInterval obj.recordNumber*obj.reportingInterval]);
            ylabel('Average RMS Error Over Data Set');
            legend('Training Data Set','Testing Data Set');
            title(['RMS Errors for ' plotTitle ' for Testing and Training Data Sets']);
            set(gcf,'color','w');
            export_fig(outputfile,1);

            disp('Final Epoch:');
            disp(obj.recordNumber*obj.reportingInterval);
        end
        
        function plotClassificationError(obj,outputfile,plotTitle)
            figure(2);
            % Note that the epoch number scale starts at the first
            % reporting period.
            semilogx(obj.reportingInterval:obj.reportingInterval:obj.recordNumber*obj.reportingInterval,obj.trainAccuracy(1:obj.recordNumber),'-k',...
            obj.reportingInterval:obj.reportingInterval:obj.recordNumber*obj.reportingInterval,obj.classificationAccuracy(1:obj.recordNumber),'-r');
            xlabel(['Epoch Number (Epoch size = ' int2str(obj.epochSize) ', m = ' int2str(obj.reportingInterval) ' epochs)']);
            xlim([obj.reportingInterval,obj.recordNumber*obj.reportingInterval]);
            ylabel('Classification Accuracy Over Data Set');
            legend('Training Data Set','Testing Data Set','Location','SouthWest');
            title(['Classification Accuracy for ' plotTitle ' for Testing and Training Data Sets']);
            set(gcf,'color','w');
            export_fig(outputfile,2);
        end      
    end
    
end

