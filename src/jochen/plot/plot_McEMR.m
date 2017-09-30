function [mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = plot_McEMR(mCatalog, fBinning)
% function [mResult, fMls, fMc, fMu, fSigma, mDatPredBest, vPredBest] = plot_McEMR(mCatalog, fBinning);
% -----------------------------------------------------------------------------------------------------
% Same as calc_McCdfnormal with plotting the fitting steps and the final result
%
% Incoming variables:
% mCatalog   : EQ catalog
% fBinning   : Binning interval, usually 0.1
%
% Outgoing variables:
% mResult     : Solution matrix including
%               vProbability: maximum likelihood score
%               vMc         : Mc values
%               vX_res      : mu (of normal CDF), sigma (of normal CDF), residuum, exitflag
%               vNmaxBest   : Number of events in lowest magnitude bin considered complete
%               vABValue    : a and b-value
% fMls       : likelihood score --> best Mc
% fMc        : Best estimated magnitude of completeness
% mDatPredBest   : Matrix of non-cumulative FMD [Prediction, magnitudes, original distribution]
% vPredBest      : Matrix of non-cumulative FMD below Mc [magnitude, prediction, uncertainty of prediction]
%
% J. Woessner: jochen.woessner@sed.ethz.ch
% updated: 29.09.04

% Initialize
vProbability = [];
vMc = [];
vABValue =[];
mFitRes = [];
vX_res = [];
vNCumTmp = [];
mDataPred = [];
vPredBest = [];
vDeltaBest = [];
vX_res = [];
vNmaxBest = [];
mResult=[];
mDatPredBest = [];

% Determine exact time period
fPeriod1 = max(mCatalog.Date) - min(mCatalog.Date);

% Determine max. and min. magnitude
fMaxMag = ceil(10 * max(mCatalog.Magnitude)) / 10;

% Set starting value for Mc loop and LSQ fitting procedure
fMcTry= calc_Mc(mCatalog,1);
fSmu = abs(fMcTry/2);
fSSigma = abs(fMcTry/4);
if (fSmu > 1)
    fSmu = fMcTry/10;
    fSSigma = fMcTry/20;
end
fMcBound = fMcTry;

% Calculate FMD for original catalog
[vFMDorg, vNonCFMDorg] = calc_FMD(mCatalog);
fMinMag = min(vNonCFMDorg(1,:));

%% Shift to positive values
% if fMinMag ~= 0
%     fMcBound = fMcTry-fMinMag;
% end
% Loop over Mc-values
for fMc = fMcBound-0.4:0.1:fMcBound+0.8
    fMc = round(fMc, -1);
    vFMD = vFMDorg;
    vNonCFMD = vNonCFMDorg;
    vNonCFMD = fliplr(vNonCFMD);
    %[nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mCatalog, vFMD, fMc);
    % Select magnitudes to calculate b- anda-value
    vSel = mCatalog.Magnitude > fMc-fBinning/2;
    if sum(vSel) >= 20
        [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog.subset(vSel), fBinning);
        % Normalize to time period
        vFMD(2,:) = vFMD(2,:)./fPeriod1; % ceil taken out
        vNonCFMD(2,:) = vNonCFMD(2,:)./fPeriod1; % ceil removed
        % Compute quantity of earthquakes by power law
        fMaxMagFMD = max(vNonCFMD(1,:));
        fMinMagFMD = min(vNonCFMD(1,:));
        vMstep = [fMinMagFMD:0.1:fMaxMagFMD];
        vNCum = 10.^(fAValue-fBValue.*vMstep); % Cumulative number

        % Compute non-cumulative numbers vN
        fNCumTmp = 10^(fAValue-fBValue*(fMaxMagFMD+0.1));
        vNCumTmp  = [vNCum fNCumTmp ];
        vN = abs(diff(vNCumTmp));

        % Normalize vN
        vN = vN./fPeriod1;
        % Data selection
        % mData = Non-cumulative FMD values from GR-law and original data
        mData = [vN' vNonCFMD'];
        vSel = (mData(:,2) >= fMc);
        mDataTest = mData(~vSel,:);
        mDataTmp = mData.subset(vSel);
%         % Check for zeros in observed data
        vSelCheck = (mDataTest(:,3) == 0);
        mDataTest = mDataTest(~vSelCheck,:);
        % Choices of normalization
        fNmax = mDataTmp(1,3); % Frequency of events in Mc bin
        %fNmax = max(mDataTest(:,3));  % Use maximum frequency of events in bins below Mc
        %fNmax = mDataTest(length(mDataTest(:,1)),3); % Use frequency of events at bin Mc-0.1 -> best fit
        if (~isempty(isempty(fNmax)) &&  ~isnan(fNmax) & fNmax ~= 0 & length(mDataTest(:,1)) > 4)
            mDataTest(:,3) = mDataTest(:,3)/fNmax; % Normalize datavalues for fitting with CDF
            % Move to M=0 to fit with lsq-algorithm
            fMinMagTmp = min(mDataTest(:,2));
            mDataTest(:,2) = mDataTest(:,2)-fMinMagTmp;
            % Curve fitting: Non cumulative part below Mc
            options = optimset;
            %options = optimset('Display','off','Tolfun',1e-7,'TolX',0.0001,'MaxFunEvals', 100000,'MaxIter',10000);
            options = optimset('Display','off','Tolfun',1e-5,'TolX',0.001,'MaxFunEvals', 1000,'MaxIter',1000);
            [vX, resnorm, resid, exitflag, output, lambda, jacobian]=lsqcurvefit(@calc_normalCDF,[fSmu  fSSigma], mDataTest(:,2), mDataTest(:,3),[],[],options);
            mDataTest(:,1) = normcdf(mDataTest(:,2), vX(1), vX(2))*fNmax;
            if (length(mDataTest(:,2)) > length(vX(1,:)))
                %% Confidence interval determination
                % vPred : Predicted values of lognormal function
                % vPred+-delta : 95% confidence level of true values
                [vPred,delta] = nlpredci(@calc_normalCDF,mDataTest(:,2),vX, resid, jacobian);
            else
                vPred = NaN;
                delta = NaN;
            end % END: This section is due for errors produced with datasets less long than amount of parameters in vX
            % Results of fitting procedure
            mFitRes = [mFitRes; vX resnorm exitflag];
            % Move back to original magnitudes
            mDataTest(:,2) = mDataTest(:,2)+fMinMagTmp;
            % Set data together
            mDataTest(:,3) = mDataTest(:,3)*fNmax;
            mDataPred = [mDataTest; mDataTmp];
            % Denormalize to calculate probabilities
            mDataPred(:,1) = round(mDataPred(:,1).*fPeriod1);
            mDataPred(:,3) = mDataPred(:,3).*fPeriod1;
            vProb_ = calc_log10poisspdf2(mDataPred(:,3), mDataPred(:,1)); % Non-cumulative

            % Sum the probabilities
            fProbability = (-1) * sum(vProb_);
            vProbability = [vProbability; fProbability];
            % Move magnitude back
            mDataPred(:,2) = mDataPred(:,2)+fMinMag;
            vMc = [vMc; fMc];
            vABValue = [vABValue; fAValue fBValue];

            % Keep values
            vDeltaBest = [vDeltaBest; delta];
            vX_res = [vX_res; vX resnorm exitflag];
            vNmaxBest = [vNmaxBest; fNmax];

            % Keep best fitting model
            if (fProbability == min(vProbability))
                vDeltaBest = delta;
                vPredBest = [mDataTest(:,2) vPred*fNmax*fPeriod1 delta*fNmax*fPeriod1]; % Gives back uncertainty
                %fMc+fMinMag : Test procedure
                mDatPredBest = [mDataPred];
           end
        else
            %disp('Not enough data');
            % Setting values
            fProbability = NaN;
            fMc = NaN;
            vX(1) = NaN;
            vX(2) = NaN;
            resnorm = NaN;
            exitflag = NaN;
            delta = NaN;
            vPred = [NaN NaN NaN];
            fNmax = NaN;
            fAValue = NaN;
            fBValue = NaN;
            vProbability = [vProbability; fProbability];
            vMc = [vMc; fMc];
            vX_res = [vX_res; vX resnorm exitflag];
%             vDeltaBest = [vDeltaBest; NaN];
%             vPredBest = [vPredBest; NaN NaN NaN];
            vNmaxBest = [vNmaxBest; fNmax];
            vABValue = [vABValue; fAValue fBValue];
        end
    end


    % Clear variables
    vNCumTmp = [];
    mModelDat = [];
    vNCum = [];
    vSel = [];
    mDataTest = [];
    mDataPred = [];
end % END of FOR fMc
% Result matrix
mResult = [mResult; vProbability vMc vX_res vNmaxBest vABValue];

% Find best estimate, excluding the case of mResult all NAN
if  ~isempty(nanmin(mResult))
    if ~isnan(nanmin(mResult(:,1)))
        vSel = find(nanmin(mResult(:,1)) == mResult(:,1));
        fMc = min(mResult(vSel,2));
        fMls = min(mResult(vSel,1));
        fMu = min(mResult(vSel,3));
        fSigma = min(mResult(vSel,4));
        fAvalue = min(mResult(vSel,8));
        fBvalue = min(mResult(vSel,9));
    else
        fMc = NaN;
        fMls = NaN;
        fMu = NaN;
        fSigma = NaN;
        fAvalue = NaN;
        fBvalue = NaN;
    end
else
    fMc = NaN;
    fMls = NaN;
    fMu = NaN;
    fSigma = NaN;
    fAvalue = NaN;
    fBvalue = NaN;
end

try % Try catch block used as mDatPreBest not always calculated
    % Reconstruct vector of magnitudes from model for Period 1
    vMag = [];
    mModelFMD = [round(mDatPredBest(:,1)) mDatPredBest(:,2)];
    vSel = (mModelFMD(:,1) ~= 0); % Remove bins with zero frequency of zero events
    mData = mModelFMD(vSel,:);
    for nCnt=1:length(mData(:,1))
        fM = repmat(mData(nCnt,2),mData(nCnt,1),1);
        vMag = [vMag; fM];
    end
    % Calculate KS-Test
    [bH,fPval,fKsstat] = kstest2(roundn(mCatalog.Magnitude,-1),roundn(vMag,-1),0.05,0)
catch
    bH = NaN;
    fPval = NaN;
    fKsstat = NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot result

% Plot best fitting CDF vs. magnitude
figure_w_normalized_uicontrolunits('tag','best_cdfit','Name','CDF fit','Units','normalized','Nextplot','add',...
                    'Numbertitle','off','visible','on');
p1=plot(mDatPredBest(:,2), mDatPredBest(:,3),'Marker','d','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.4 0.4 0.4],'Markersize',8,'Linewidth',2,'Linestyle','none');
hold on;
p2=plot(mDatPredBest(:,2),mDatPredBest(:,1),'Marker','o','MarkerEdgeColor',[0.25 0.25 0.25],'MarkerFaceColor',[0.75 0.75 0.75],'Markersize',8,'Linewidth',2,'Linestyle','none');
%sTitlestr = ['mu = ' num2str(fMu) ', sigma = ' num2str(fSigma)];
%title(sTitlestr)
p3=plot(vPredBest(:,1),vPredBest(:,2),'-','Color',[0.2 0.2 0.2],'Linewidth',2);
p4=plot(vPredBest(:,1),vPredBest(:,2)+vPredBest(:,3),'--','Color',[0.2 0.2 0.2],'Linewidth',2);
plot(vPredBest(:,1),vPredBest(:,2)-vPredBest(:,3),'--','Color',[0.2 0.2 0.2],'Linewidth',2);
xlabel('Magnitude','FontSize',14,'FontWeight','bold');
ylabel('Number of events','FontSize',14,'FontWeight','bold');
xlim = ([min(mDatPredBest(:,2)) max(mDatPredBest(:,2))]);
ylim = ([0 max(mDatPredBest(:))]);
hl1=legend([p1,p2,p3,p4],'Noncum. FMD','Noncum. model FMD ','Model','Model uncertainty');
set(hl1,'FontWeight','bold','FontSize',12')
set(gca,'visible','on','FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on');
hold off;

% Plot Non-/Cumulative distribution, original and predicted
figure_w_normalized_uicontrolunits('tag','ncumdist','Name','Best model','Units','normalized','Nextplot','add',...
                    'Numbertitle','off','visible','on');
p1 = semilogy(vNonCFMDorg(1,:)', vNonCFMDorg(2,:)', 'Marker','d','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.4 0.4 0.4],'Markersize',8,'Linewidth',2,'Linestyle','none');
hold on;
p2 = semilogy(vFMDorg(1,:)', vFMDorg(2,:)', 'Marker','^','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.75 0.75 0.75],'Markersize',8,'Linewidth',2,'Linestyle','none');
%p2=semilogy(vCFMD(1,:)', vNBest.*fPeriod1, '*',
p3=semilogy(mDatPredBest(:,2),mDatPredBest(:,1),'Marker','o','MarkerEdgeColor',[0.25 0.25 0.25],'MarkerFaceColor',[0.75 0.75 0.75],'Markersize',8,'Linewidth',2,'Linestyle','none');
%fBvalue = mResult(vSel,9)
%fAValue = mResult(vSel,8)
vPoly = [-1*fBvalue fAvalue]
vMagnitudes = [0:0.01:max(mDatPredBest(:,2))];
fBFunc = 10.^(polyval(vPoly, vMagnitudes));
p4 = semilogy(vMagnitudes, fBFunc,'Linewidth',3,'Linestyle','--','Color',[0.4 0.4 0.4])
xlim = ([min(mDatPredBest(:,2)) max(mDatPredBest(:,2))]);
ylim = ([0 100000]);
%sTitlestr = ['Mc = ' num2str(fMc) ' using Normal CDF fitting'];
%title(sTitlestr)
sText1 = ['KS-Test: H = ' num2str(bH)];
sText2 = ['Mc(EMR) = ' num2str(fMc)];
hT1 = text(max(vFMDorg(1,:))-1, max(vFMDorg(2,:))*0.6,sText1);
hT2 = text(max(vFMDorg(1,:))-1, max(vFMDorg(2,:))*0.4,sText2);
set(hT1,'FontSize',12,'FontWeight','bold');
set(hT2,'FontSize',12,'FontWeight','bold');
xlabel('Magnitude','FontSize',14,'FontWeight','bold');
ylabel('Number of events','FontSize',14,'FontWeight','bold');
hl1=legend([p1 p2 p3 p4],'Noncum. FMD','Cum. FMD','Noncum. model FMD','Cum. model FMD');
set(hl1,'FontWeight','bold','FontSize',12')
set(gca,'visible','on','FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on');

%%%% Plotting the likelihood scores
figure
%vSel2 = (vMc >= 0.6 & vMc<= 2);
%vMc = vMc(vSel2);
%vProbability = vProbability(vSel2);
plot(vMc, vProbability,'Marker','s','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor',[0 0 0],'Markersize',10','Linewidth',2,'Color',[0 0 0],'visible','on');%sTitlestr = ['mu = ' num2str(fMu) ', sigma = ' num2str(fSigma)];
hl2=legend('MLE');
set(hl2,'FontWeight','bold','FontSize',12');
xlim = ([min(mDatPredBest(:,2)) max(mDatPredBest(:,2))]);
set(gca,'visible','on','FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on');
xlabel('Magnitude','FontSize',14,'FontWeight','bold');
ylabel('Likelihood','FontSize',14,'FontWeight','bold');

