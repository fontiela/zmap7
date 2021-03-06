function aux_1FMD(params, hParentFigure)
% function aux_1FMD(params, hParentFigure);
%-------------------------------------------
% Plots FMD of the grid node catalog, entire time period
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 19.08.02


% Get the axes handle of the plotwindow
axes(sv_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok');

% Get closest gridnode for the chosen point on the map
[fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY)
plot(fXGridNode, fYGridNode, '*r');
hold off;

% Get the data for the grid node
mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);

if params.nGriddingMode == 1
    vDistances_ = sqrt(((mNodeCatalog_(:,1)-fXGridNode)*cos(pi/180*fYGridNode)*111).^2 + ((mNodeCatalog_(:,2)-fYGridNode)*111).^2);
    vSel = (vDistances_ <= params.fRadius);
    fCheckDist = max(vDistances_(vSel, :));
    mNodeCatalog_=mNodeCatalog_(vSel,:);
end
% Time period
params.fTimePeriod = params.fTimePeriod/365;

% Create the frequency magnitude distribution vectors for the two time periods
[vFMD, vNonCFMD] = calc_FMD(mNodeCatalog_);

if exist('new_fig','var') &  ishandle(new_fig)
    set(0,'Currentfigure',new_fig);
    disp('Figure exists');
else
    new_fig=figure_w_normalized_uicontrolunits('tag','bnew','Name','Cumulative FMD and b-value fit','Units','normalized','Nextplot','add','Numbertitle','off');
    new_axs=axes('tag','ax_bnew','Nextplot','add','box','on');
end
set(gca,'tag','ax_bnew','Nextplot','replace','box','on');
axs5=findobj('tag','ax_bnew');
axes(axs5(1));
semilogy(vFMD(1,:), vFMD(2,:),'ks');
hold on;
semilogy(vNonCFMD(1,:), vNonCFMD(2,:),'k^');

% Calculate magnitude of completeness
fMcNorm = params.mValueGrid(nNodeGridPoint,5);
fMc = fMcNorm; %calc_Mc(mNodeCatalog_, 5);
params.mValueGrid(nNodeGridPoint,:)
% First period
[nIndexLo, fMagHi, vSel, vMagnitudes] = fMagToFitBValue(mNodeCatalog_, vFMD, fMc);
% Calculate the b-value etc. for M > Mc
[fMeanMag, fBValue, fStdDev, fAValue] =  calc_bmemag(mNodeCatalog_(vSel,:),0.1);
% Plot the 'x'-marker
sColor = 'b';
hPlot = semilogy(vFMD(1,nIndexLo), vFMD(2,nIndexLo), ['x' sColor]);
set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12);
hPlot = semilogy(vFMD(1,1), vFMD(2,1), ['x' sColor]);
set(hPlot, 'LineWidth', [2.5], 'MarkerSize', 12)

% Plot the line representing the b-value
vPoly = [-1*fBValue fAValue];
fBFunc = 10.^(polyval(vPoly, vMagnitudes));
hPlot = semilogy(vMagnitudes, fBFunc, sColor);
set(hPlot, 'LineWidth', [2.0]);
txtInfoString = ['a: ' num2str(fAValue) ', b: ' num2str(fBValue) ', std: ' num2str(fStdDev)];
text(0.1, 1.1, txtInfoString, 'Color', [0 0 1]);
% Set x-limits
set(gca,'Xlim',[min(mNodeCatalog_(:,6))-1 max(mNodeCatalog_(:,6))]);
% Plot labels
xlabel('Magnitude');
ylabel('Cumulative sum per grid node');
if params.nGriddingMode == 1
    sTitleString = ['o: ' num2str(min(mNodeCatalog_(:,3))) ' - ' num2str(max(mNodeCatalog_(:,3)))...
            ' Max. Radius: ' num2str(fCheckDist)];
else
    sTitleString = ['o: ' num2str(min(mNodeCatalog_(:,3))) ' - ' num2str(max(mNodeCatalog_(:,3)))];
end

title(sTitleString);
hold off;

% Calculate Goodness-of-fit above Mc
[fPerMcMean, fResMean] = calc_FitTest(mNodeCatalog_,params.mValueGrid(nNodeGridPoint,7),params.mValueGrid(nNodeGridPoint,9),params.fBinning)
[fPerMc, fRes] = calc_FitTest(mNodeCatalog_,params.mValueGrid(nNodeGridPoint,5),fBValue,params.fBinning)

%[fMc, fMLE, mRes] = calc_Mclike(mNodeCatalog_, params.fBinning);
[mResult1, fMLE1, fMc1, fMu1, fSigma1, mDatPredBest1, vPredBest1, fBvalue1, fAvalue1] = calc_McCdfnormal(mNodeCatalog_, params.fBinning);
% lognormal
[mResult2, fMLE2, fMc2, fMu2, fSigma2, mDatPredBest2, vPredBest2] = calc_McCdflognormal(mNodeCatalog_, params.fBinning);

fMLE1
fMLE2
