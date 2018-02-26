classdef magrcros < ZmapVGridFunction
    properties
        
    end
    properties(Constant)
        PlotTag='myplot';
        ReturnDetails = { ... TODO update this. it hasn't been really done.
            ... VariableNames, VariableDescriptions, VariableUnits
            'Mc_value', 'Magnitude of Completion (Mc)', '';...
            'Mc_std', 'Std. of Magnitude of Completion', '';...
            'x', 'Longitude', 'deg';...
            'y', 'Latitude', 'deg';...
            'z', 'Depth','km';...
            'dist_along_strike','Distance along strike','km';...
            'Radius_km', 'Radius of chosen events (Resolution) [km]', 'km';...
            'b_value', 'b-value', '';...
            'b_value_std', 'Std. of b-value', '';...
            'a_value', 'a-value', '';...
            'a_value_std', 'Std. of a-value', '';...
            'power_fit', 'Goodness of fit to power-law', '';...
            'max_mag', 'Maximum magnitude at node', 'mag';...
            'Additional_Runs_b_std', 'Additional runs: Std b-value', '';...
            'Additional_Runs_Mc_std', 'Additional runs: Std of Mc', '';...
            'Number_of_Events', 'Number of events in node', ''...
            };
    end
    methods
        function obj=magrcros(zap,varargin)
            obj@ZmapVGridFunction(zap,'z_value');
            
        end
    end % methods
    methods(Static)
        function h=AddMenuItem(parent,zapFcn) %xsec_zap
            % create a menu item
            label='Z-value section map';
            h=uimenu(parent,'Label',label,'Callback', @(~,~)magrcros(zap_Fcn()));
        end
    end % static methods
    
