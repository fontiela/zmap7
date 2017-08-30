function translating(value2trans) % autogenerated function wrapper
    % translating
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    if isempty(ZG.newcat)
        ZG.newcat=a;
    end
    
    % call
    uiwait(dlboxb2p);               % way is now 'unif' or 'real'
    if cancquest=='yes'; return; end; clear cancquest;
    
    % call
    uiwait(beta2prob_dlbox1);       % NuRep is now defined
    if cancquest=='yes'; return; end; clear cancquest;
    NuRep=str2double(NuRep);
    
    BinLength=1/length(xt);
    NuBins=length(xt);
    
    % produce Big Catalog
    if way=='unif'
        BigCatalog=sort(rand(100000,1));
    else % if way=='real'
        whichs=ceil(ZG.newcat.Count*rand(100000,1));
        BigCatalog(100000,1)=0;
        for i=1:100000
            BigCatalog(i,1)=ZG.newcat.Date(whichs(i));    % ith element of BigCatalog is random out of ZG.newcat
        end
        BigCatalog=sort(BigCatalog);
        BigCatalog=(BigCatalog-min(BigCatalog))/(max(BigCatalog)-min(BigCatalog));
    end
    
    % call
    sim_2prob(value2trans);
    
    switch value2trans
    case 'zval'
        ProbValuesZ=[];
        for i=1:length(as)
            ProbValuesZ(1,i)=normcdf(as(1,i), IsFitted(2,1), IsFitted(2,2));
        end
        
    case 'beta'
        ProbValuesBeta=[];
        for i=1:length(BetaValues)
            ProbValuesBeta(1,i)=normcdf(BetaValues(1,i), IsFitted(1,1), IsFitted(1,2));
        end
    otherwise
        error('unknown value to translate')
    end
    
end
