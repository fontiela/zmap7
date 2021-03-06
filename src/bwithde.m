function bwithde(mycat) 
    % bwithde b-value with depth
    % bwithde(catalog)
    % turned into function by Celso G Reyes 2017

    report_this_filefun();
    myFigName='b-value with depth';
    bv2 = [];
    bv3 = [];
    mag = [];
    me = [];
    av2=[];
    [~,~,ni]=smart_inputdlg('Input',struct('prompt','Number of events in each window?','value',150));
    mycat.sort('Depth')
    watchon;
    
    for tt = 1:ni/4:length(mycat)-ni
        % calculate b-value based an weighted LS
        [~, bv, stan, av ] =  bvalca2(mycat.subset(tt:tt+ni));
        bv2 = [bv2 ; bv mycat.Magnitude(tt) ; bv mycat.Magnitude(tt+ni) ; inf inf];
        bv3 = [bv3 ; bv mycat.Magnitude(tt+round(ni/2)) stan ];
        mag = [mag ; av mycat.Magnitude(tt+round(ni/2))];
        
        % calculate b-value based on maximum likelihood
        % THIS is what the following calc_bmemag was actually returning... av = mean(mycat(tt:tt+ni,:));
        [bv stan av] = calc_bmemag(mycat.Magnitude(tt:tt+ni), 0.1);
        av2 = [av2 ;   av  mycat.Magnitude(t+round(ni/2)) stan bv];
        
        
    end
    
    watchoff
    
    bdep=findobj('Type','Figure','-and','Name',myFigName);
    
    % Set up the Cumulative Number window
    
    if isempty(bdep)
        bdep = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','add', ...
            'backingstore','on',...
            'Visible','on', ...
            'Position',position_in_current_monitor(ZG.map_len(1)-50, ZG.map_len(2)-20));
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
            'callback',@(~,~)infoz(1));
        
        
    end
    
    figure(bdep);
    delete(findobj(bdep,'Type','axes'));
    
    axis off
    set(gca,'NextPlot','add')
    orient tall
    %rect = [0.15 0.65 0.7 0.25];
    rect = [0.15 0.65 0.7 0.25];
    axes('position',rect)
    errorbar(bv3(:,2),bv3(:,1),bv3(:,3),bv3(:,3))
    set(gca,'NextPlot','add')
    pl = plot(bv2(:,2),bv2(:,1),'b');
    set(pl,'LineWidth',0.5)
    grid
    %set(gca,'Color',color_bg)
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    
    bax = gca;
    strib = [name ', ni = ' num2str(ni), ', Mmin = ' num2str(min(mycat.Magnitude)) ];
    set(gca,'XTickLabels',[])
    ylabel('b(LS)')
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.l,...
        'Color','k')
    
    xl = get(gca,'Xlim');
    
    
    
    rect = [0.15 0.40 0.7 0.25];
    axes('position',rect)
    
    errorbar(av2(:,2),av2(:,4),av2(:,3))
    set(gca,'NextPlot','add')
    grid
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    
    set(gca,'Xlim',xl)
    xlabel('depth')
    ylabel('b based on mean')
    axes(bax)
    
    
end