end
function magrcros_orig(sel)
    % MAGRCROS z-value with depth
    %
    % This subroutine assigns creates a grid with
    % spacing dx,dy (in degrees). The size will
    % be selected interactiVELY. The bvalue in each
    % volume around a grid point containing ni earthquakes
    % will be calculated as well as the magnitude
    % of completness
    %   Stefan Wiemer 1/95
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    global maex maey maix maiy
    
    if exist('sel','var')
        switch sel
            case 'lo'
                my_load();
            case 'ca'
                my_calculate();
            case 'in'
                % fall through
            otherwise
                warning ('unexpected selection option');
        end
    end
    
    % get the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
    ra = ZG.ra;
    
    % make the interface
    %
    zdlg = ZmapDialog([]);
    zdlg.AddEventSelectionParameters('evtparams', ni, ra);
    %zdlg.AddGridParameters('gridparams',dx,'km',[],[],dd,'km');
    zdlg.AddBasicEdit('dx_km','Spacing along strike [km]',dx,'spacing in horizontal plane');
    zdlg.AddBasicEdit('dd_km','Spacing in depth [km]',dd,'spacing in vertical plane');
    zdlg.AddBasicEdit('bin_dur','Time steps in days',ZG.bin_dur,'time steps in days');
    [zparam,okPressed]=zdlg.Create('Z-value xsection input parameters');
    if ~okPressed
        return
    end
    dd=zparam.dd_km;
    dx=zparam.dx_km;
    bin_dur = zparam.bin_dur;
    evtsel = zparam.evtparams;
    
    my_calculate();
    %{
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ ZG.wex+200 ZG.wey-200 600 250]);
    axis off
    
    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .10],...
        'Units','normalized','String',num2str(ni),...
        'callback',@callbackfun_001);
    
    
    freq_field0=uicontrol('Style','edit',...
        'Position',[.70 .50 .12 .10],...
        'Units','normalized','String',num2str(ra),...
        'callback',@callbackfun_002);
    
    tgl1 = uicontrol('Style','checkbox',...
        'string','Number of Events:',...
        'Position',[.05 .50 .2 .10], 'callback',@callbackfun_003,...
        'Units','normalized');
    
    set(tgl1,'value',1);
    
    tgl2 =  uicontrol('Style','checkbox',...
        'string','OR: Constant Radius',...
        'Position',[.47 .50 .2 .10], 'callback',@callbackfun_004,...
        'Units','normalized');
    
    
    
    % freq_field=uicontrol('Style','edit',...
    %         'Position',[.60 .50 .22 .10],...
    %        'Units','normalized','String',num2str(ni),...
    %        'callback',@callbackfun_005);
    
    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dd),...
        'callback',@callbackfun_006);
    
    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'callback',@callbackfun_007);
    
    freq_field6B=uicontrol('Style','edit',...
        'Position',[.60 .20 .22 .10],...
        'Units','normalized','String',num2str(days(ZG.bin_dur)),...
        'callback',@callbackfun_008);
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','callback',@callbackfun_cancel,'String','Cancel');
    
    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_go,...
        'String','Go');
    
    text(...
        'Position',[0. 0.20 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time steps in days:');
    
    
    txt3 = text(...
        'Position',[0.30 0.84 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Position',[0. 0.42 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing along strike in km');
    
    txt6 = text(...
        'Position',[0. 0.32 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in depth in km:');
    
    
    set(gcf,'visible','on');
    watchoff
    %}
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % thge seimicity and selectiong the ni neighbors
    % to each grid point
    
    function my_calculate()
        
        figure(xsec_fig());
        hold on
        ax = mainmap('axes');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        
        
        plos2 = plot(x,y,'b-');        % plot outline
        sum3 = 0.;
        pause(0.3)
        
        %create a rectangular grid
        xvect=[min(x):dx:max(x)];
        yvect=[min(y):dd:max(y)];
        gx = xvect;gy = yvect;
        tmpgri=zeros((length(xvect)*length(yvect)),2);
        n=0;
        for i=1:length(xvect)
            for j=1:length(yvect)
                n=n+1;
                tmpgri(n,:)=[xvect(i) yvect(j)];
            end
            
        end
        %extract all gridpoints in chosen polygon
        XI=tmpgri(:,1);
        YI=tmpgri(:,2);
        
        ll = polygon_filter(x,y, XI, YI, 'inside');
        %grid points in polygon
        newgri=tmpgri(ll,:);
        
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k')
        
        if length(xvect) < 2  ||  length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        itotal = length(newgri(:,1));
        
        
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = newa.DateRange() ;
        n = newa.Count;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        cumu = zeros(length(t0b:days(ZG.bin_dur):teb)+2);
        ncu = length(cumu);
        cumuall = nan(ncu,length(newgri(:,1)));
        loc = zeros(3,length(newgri(:,1)));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        bvg = [];
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name',' grid - percent done');
        drawnow
        %
        % longitude  loop
        %
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            % calculate distance from center point and sort wrt distance
            l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
            
            if tgl1 == 0   % take point within r
                l3 = l <= ra;
                b = newa.subset(l3);      % new data per grid point (b) is sorted in distanc
                rd = b.Count;
            else
                % take first ni points
                [s,is] = sort(l);
                b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
                b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); rd = l2(ni);
            end
            if ~isempty(b)
                if b.Count > 4
                    [st,ist] = sort(b);   % re-sort wrt time for cumulative count
                    b = b(ist(:,3),:);
                    cumu = cumu * 0;
                    % time (bin) calculation
                    n = b.Count;
                    cumu = histogram(b(1:n,3),t0b:days(ZG.bin_dur):teb);
                    l = sort(l);
                    cumuall(:,allcount) = [cumu';  x; rd];
                    loc(:,allcount) = [x ; y; rd];
                    waitbar(allcount/itotal)
                end
            end
        end  % for newgr
        
        
        catsave3('magrcros');
        %corrected window positioning error
        close(wai)
        watchoff
        
        % Plot the results
        %
        
        det = 'nop'
        in2 = 'nocal'
        menucros
    end
    
    % Load exist z-grid
    function my_load()
        [file1,path1] = uigetfile(['*.mat'],'z-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            det = 'nop'
            in2 = 'nocal'
            menucros
        else
            return
        end
    end
    

end
