function bvalmapt(sel) % autogenerated function wrapper
    % This subroutine creates a differential bvalue map
    % for two time periods. The difference in
    % both b and Mc can be displayed.
    %   Stefan Wiemer 1/95
    %   Rev. R.Z. 4/2001
    % turned into function by Celso G Reyes 2017
    
    %TODO refactor out the sel parameter
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    if ~exist('sel','var')
        sel='';
    end
    
    switch sel
        case 'lo'
            my_load();
            return;
        case 'ca'
            my_calculate();
            return;
        otherwise
            %drop through to initialize
    end
    % get the grid parameter
    % initial values
    %
    dx = 1.00; % should it come from ZG?
    dy = 1.00 ; % should it come from ZG?
    ra = 5 ; % should it come from ZG?
    t0b=ZG.t0b;
    teb=ZG.teb;
    
    t1 = t0b;
    t4 = teb;
    t2 = t0b + (teb-t0b)/2;
    t3 = t2+0.01;
    
    dft='uuuu-MM-dd HH:mm:ss';
    def = {char(t1,dft),char(t2,dft),char(t3,dft),char(t4,dft), '50'};
    tit ='differntial b-value map ';
    prompt={'T1 = ', 'T2= ', 'T3 = ', 'T4= ', 'Min # of events in each period?'};
    
    ni2 = inputdlg(prompt,tit,1,def);
    minnu = str2double(ni2{5});
    t4 = datetime(ni2{4});
    t3 = datetime(ni2{3});
    t2 = datetime(ni2{2});
    t1 = datetime(ni2{1});
    
    
    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off',...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ ZG.wex+200 ZG.wey-200 450 250]);
    axis off
    labelList2=['Weighted LS - automatic Mcomp | Weighted LS - no automatic Mcomp '];
    labelPos = [0.2 0.7  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'callback',@callbackfun_001);
    
    
    
    labelList=['Maximum likelihood - automatic Mcomp | Maximum likelihood  - no automatic Mcomp '];
    labelPos = [0.2 0.8  0.6  0.08];
    hndl1=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList,...
        'callback',@callbackfun_002);
    
    
    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(ra),...
        'callback',@callbackfun_003);
    
    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'callback',@callbackfun_004);
    
    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dy),...
        'callback',@callbackfun_005);
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','callback',@callbackfun_006,'String','Cancel');
    
    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_007,...
        'String','Go');
    
    text(...
        'Position',[0.20 1.0 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Automatically estimate magn. of completeness?   ');
    txt3 = text(...
        'Position',[0.30 0.64 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Position',[0. 0.42 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');
    
    txt6 = text(...
        'Position',[0. 0.32 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');
    
    txt1 = text(...
        'Position',[0. 0.53 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'String','Constant Radius in km:');
    set(gcf,'visible','on');
    watchoff
    
    function my_calculate()
        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % thge seimicity and selectiong the radius neighbors
        % to each grid point
        
        try
            close(wai);
        catch ME
            error_handler(ME,@do_nothing);
        end
        selgp
        itotal = length(newgri(:,1));
        
        %  make grid, calculate start- endtime etc.  ...
        %
        t0b = min(ZG.primeCatalog.Date)  ;
        n = ZG.primeCatalog.Count;
        teb = max(ZG.primeCatalog.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        bvg = [];
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','b-value grid - percent done');
        drawnow
        %
        % overall b-value
        [bv, magco, stan, av, me, mer, me2, pr] =  bvalca3(a,ZG.inb1);
        ZG.bo1 = bv; no1 = ZG.primeCatalog.Count;
        magco1 = NaN; magco2 = NaN;
        
        % loop over all points
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);
            y = newgri(i,2);
            allcount = allcount + 1.;
            i2 = i2+1;
            
            % calculate distance from center point and sort wrt distance
            b = ZG.primeCatalog.selectRadius(y,x,ra);
            
            if b.Count >= 2*minnu
                % call the b-value function
                lt =  b.Date >= t1 &  b.Date <t2 ;
                if  sum(lt) >= minnu
                    [bv, magco1, stan, av, me, mer, me2, pr1] =  bvalca3(b.subset(lt),ZG.inb1);
                    ZG.bo1 = bv; no1 = length(b(lt,1));
                    P6b = 10^(av-bv*6.5)/(t2-t1); %%
                    
                else
                    [bv, magco1, stan, av0, me, mer, me2, pr1] =  bvalca3(b,ZG.inb1);
                    av2 = log10(length(b(lt,1))) + bv*magco1;
                    P6b = 10^(av2-bv*5)/(t2-t1);
                    bv = NaN; pr = 50;
                end
                lt = b.Date >= t3 &  b.Date < t4 ;
                if  sum(lt) >= minnu
                    [bv2, magco2, stan, av, me, mer, me2, pr] =  bvalca3(b.subset(lt),ZG.inb1);
                    
                    P6a = 10^(av-bv2*6.5)/(t4-t3);
                    
                    
                else
                    [bv2 magco2 stan av0 me mer me2,  pr] =  bvalca3(b,ZG.inb1);
                    av2 = log10(length(b(lt,1))) + bv2*magco2;
                    P6a = 10^(av2-bv2*5)/(t4-t3);
                    bv2 = NaN; pr = 50;
                end
                
                
                l2 = sort(l);
                b2 = b;
                if ZG.inb2 ==  1
                    l = b.Magnitude >= magco;
                end
                if pr >= 40
                    bvg = [bvg ; bv magco1 x y b.Count bv2 pr av P6a  magco1-magco2  bv-bv2  magco2 P6a/P6b bv2/bv*100-100];
                else
                    bvg = [bvg ; NaN NaN x y NaN NaN NaN NaN NaN  NaN NaN NaN NaN NaN] ;
                end
            else
                bvg = [bvg ; NaN NaN x y NaN NaN NaN  NaN NaN NaN NaN NaN NaN NaN];
            end
            
            waitbar(allcount/itotal)
        end  % for newgr
        
        % save data
        %
        catsave3('bvalmapt');
        
        close(wai)
        watchoff
        
        % plot the results
        % old and valueMap (initially ) is the b-value matrix
        %
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap2(ll)= bvg(:,1);
        bm1=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,5);
        r=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,6);
        bm2=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,2);
        magco1=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,12);
        magco2=reshape(normlap2,length(yvect),length(xvect));
        
        dmag = magco1 - magco2;
        
        normlap2(ll)= bvg(:,7);
        pro=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,8);
        avm=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,9)-bvg(:,7);
        stanm=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,13);
        maxm=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,11);
        db12=reshape(normlap2,length(yvect),length(xvect));
        
        
        normlap2(ll)= bvg(:,14);
        dbperc=reshape(normlap2,length(yvect),length(xvect));
        
        valueMap = db12;
        old = valueMap;
        
        % View the b-value map
        view_bvtmap
        
    end
    
    function my_load()
        %RZ Load existing  diff b-grid
        [file1,path1] = uigetfile(['*.mat'],'Diff b-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            normlap2=nan(length(tmpgri(:,1)),1)
            normlap2(ll)= bvg(:,1);
            bm1=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,5);
            r=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,6);
            bm2=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,2);
            magco1=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,12);
            magco2=reshape(normlap2,length(yvect),length(xvect));
            
            dmag = magco1 - magco2;
            
            normlap2(ll)= bvg(:,7);
            pro=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,8);
            avm=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,9);
            stanm=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,10);
            maxm=reshape(normlap2,length(yvect),length(xvect));
            
            normlap2(ll)= bvg(:,11);
            db12=reshape(normlap2,length(yvect),length(xvect));
            
            valueMap = db12;
            old = valueMap;
            
            view_bvtmap
        else
            return
        end
    end
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb2=hndl2.Value;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb1=hndl1.Value;
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ra=str2double(freq_field.String);
        freq_field.String=num2str(ra);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(freq_field2.String);
        freq_field2.String=num2str(dx);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dy=str2double(freq_field3.String);
        freq_field3.String=num2str(dy);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb1=hndl1.Value;
        ZG.inb2=hndl2.Value;
        close;
        my_calculate();
    end
    
end
