function declus(declusParams) %(taumin,taumax,xk,xmeff,P,rfact,err,derr)
    % declus.m                                A.Allmann
    % main decluster algorithm
    % modified version, uses two different circles for already related events
    % works on ZG.newcat
    % different clusters stored with respective numbers in clus
    % Program is based on Raesenberg paper JGR;Vol90;Pages5479-5495;06/10/85
    
    % modified by Celso Reyes, 2017
    
    
    % variables given by inputwindow
    %
    % rfact  is factor for interaction radius for dependent events (default 10)
    % xmeff  is "effective" lower magnitude cutoff for catalog,it is raised
    %         by a factor xk*cmag1 during clusters (default 1.5)
    % xk     is the factor used in xmeff    (default .5)
    % taumin is look ahead time for not clustered events (default one day)
    % taumax is maximum look ahead time for clustered events (default 10 days)
    % P      to be P confident that you are observing the next event in
    %        the sequence (default is 0.95)
    
        
    
    %basic variables used in the program
    %
    % rmain_km  interaction zone for not clustered events
    % r1     interaction zone for clustered events
    % rtest  radius in which the program looks for clusters
    % tau    look ahead time
    % tdiff  time difference between jth event and biggest eq
    % mbg    index of earthquake with biggest magnitude in a cluster
    % k      index of the cluster
    % k1     working index for cluster
    
    %routine works on ZG.newcat
    
    report_this_filefun(mfilename('fullpath'));
    
    % FIXME this apparently can return empty clusters (?)
    
    %declaration of global variables
    %
    global clus 
    global rmain_km % interaction zone for mainshock, km
    global r1   % interaction zone if included in a cluster, km
    global eqtime   %time of all earthquakes catalogs
    global k k1 bg mbg bgevent bgdiff          %indices
    global equi %[OUT]
    global clust 
    global clustnumbers
    global cluslength %[OUT]
   %  global taumin taumax 
    % global xk xmeff P

    ZG=ZmapGlobal.Data;
    
    
    taumin = declusParams.taumin;
    taumax = declusParams.taumax;
    P = declusParams.P;
    xk = declusParams.xk;
    xmeff = declusParams.xmeff;
    rfact = declusParams.rfact;
    err = declusParams.err;
    derr = declusParams.derr;
    
    bg=[];
    k1=[];
    mbg=[];
    bgevent=[];
    equi=[];
    bgdiff=[];
    clust=[];
    clustnumbers=[];
    cluslength=[];
    
    [rmain_km,r1]=interaction_zone(ZG.newcat, rfact);   %calculation of interaction radii

    %calculation of the eq-time relative to 1902
    eqtime=clustime(ZG.newcat);
    
    %variable to store information whether earthquake is already clustered
    clus = zeros(1,ZG.newcat.Count);
    
    k = 0;                                %clusterindex
    
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','Decluster - Percent done');
    drawnow
    
    %for every earthquake in ZG.newcat, main loop
    for i = 1: (ZG.newcat.Count-1)
        
        if rem(i,50)==0
            waitbar(i/(ZG.newcat.Count-1));
        end
        
        % variable needed for distance and timediff
        k1=clus(i);
        
        % attach interaction time
        if k1~=0                %If i is already related with a cluster
            if ZG.newcat.Magnitude(i)>=mbg(k1) %if magnitude of i is biggest in cluster
                mbg(k1)=ZG.newcat.Magnitude(i);    %set biggest magnitude to magnitude of i
                bgevent(k1)=i;                  %index of biggest event is i
                tau=taumin;
            else
                bgdiff=eqtime(i)-eqtime(bgevent(k1));
                tau=funTaucalc(xk,mbg,k1,xmeff,bgdiff,P);
                tau = min(tau,taumax);
                tau = max(tau, taumin);
            end
        else
            tau=taumin;
        end
        
        %extract eqs that fit interation time window
        [tdiff,ac]=timediff(i+1, i, tau, clus, eqtime);
        
        
        if ~isempty(ac)   %if some eqs qualify for further examination
            
            rtest1=r1(i);
            if tau==taumin
                rtest2 = 0;
            else
                rtest2=rmain_km(bgevent(k1));
            end
            
            if k1~=0                       % if i is already related with a cluster
                tm1 = clus(ac) ~= k1;       %eqs with a clustnumber different than i
                if any(tm1)
                    ac=ac(tm1);
                end
                bg_ev_for_dist = bgevent(k1);
            else
                bg_ev_for_dist = i;
            end
            
            %calculate distances from the epicenter of biggest and most recent eq
            [dist1,dist2]=distance2(i,bg_ev_for_dist,ac);
            
            %extract eqs that fit the spatial interaction time
            sl0 = dist1<= rtest1 | dist2<= rtest2;
            
            if any(sl0)    %if some eqs qualify for further examination
                ll=ac(sl0);       %eqs that fit spatial and temporal criterion
                lla=ll(clus(ll)~=0);   %eqs which are already related with a cluster
                llb=ll(clus(ll)==0);   %eqs that are not already in a cluster
                if ~isempty(lla)            %find smallest clustnumber in the case several
                    sl1=min(clus(lla));            %numbers are possible
                    if k1~=0
                        k1= min([sl1,k1]);
                    else
                        k1 = sl1;
                    end
                    if clus(i)==0
                        clus(i)=k1;
                    end
                    %merge all related clusters together in the cluster with the smallest number
                    sl2=lla(clus(lla)~=k1);
                    for j1=[i,sl2]
                        if clus(j1)~=k1
                            sl5=find(clus==clus(j1));
                            tm2=length(sl5);
                            clus(sl5)=k1*ones(1,tm2);
                        end
                    end
                end
                
                if ~k1   %if there was neither an event in the interaction zone nor i, already related to cluster
                    k=k+1;                         %
                    k1=k;
                    clus(i) = k1;
                    mbg(k1) = ZG.newcat.Magnitude(i);
                    bgevent(k1) = i;
                end
                
                if size(llb)>0     %attach clustnumber to events not already related to a cluster
                    clus(llb) = k1*ones(1,length(llb));  %
                end
                
            end                          %if ac
        end                           %if sl0
    end                            %for loop
    
    close(wai);
    
    if ~any(clus)
        ZmapMessageCenter.set_info('Alert','No Cluster found')
        return
    else
        [cluslength,bgevent,mbg,bg,clustnumbers] = funBuildclu(ZG.newcat,bgevent,clus,mbg);%builds a matrix clust that stored clusters
        equi=equevent(ZG.newcat, clus);               % calculates equivalent events
        if isempty(equi)
            disp('No clusters in the catalog with this input parameters');
            return;
        end
        
        juggle_catalogs(clus)
        
        zmap_update_displays();
        hold on
        pl=plot(mainmap('axes'),ZG.cluscat.Longitude, ZG.cluscat.Latitude,'mo', 'DisplayName','Clustered Events');
        pl.ZData=ZG.cluscat.Depth;
        
        st1 = sprintf([' The declustering found %d clusters of earthquakes, a total of %d'...
            ' events (out of %d). The map window now display the declustered catalog containing %d events.'...
            'The individual clusters are displayed as magenta on the  map.' ] ...
            , bgevent.Count, ZG.cluscat.Count, ZG.original.Count , ZG.primeCatalog.Count);

        msgbox(st1,'Declustering Information')
        
        
        maybe_analyse_clusters(); % depends on user input
        
        watchoff
        
    end
    

end

function juggle_catalogs(clus)
    ZG = ZmapGlobal.Data;
    ZG.primeCatalog=buildcat('interactive');  % create new catalog for main program
    ZG.original=ZG.newcat;       %save ZG.newcat in variable original
    ZG.newcat=ZG.primeCatalog;
    ZG.storedcat=ZG.original;
    ZG.cluscat=ZG.original.subset(clus(clus~=0));
end
    
function tf = maybe_analyse_clusters()
    % analyse_clusters ask user whether clusters should be analyzed
        tf = questdlg('                                                           ',...
            'Analyse clusters? ',...
            'Yes please','No thank you','No thank you' );
        
        switch tf
            case 'Yes please'
                plotclust()
            case 'No thank you'
                disp('Keep on going ...');
        end
end
