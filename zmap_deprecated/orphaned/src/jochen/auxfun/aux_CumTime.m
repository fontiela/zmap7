function aux_SeisMoment(params, hParentFigure)
% function aux_SeisMoment(params, hParentFigure);
%-------------------------------------------
% Plots cum. number of events  versus time
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, jowoe@gps.caltech.edu
% last update: 09.11.05


% Get the axes handle of the plotwindow
axes(sv_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok');

% Get closest gridnode for the chosen point on the map
[fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY);
plot(fXGridNode, fYGridNode, '*r');
hold off;

% Get the data for the grid node
mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);

if (params.nGriddingMode == 1 && params.bMap == 1)
    vDistances_ = sqrt(((mNodeCatalog_(:,1)-fXGridNode)*cos(pi/180*fYGridNode)*111).^2 + ((mNodeCatalog_(:,2)-fYGridNode)*111).^2);
    vSel = (vDistances_ <= params.fRadius);
    fCheckDist = max(vDistances_(vSel, :));
    mNodeCatalog_=mNodeCatalog_(vSel,:);
elseif (params.nGriddingMode == 1 && params.bMap == 0)
    [nRow_, nColumn_] = size(mNodeCatalog_);
    vXSecX_ = mNodeCatalog_(:,nColumn_);  % length along x-section
    vXSecY_ = (-1) * mNodeCatalog_(:,7);
    vDistances_ = sqrt(((vXSecX_ - fXGridNode)).^2 + ((vXSecY_ - fYGridNode)).^2);
    vSel = (vDistances_ <= params.fRadius);
    mNodeCatalog_=mNodeCatalog_(vSel,:);
    fCheckDist = max(vDistances_);
end
% Time period
params.fTimePeriod = params.fTimePeriod/365;

% Sort the catalog according to time
[s,is] = sort(mNodeCatalog_(:,3));
mNodeCatalog_ = mNodeCatalog_(is(:,1),:);

if exist('new_fig','var') &&  ishandle(new_fig)
    set(0,'Currentfigure',new_fig);
    disp('Figure exists');
else
    new_fig=figure_w_normalized_uicontrolunits('tag','bnew','Name','Cumulative FMD and b-value fit','Units','normalized','Nextplot','add','Numbertitle','off');
    new_axs=axes('tag','ax_bnew','Nextplot','add','box','on');
end
set(gca,'tag','ax_bnew','Nextplot','replace','box','on');
axs5=findobj('tag','ax_bnew');
axes(axs5(1));
vTime = mNodeCatalog_(:,3);
vCumNumber = (1:length(vTime));
vCumNumber(length(vTime)) = length(vTime);
plot(vTime,vCumNumber,'k','LineWidth',2);

% Figure refinements
set(gca,'LineWidth',2,'FontSize',12','FontWeight','bold')

xlabel('Time in years ','FontWeight','bold','FontSize',12)
ylabel('Number of events','FontWeight','bold','FontSize',12)
