function plorem(onesigma, aw, bw) % autogenerated function wrapper
    % plorem Estimate recurrence time/probability
    % works on ZG.newt2
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun(mfilename('fullpath'));
    deltaT=max(ZG.newt2.Date) - min(ZG.newt2.Date); %teb - t0b
    magRange = max(ZG.newt2.Magnitude) -1 : 0.1 : max(ZG.newt2.Magnitude) + 2;
    
    %set onesigma to 0 if not defined
    if isempty(onesigma)
        onesigma=0;
    end
        
    % FIXME the next line probably shouldn't be needed... where bw coming from?
    bw = abs(bw); % added by Celso because bw was passed as negative, which makes no sense to equation... numbers were ridiculous
    
    all_tr =   deltaT ./ 10.^ (aw - bw  .* magRange);
    
    tr2=[all_tr(:) magRange(:)];
    
    %plot recurrence interval
    fig=figure('Name',[ZG.newt2.Name, ': Recurrence Interval']);
    ax=axes(fig);
    % pl =  plot(ax,years(tr2(:,2)), years(tr2(:,1)),'k','LineWidth',2.0);
    pl =  plot(ax,magRange, years(all_tr),'k','LineWidth',2.0);
    hold on
    grid
    set(ax,'Yscale','log');
    
    set(ax,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2,'Ticklength',[0.02 0.02])
    
    ylabel(ax,'Recurrence Time [yrs] ')
    xlabel(ax,'Magnitude ')
    set(fig,'color','w');
    set(ax,'color','w');
    
    
    
    % plot annual probablity
    fig=figure('Name',[ZG.newt2.Name, ': Annual Probablity']);
    ax=axes(fig);
    pl =  plot(ax,magRange,1./years(all_tr),'k');
    set(pl,'LineWidth',2.0)
    hold on
    grid
    set(ax,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.,'Ticklength',[0.02 0.02])
    xlabel(ax,'Magnitude ')
    set(ax,'Yscale','log');
    ylabel(ax,'Annual Probability ')
    
    set(fig,'color','w');set(ax,'color','w');
    
end
