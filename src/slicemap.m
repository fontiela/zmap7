function slicemap() 
    % SLICEMAP plot multiple horizontal slices through a 3D data cube
    %
    % see also SLICEMAPZ
    
    % turned into function by Celso G Reyes 2017
    
    report_this_filefun();
    ZG=ZmapGlobal.Data;
    globalCatalog = ZG.primeCatalog;
    
    global pli gz
    
    if ~exist('zv2', 'var') %TODO figure out zvg, zv2's global status for bgrid3dB, myslicer, slicemap, slicemapZ, zgrid3d
        zv2= zvg ;
    end
    
    minzvg=min(zvg(:)); % was min(min(:)))
    maxzvg=max(zvg(:));
    if ~exist('fix1', 'var') || isempty(fix1)
        fix1 = minzvg;
        fix2 = maxzvg;
    end
    my_new()
    
    function my_new()
        % create the interactive figure
        % incoming values: minzvg, maxzvg, gx, gy, gz
        global bvalsum3 magsteps_desc
        fix1 = minzvg;
        fix2 = maxzvg;
        
        R = nan;
        
        if mean(gz) < 0
            gz = -gz;
        end
        ds = min(gz);
        
        l = ram > R; %TOFIZX R is always nan
        zvg(l)=nan;
        
        %y = get(pli,'Ydata');
        gx2 = linspace(min(gx),max(gx),80);
        gy2 = linspace(min(gy),max(gy),80);
        gz2 = linspace(min(gz),max(gz),10);
        
        [X,Y,Z] = meshgrid(gy,gx,gz);
        [X2,Y2] = meshgrid(gx2,gy2);
        Z2 = (X2*0 + ds);
        
        
        slfig = figure_w_normalized_uicontrolunits('pos', [80 50 900 650]);
        hs=axes(slfig,'pos',[0.1 0.15 0.4 0.7]);
        hold(hs,'on');
        
        sliceh = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        pcolor(X2,Y2,sliceh);
        shading flat
        
        %axis image
        
        box(hs,'on');
        shading flat;
        hold(hs,'on')
        axis([min(gx) max(gx) min(gy) max(gy) ]);
        
        hold(hs,'on');
        error('call to overlay_, but maybe is not same as zmap_update_displays();');
        %zmap_update_displays();
        
        
        caxis([fix1 fix2]);
        colormap(jet);
        
        set(hs,'TickDir','out','Ticklength',[0.02 0.02],'Fontweight','bold','Tag','hs');
        h5 = colorbar('horz');
        hsp = get(hs,'pos');
        set(h5,'pos',[0.15 hsp(2)-0.1 0.3 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');
        ti = title(['Depth: ' num2str(ds,3) ' km'],'Fontweight','bold');
        
        uicontrol('Units','normal',...
            'Position',[.90 .95 .04 .04],'String','Slicer',...
            'callback',@callbackfun_slicer)
        
        uicontrol('Units','normal',...
            'Position',[.96 .90 .04 .04],'String',' V1',...
            'Callback',@(~,~)callbackfun_vX('samp1'));
        uicontrol('Units','normal',...
            'Position',[.96 .85 .04 .04],'String',' V2',...
            'Callback',@(~,~)callbackfun_vX('samp2'));
        uicontrol('Units','normal',...
            'Position',[.0 .95 .15 .04],'String',' Define X-section',...
            'callback',@callbackfun_define_xsection)
        
        labelList={'hsv','hot','jet','cool','pink','gray','bone','invjet'};
        labelPos = [0.9 0.00 0.10 0.05];
        uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'String',labelList,...
            'Value',3,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'Tag','colormapchoices',...
            'callback',@setcolormap_callback);
        
        labelList={'b-value Map',...
            'Mc Map',...
            'Goodness of fit Map',...
            'Resolution Map',...
            'a-value Map',...
            'recurrence time map'};
        labelPos = [0. 0.0 0.30 0.05];
        
        hndl3=uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'Value',1,...
            'String',labelList,...
            'TooltipString','Choose a map type', ...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'callback',@callbackfun_newtype);
        
        ed1 =  uicontrol('units','norm',...
            'BackgroundColor',[0 0 0], ...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.08 hsp(2)-0.11 0.06 0.035], ...
            'String',num2str((fix1),2) , ...
            'TooltipString','Change colorbar range - minimum value', ...
            'Style','edit',...
            'Callback', @callbackfun_climmin) ;
        
        ed2 =  uicontrol('BackgroundColor',[0 0 0], ...
            'units','norm',...
            'ForegroundColor',[0.7 0.9 0], ...
            'FontSize',10, ...
            'FontWeight','demi', ...
            'Position',[0.48 hsp(2)-0.11 0.06 0.035], ...
            'String',num2str((fix2),2) , ...
            'TooltipString','Change colorbar range - maximum value ', ...
            'Style','edit',...
            'Callback', @callbackfun_climmax);
        
        sl1 = uicontrol('units','norm',...
            'BackgroundColor',[0.7 0.7 0.70], ...
            'ListboxTop',0, ...
            'callback',@callbackfun_newdep, ...
            'Max',max(abs(gz)),'Min',0, ...
            'Position',[0.15 0.92 0.35 0.03], ...
            'SliderStep',[0.05 0.15], ...
            'Style','slider', ...
            'Tag','Slider1', ...
            'TooltipString','Move the slider to select the z-value map depth');
        
        ax3 = axes(...
            'Units','norm', ...
            'Box','on', ...
            'Position',[0.6 0.6 0.3 0.3], ...
            'Tag','Axes1', ...
            'TickDir','out', ...
            'TickDirMode','manual','Tag','ax3');
        
        set(gca,'NextPlot','add')
        x = mean(gx); y = mean(gy) ; z = ds;
        l=globalcatalog.hypocentralDistanceTo(x,y,z); %km
        
        [s,is] = sort(l);
        ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
        ZG.newt2 = ZG.newt2(1:ni,:);
        ZG.newt2.sort('Date');
        di = sort(l); Rjma = di(ni);
        
        plot(ZG.newt2.Date,(1:ZG.newt2.Count),'m-','LineWidth',2.0,'Tag','tiplo2')
        set(gca,'YLim',[0 ni+15],'Xlim',[ floor(min(globalcatalog.Date)) ceil(max(globalcatalog.Date))]);
        set(gca,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);
        
        xlabel('Time [yrs]');
        ylabel('Cumul. Number');
        
        % Plot the events on map in yellow
        axes(findobj(groot,'Tag','hs'))
        set(gca,'NextPlot','add')
        %plev =   plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'.k','MarkerSize',4)
        xc1 = plot(mean(gx),mean(gy),'m^','MarkerSize',10,'LineWidth',1.5);
        set(xc1,'Markeredgecolor','w','Markerfacecolor','g','Tag','xc1')
        set(xc1,'ButtonDownFcn',@(~,~)anseiswa('start1',ds));
        % plot circle containing events as circle
        xx = -pi-0.1:0.1:pi;
        plot(x+sin(xx)*Rjma/(cosd(y)*111), y+cos(xx)*Rjma/(cosd(y)*111),'k','Tag','plc1')
        
        
        
        ax4 = axes(...
            'Units','norm', ...
            'Box','on', ...
            'Position',[0.6 0.15 0.3 0.3], ...
            'Tag','Axes1', ...
            'TickDir','out', ...
            'TickDirMode','manual');
        
        bv = bvalca3(ZG.newt2.Magnitude,McAutoEstimate.auto);
        
        plb =semilogy(magsteps_desc,bvalsum3,'sb');
        set(plb,'LineWidth',1.0,'MarkerSize',4,...
            'MarkerFaceColor','g','MarkerEdgeColor','g','Tag','plb');
        text(0.6,0.8,[ 'b-value: ' num2str(bv,3)],'units','norm','color','m',...
            'Tag','teb2');
        
        
        axes(ax3)
        set(gca,'NextPlot','add')
        x = mean(gx)+std(gx)/2; y = mean(gy)+std(gy)/2 ; z = ds;
        
        l=globalcatalog.hypocentralDistanceTo(x,y,z,'kilometer'); %km
        [s,is] = sort(l);
        ZG.newt2 = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
        ZG.newt2 = ZG.newt2(1:ni,:);
        ZG.newt2.sort('Date');
        di = sort(l); Rjma = di(ni);
        
        plot(ZG.newt2.Date,(1:ZG.newt2.Count),'c-','LineWidth',2.0,'tag','tiplo1')
        set(gca,'YLim',[0 ni+15],'Xlim',[ floor(min(globalcatalog.Date)) ceil(max(globalcatalog.Date))]);
        set(gca,'YTick',[ 0 ni/4 ni/2 ni*3/4 ni]);
        
        xlabel('Magnitude');
        ylabel('Cumul. Number');
        
        
        % Plot the events on map in yellow
        axes(findobj(groot,'Tag','hs'))
        set(gca,'NextPlot','add')
        xc2 = plot(mean(gx)+std(gx)/2,mean(gy)+std(gx)/2,'ch','MarkerSize',12,'LineWidth',1.0);
        set(xc2,'Markeredgecolor','w','Markerfacecolor','r','Tag','xc2')
        set(xc2,'ButtonDownFcn',@(~,~)anseiswa('start2',ds));
        set(gcbf,'WindowButtonMotionFcn','')
        set(gcbf,'WindowButtonUpFcn','')
        % plot circle containing events as circle
        xx = -pi-0.1:0.1:pi;
        plot(x+sin(xx)*Rjma/(cosd(y)*111), y+cos(xx)*Rjma/(cosd(y)*111),'k','Tag','plc2')
        
        axes(ax4);
        set(gca,'NextPlot','add')
        
        bv = bvalca3(ZG.newt2.Magnitude,McAutoEstimate.auto);
        
        semilogy(magsteps_desc,bvalsum3,'^b','LineWidth',1.0,'MarkerSize',4,...
            'MarkerFaceColor','r','MarkerEdgeColor','r','Tag','plb2');
        text(0.6,0.9,[ 'b-value: ' num2str(bv,3)],'units','norm','color','c',...
            'Tag','teb1');
        
        whitebg(gcf);
        
        helpdlg('You can drag the square and star to display new subvolumes. To display a different depth layer, use the slider')
    end
    
    function my_newslice()
        nlammap();
        prev = 'ver';
        try
            x = get(pli,'Xdata');
        catch ME
            warning(ME);
            errordlg(' Please Define a X-section first! ');
            return;
        end
        y = get(pli,'Ydata');
        gx2c = linspace(x(1),x(2),50);
        gy2c = linspace(y(1),y(2),50);
        gz2c = linspace(min(gz),max(gz),50);
        
        dic = distance(gy2c(1),gx2c(1),gy2c(50),gx2c(50))*111;
        dic = 0:dic/49:dic;
        
        [Y2c,Z2c] = meshgrid(gy2c,gz2c);
        X2c = repmat(gx2c,50,1);
        
        [Xc,Yc,Zc] = meshgrid(gy,gx,gz);
        
        figure_w_normalized_uicontrolunits('visible','off');
        set(gca,'NextPlot','add');
        sl2 = slice(Xc,Yc,Zc,zvg,Y2c,X2c,Z2c);
        valueMap = get(sl2,'Cdata');
        close(gcf)
        figure
        axes('pos',[0.15 0.15 0.6 0.6]);
        pcolor(dic,-gz2c,valueMap);
        shading flat
        if prev == "hor"
            set(sliceh,'tag','slice');
        end
        box on
        lat1 = y(1); lat2 = y(2);lon1 = x(1); lon2 = x(2);
        di = deg2km(distance(lat1,lon1,lat2,lon2));
        
        if ~exist('ZG.xsec_defaults.WidthKm', 'var'); ZG.xsec_defaults.WidthKm = 10; end
        [Ax, Ay, inde] = mysectnoplo(globalcatalog.Latitude',globalcatalog.Longitude',globalcatalog.Depth,ZG.xsec_defaults.WidthKm,0,lat1,lat2,lon1,lon2);
        set(gca,'NextPlot','add')
        %figure
        plot(di-Ax,-Ay,'.k','Markersize',1);
        
        shading flat
        caxis([fix1 fix2]);
        axis image
        hsc = gca;
        set(gca,'Xaxislocation','top');
        set(gca,'TickDir','out','Ticklength',[0.02 0.02],'Fontweight','bold');
        xlabel('Distance [km]');
        ylabel('Depth [km]');
        
        
        h5 = colorbar('horz');
        hsp = get(hsc,'pos');
        set(h5,'pos',[0.35 hsp(2)-0.05 0.25 0.02],'Tickdir','out','Ticklength',[0.02 0.02],'Fontweight','bold');
        
        whitebg(gcf,[0 0 0]);
        set(gca,'FontSize',10,'FontWeight','bold')
        set(gcf,'Color','k','InvertHardcopy','off')
        slax = gca;
        setcolormap_callback(findobj('Tag','colormapchoices'));
        
    end
    
    function my_newclim(fix1, fix2)
        % change the colormap scale (AND draw colorbar!?)
        axes(findobj(groot,'Tag','hs'));
        caxis([fix1 fix2]);
        h5 = colorbar('horiz');
        set(h5,'pos',[0.15 hsp(2)-0.1 0.3 0.02],...
            'Tickdir','out','Ticklength',[0.02 0.02],...
            'Fontweight','bold');
    end
    
    
    %% callbacks
    function callbackfun_slicer(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        myslicer();
    end
    
    function callbackfun_vX(whichsamp)
        anseiswa(whichsamp,ds);
        ZG=ZmapGlobal; 
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
    end
    
    function callbackfun_define_xsection(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        animator('start', @my_newslice);
    end
    
    function setcolormap_callback(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cmapname = mysrc.String{mysrc.Value};
        mycolormap = colormap(cmapname);
        if cmapname == "jet"
            flipud(mycolormap);
        end
        colormap(mycolormap);
    end
    
    function callbackfun_newtype(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in3 = mysrc.Value;
        switch in3
            case 1
                zvg = bvg;
            case 2
                zvg = mcma;
            case 3
                zvg = go;
            case 4
                zvg = ram;
            case 5
                zvg = avm;
            case 6
                def = {'6'};
                m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
                m1 = m{:};
                m = str2double(m1);
                zvg =(teb - t0b)./(10.^(avm-m*bvg));
        end
        
        chil = allchild(findobj(groot,'Tag','hs'));
        Z2 = (X2*0 + ds);
        sliceh = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        set(chil(length(chil)),'Cdata',sliceh);
        fix1 = minzvg;
        fix2 = maxzvg;
        ed1.String = num2str(fix1,3);
        ed2.String = num2str(fix2,3);
        
        my_newclim(fix1, fix2)
    end
    
    function callbackfun_climmin(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fix1 =  str2double(mysrc.String); % colorbar min
        my_newclim(fix1, fix2)
    end
    
    function callbackfun_climmax(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fix2 = str2double(mysrc.String); %colorbar max
        my_newclim(fix1, fix2)
    end
    
    function callbackfun_newdep(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ds = min(mysrc.Value);
        if ds < min(abs(gz))
            ds = min(abs(gz));
        end
        chil = allchild(findobj(groot,'Tag','hs'));
        Z2 = (X2*0 + ds);
        sliceh = interp3(X,Y,Z,zvg,Y2,X2,Z2);
        set(chil(length(chil)),'Cdata',sliceh); %FIXME I seriously doubt this is written as intended
        set(ti,'string',['Depth: ' num2str(ds,3) ' km']);
        anseiswa('tipl2',ds)
        anseiswa('tipl',ds)
    end
    
end

function [xsecx,xsecy, inde] = mysectnoplo(eqlat,eqlon,depth,width,length,...
        lat1,lon1,lat2,lon2)
% mysectnoplo mysect noplot
% [probably] based off of LC_XSECTION [LC_xsect]

    report_this_filefun();
    
    
    %TODO untangle the global situation, incoming parameters cannot match globals directly. -CGR
    global  torad
    global sine_phi0 lambda0  sw eq1
    global maxlatg minlatg maxlong minlong
    global eq0p
    todeg = 180 / pi;
    eq1 =[];
    
    
    if nargin == 8	% method 2: given lat & lon of center point and angle
        
    elseif nargin == 9	% method 1: given lat & lon of the two end points
        %figure(mapl);
        [x1, y1] = lc_tocart(lat1,lon1);
        [x2, y2] = lc_tocart(lat2,lon2);
        
        if x1 > x2
            xtemp = x1; ytemp = y1;
            x1 = x2; y1 = y2;
            x2 = xtemp; y2 = ytemp;
            sw = 'on';
        else
            sw = 'of';
        end
        
        x0 = (x1 + x2) / 2;
        y0 = (y1 + y2) / 2;
        [lat0, lon0] = lc_froca(x0,y0);
        dx = x2 - x1;
        dy = y2 - y1;
        
        alpha = 90 - (atan(dy/dx)*todeg);
        length = sqrt(dx^2 + dy^2);
        
    else
        
        disp('ERROR: incompatible number of arguments')
        help LC_XSECTION
        return
        
    end
    
    % correction factor to correct for longitude away from the center meridian
    theta0 = ((lon0*torad - lambda0) * sine_phi0) * todeg;
    
    % correct the XY azimuth of the Xsection line with the above factor to obtain
    % the true azimuth
    azimuth = alpha + theta0;
    if azimuth < 0, azimuth = azimuth + 180; end
    
    % convert XY coordinate azimuth to a normal angle like we used to deal with
    sigma = 90 - alpha;
    
    % transformation matrix to rotate the data coordinate w.r.t the Xsection line
    transf = [cos(sigma*torad) sin(sigma*torad)
        -sin(sigma*torad) cos(sigma*torad)];
    
    % inverse transformation matrix to rotate the data coordinate back
    invtransf = [cos(-sigma*torad) sin(-sigma*torad)
        -sin(-sigma*torad) cos(-sigma*torad)];
    
    % convert the map coordinate of the events to cartesian coordinates
    idx_map = find(minlatg < eqlat & eqlat < maxlatg & ...
        minlong < eqlon & eqlon < maxlong);
    [eq(1,:) eq(2,:)] = lc_tocart(eqlat,eqlon);
    % create new coordinate system at center of Xsection line
    eq0(1,:) = eq(1,:) - x0;
    eq0(2,:) = eq(2,:) - y0;
    
    % rotate this last coordinate system so that X-axis correspond to Xsection line
    eq0p = transf * eq0;
    % project the event data to the Xsection line
    eq1(1,:) = eq0p(1,:);
    eq1(2,:) = eq0p(2,:) ;
    
    % convert back to the original coordinate system
    eq1p = invtransf * eq1;
    eq2(1,:) = eq1p(1,:) + x0;
    eq2(2,:) = eq1p(2,:) + y0;
    
    % find index of all events which are within the given box width
    idx_box = find(abs(eq0p(2,:)) <= width/2 & abs(eq0p(1,:)) <= length/2);
    inde = idx_box;
    
    
    % Plot events on cross section figure
    xdist = eq1(1,idx_box) + (length / 2);
    %eq1(1,:) = eq1(1,:) + (length / 2);
    
    global Xwbz Ywbz
    Xwbz = xdist;
    Ywbz = depth(idx_box);
    
    xsecx = xdist;
    xsecy = depth(idx_box);
end
