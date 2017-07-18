% Script: plot_constnrbootfitF
% Selects constant number of earthquakes around a grid node  in learning period and calculates the forecast
% by using calc_bootfitF.m
%
% Jochen Woessner
% last update: 24.07.03

report_this_filefun(mfilename('fullpath'));
try
    delete(plos1)
catch
    disp(' ');
end

axes(h1)
%zoom off

titStr ='Selecting EQ in Circles                         ';
messtext= ...
    ['                                                '
    '  Please use the LEFT mouse button              '
    ' to select the center point.                    '
    ' The "ni" events nearest to this point          '
    ' will be selected and displayed in the map.     '];

zmap_message_center.set_message(titStr,messtext);

% Input center of circle with mouse
%
[xa0,ya0]  = ginput(1);

stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
stri = stri1;
pause(0.1)

%  Calculate distance for each earthquake from center point
%  and sort by distance l
l = sqrt(((ZG.a.Longitude-xa0)*cosd(ya0)*111).^2 + ((ZG.a.Latitude-ya0)*111).^2) ;
[s,is] = sort(l);
ZG.newt2 = a(is(:,1),:) ;

l =  sort(l);

% Select events in learning time period
vSel = (ZG.newt2.Date <= ZG.maepi.Date(1)+days(time));
newt2_learn = ZG.newt2.subset(vSel);
vSel2 = (ZG.newt2.Date > ZG.maepi.Date(1)+days(time) & ZG.newt2.Date <= ZG.maepi.Date(1)+(time+timef)/365);
newt2_forecast = ZG.newt2(vSel2,:);

% Distance from grid node for learning period and forecast period
vDist = sort(l(vSel));
vDist_forecast = sort(l(vSel2));

% Select constant number
newt2_learn = newt2_learn(1:ni,:);
% Maximum distance of events in learning period
fMaxDist = vDist(ni);

if fMaxDist <= fMaxRadius
    vSel3 = vDist_forecast <= fMaxDist;
    newt2_forecast = newt2_forecast(vSel3,:);
    ZG.newt2 = [newt2_learn; newt2_forecast];
else
    vSel4 = (l < fMaxRadius & ZG.newt2.Date <= ZG.maepi.Date(1)+days(time));
    ZG.newt2 = ZG.newt2(vSel4,:);
    newt2_learn = ZG.newt2;
    fMaxDist = fMaxRadius;
end

length(newt2_learn)
length(newt2_forecast)

messtext = ['Radius of selected Circle:' num2str(l(ni))  ' km' ];
disp(messtext)
zmap_message_center.set_message('Message',messtext)
% Sort by time
[st,ist] = sort(ZG.newt2);
ZG.newt2 = ZG.newt2(ist(:,3),:);

% Set limiting radius to plot
R2 = fMaxDist;

% Check for maximum radius
l2 = sort(l);
fMaxDist = l2(ni);
% Check for maximum radius
if fMaxDist > fMaxRadius
    sWarnstr = ['Maximum radius exceeded to obtain ', num2str(ni) , ' events'];
    hWarn = warndlg(sWarnstr,'Check number of events')
end % End if on rd


% Plot selected earthquakes
hold on
plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','normal');

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
pl = plot(xa0+sin(x)*R2/(cosd(ya0)*111), ya0+cos(x)*R2/(cosd(ya0)*111),'k','era','normal')

% Compute and Plot the forecast
calc_bootfitF(ZG.newt2,time,timef,bootloops,ZG.maepi)

set(gcf,'Pointer','arrow')
%
newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2

% Call program "timeplot to plot cumulative number
clear l s is
timeplot(ZG.newt2)
