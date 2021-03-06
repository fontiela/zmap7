function recperc() 
    % This is recperc
    % A file to count the number of noder below a certain
    % recurrence time value and divede by the total nu,ber of nodes;
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    % Stefan Wiemer 02/99
    
    report_this_filefun();
    
    l = isnan(re4);
    rt = re4(~isnan(re4));
    le = length(rt); pe = [];
    
    for i = min(rt) : min(rt)/10: min(rt)*10;
        l = rt <= i;
        pe = [pe ; length(rt(l))/le*100 i];
    end
    
    figure
    plot(pe(:,2),pe(:,1));
    set(gca,'NextPlot','add')
    plot(pe(:,2),pe(:,1),'sr');
    set(gca,'pos',[0.2 0.2 0.6 0.6])
    
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'LineWidth',1.2,'Box','on','TickDir','out')
    xlabel('Tr [years]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    ge_sign = char(8805); % >=
    ylabel(['Percentage (T ',ge_sign,' Tr)'],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    ;
    
end
