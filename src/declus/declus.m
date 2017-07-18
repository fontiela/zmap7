function declus%(taumin,taumax,xk,xmeff,P,rfact,err,derr)
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
    % rmain  interaction zone for not clustered events
    % r1     interaction zone for clustered events
    % rtest  radius in which the program looks for clusters
    % tau    look ahead time
    % tdiff  time difference between jth event and biggest eq
    % mbg    index of earthquake with biggest magnitude in a cluster
    % k      index of the cluster
    % k1     working index for cluster
    
    %routine works on ZG.newcat
    
    report_this_filefun(mfilename('fullpath'));
    
    
    
    
    %declaration of global variables
    %
    global  clus rmain r1 eqtime              %catalogs
    global k k1 bg mbg bgevent equi bgdiff          %indices
    global ltn                                      %variable to shorten code
    global clust clustnumbers cluslength
    global faults coastline main mainfault name
    global xmeff xk rfact taumin taumax P
    global err derr ijma 

    ZG=ZmapGlobal.Data;
    
    bg=[];k=[];k1=[];mbg=[];bgevent=[];equi=[];bgdiff=[];clust=[];clustnumbers=[];
    cluslength=[];rmain=[];r1=[];
    
    
    
    [rmain,r1]=interact(1);                     %calculation of interaction radii
    
    limag=find(ZG.newcat.Magnitude >= 6);     % index of earthquakes with magnitude bigger or
    % equal magnitude 6
    if isempty(limag)
        limag=0;
    end
    
    %calculation of the eq-time relative to 1902
    eqtime=clustime();
    
    %variable to store information wether earthquake is already clustered
    clus = zeros(1,ZG.newcat.Count);
    
    k = 0;                                %clusterindex
    
    ltn=ZG.newcat.Count-1;
    
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','Decluster - Percent done');
    drawnow
    
    %for every earthquake in ZG.newcat, main loop
    for i = 1:ltn
        if rem(i,50)==0
            
            waitbar(i/ltn);
            
        end
        % variable needed for distance and timediff
        j=i+1;
        k1=clus(i);
        
        % attach interaction time
        if k1~=0                          %If i is already related with a cluster
            if ZG.newcat.Magnitude(i)>=mbg(k1)          %if magnitude of i is biggest in cluster
                mbg(k1)=ZG.newcat.Magnitude(i);            %set biggest magnitude to magnitude of i
                bgevent(k1)=i;                  %index of biggest event is i
                tau=taumin;
            else
                bgdiff=eqtime(i)-eqtime(bgevent(k1));
                tau=taucalc;
                tau = min(tau,taumax);
                tau = max(tau, taumin);
            end
        else
            tau=taumin;
        end
        
        %extract eqs that fit interation time window
        [tdiff,ac]=timediff(j,i,tau);
        
        
        if size(ac)~=0   %if some eqs qualify for further examination
            
            if k1~=0                       % if i is already related with a cluster
                tm1=find(clus(ac)~=k1);       %eqs with a clustnumber different than i
                if ~isempty(tm1)
                    ac=ac(tm1);
                end
            end
            if tau==taumin
                rtest1=r1(i);
                rtest2=0;
            else
                rtest1=r1(i);
                rtest2=rmain(bgevent(k1));
            end
            
            %calculate distances from the epicenter of biggest and most recent eq
            if k1==0
                [dist1,dist2]=distance2(i,i,ac);
            else
                [dist1,dist2]=distance2(i,bgevent(k1),ac);
            end
            %extract eqs that fit the spatial interaction time
            sl0=find(dist1<= rtest1 | dist2<= rtest2);
            
            if size(sl0)~=0    %if some eqs qualify for further examination
                ll=ac(sl0);       %eqs that fit spatial and temporal criterion
                lla=ll(find(clus(ll)~=0));   %eqs which are already related with a cluster
                llb=ll(find(clus(ll)==0));   %eqs that are not already in a cluster
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
                    sl2=lla(find(clus(lla)~=k1));
                    for j1=[i,sl2]
                        if clus(j1)~=k1
                            sl5=find(clus==clus(j1));
                            tm2=length(sl5);
                            clus(sl5)=k1*ones(1,tm2);
                        end
                    end
                end
                
                if k1==0                    %if there was neither an event in the interaction
                    k=k+1;                         %zone nor i, already related to cluster
                    k1=k;
                    clus(i)=k1;
                    mbg(k1)=ZG.newcat.Magnitude(i);
                    bgevent(k1)=i;
                end
                
                if size(llb)>0                   %attach clustnumber to events not already
                    clus(llb)=k1*ones(1,length(llb));  %related to a cluster
                end
                
            end                          %if ac
        end                           %if sl0
    end                            %for loop
    
    close(wai);
    
    if ~any(clus)
        zmap_message_center.set_info('Alert','No Cluster found')
        return
    else
        [cluslength,bgevent,mbg,bg,clustnumbers] = funBuildclu(ZG.newcat,bgevent,clus,mbg,k1,bg);%builds a matrix clust that stored clusters
        equi=equevent(ZG.newcat, clus);               %calculates equivalent events
        if isempty(equi)
            disp('No clusters in the catalog with this input parameters');
            return;
        end
        
        
        replaceMainCatalog(buildcat(1));        %new catalog for main program
        original=ZG.newcat;       %save ZG.newcat in variable original
        ZG.newcat=ZG.a;
        storedcat=original;
        cluscat=original.subset(clus);
        %[dura,foretime,forepercent]=clusdura(clustnumbers);
        
        update(mainmap())
        hold on
        plot(cluscat.Longitude,cluscat.Latitude,'m+');
        
        
        st1 = [' The declustering found ' num2str(length(bgevent(:,1))) ' clusters of earthquakes, a total of '...
            ' ' num2str(length(cluscat(:,1))) ' events (out of ' num2str(length(original(:,1))) '). '...
            ' The map window now display the declustered catalog containing ' num2str(ZG.a.Count) ' events . The individual clusters are displayed as magenta o in the  map.  ' ];
        
        msgbox(st1,'Declustering Information')
        
        
        ans_ = questdlg('                                                           ',...
            'Analyse clusters? ',...
            'Yes please','No thank you','No' );
        
        switch ans_
            case 'Yes please'
                plotclust
            case 'No thank you'
                
                disp('Keep on going ...');
                
        end
        
        mete =...
            ['  The map window now displays             '
            '  the declusterd catalog!                 '];
        
        watchoff,done;
        
        % Plot the clusters
        %  plotclust
        
        zmap_message_center.set_message('Declustering done!',mete)
    end
    
end
