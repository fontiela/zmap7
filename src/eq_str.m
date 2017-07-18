%earthquake_strike.m
% plot the earthquake number along the strike on the map view
%	August 1995 by Zhong Lu

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('Earthquake Number Map',1);

newWindowFlag=~existFlag;

if newWindowFlag
    mif55 = figure_w_normalized_uicontrolunits( ...
        'Name','Earthquake Number Map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [300 500]) ZmapGlobal.Data.map_len]);

    
    matdraw
    hold on

end
figure_w_normalized_uicontrolunits(mif55)
%delete(gca);delete(gca);
%rect = [0.15,  0.20, 0.75, 0.65];
%axes('position',rect)

hold on

tt = newcat2;
[ts,ti] = sort(tt(:,15));
tt = tt(ti(:,1),:);

for i = 1:length(tt)
    %     pt = text(tt(i,1),tt(i,2),num2str(i));
    pt = plot(tt(i,1),tt(i,2),'o');
    hold on
    %     set(pl,'MarkerSize',mi(i,2)/sc)
end

% xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
% ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
% strib = [  'Earthquake Number Map '];
% title(strib,'FontWeight','bold',...
%              'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
%

% set(gca,'box','on',...
%         'SortMethod','childorder','TickDir','out','FontWeight',...
%         'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
%
% grid

%hold off;

done
