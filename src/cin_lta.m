function cin_lta() 
    %
    
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    var1 = zeros(1,ncu);
    var2 = zeros(1,ncu);
    lta = zeros(1,ncu);
    maxlta = zeros(1,ncu);
    maxlta = maxlta -5;
    
    cu = [cumuall(1:ti-1,:) ; cumuall(ti+winlen_days+1:len,:)];
    mean1 = mean(cu(:,:));
    mean2 = mean(cumuall(it:it+winlen_days,:));
    it
    
    for i = 1:ncu
        var1(i) = cov(cu(:,i));
    end     % for i
    
    for i = 1:ncu
        var2(i) = cov(cumuall(it:it+winlen_days,i));
    end     % for i
    
    lta = (mean1 - mean2)./(sqrt(var1/(len-winlen_days)+var2/(winlen_days)));
    valueMap = reshape(lta,length(gy),length(gx));
    
    
    
    % define size of the plot etc.
    %
    % set values gretaer ZG.tresh_km = nan
    %
    %[len, ncu] = size(cumuall);
    s = cumuall(len,:);
    r = reshape(s,length(gy),length(gx));
    re4 = valueMap;
    re4(r > ZG.tresh_km) = nan;
    
    figure(tmp);
    clf reset
    rect = [0.10 0.30 0.55 0.50 ];
    rect1 = rect;
    
    % find max and min of data for automatic scaling
    %
    
    
    % plot image
    %
    orient landscape
    axes('position',rect)
    pco1 = pcolor(gx,gy,re4);
    shading interp
    caxis([ZG.minc ZG.maxc]);
    colormap(jet)
    set(gca,'NextPlot','add')
    % plot overlay
    %
    overlay
    
    
    tx2 = text(0.07,0.85 ,['ti=' char(it*ZG.bin_dur+t0b)  ] ,...
        'Units','Norm','FontSize',14,'Color','k','FontWeight','bold');
    
    
    tx = text(0.07,0.95 ,['LTA;' char(ZG.compare_window_dur_v3)] ,...
        'Units','Norm','FontSize',14,'Color','k','FontWeight','bold');
    
    
    has = gca;
    
    
    
end
