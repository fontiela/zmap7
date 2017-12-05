function [mycat, bigEventCat, bigEventMag] = catalog_overview(mycat, bigEventMag)
    % catalog_overview presents a window where catalog summary statistics show and can be edited
    % mycat should be a ZmapCatalogView
    %
    %  ask for several input parameters that can be set up
    %  at the beginning of each session. The default values are the
    %  extrema in the catalog
    %
    % bigEventMag typically comes from ZG.big_eq_minmag
   
    %ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));
     % mycat=ZG.Views.(mycatview);
    
    %  default values
    
    %if ~exist('ZG.bin_dur', 'var')   %select bin length respective to time in catalog
    %    ZG.bin_dur = days(30);
    %end
    
    big_evt_minmag = ZmapGlobal.Data.big_eq_minmag;
    daterange = mycat.DateRange;
    minti = daterange(1);
    maxti  = daterange(2);
    magrange = mycat.MagnitudeRange;
    minma = magrange(1);
    maxma = magrange(2);
    depthrange= mycat.DepthRange;
    mindep = depthrange(1);
    maxdep = depthrange(2);
    
    fignum = create_dialog();
    
    watchoff
    str = 'Please Select a subset of earthquakes and press "Go"';
    ZmapMessageCenter.set_message('Message',str);
    figure(fignum);
    
    uiwait(fignum)
    
    function fignum = create_dialog()
        % create_dialog - creates the dialog box
        
        %
        % make the interface
        %
        fignum = figure_w_normalized_uicontrolunits(...
            'Units', 'pixels', ...
            'pos',[300 100 300 400 ],...
            'Name',['Catalog "', mycat.Name,'"'],...
            'Menu','none',...
            'Visible','off',...
            'NumberTitle','off',...
            'Tag', main_dialog_figure('tag'),...
            'NextPlot','new');
        axis off
        
        % control display parameters
        label_x = 0.05;
        all_h = 0.17;
        
        
        %catalog name
        uicontrol('Style','text',...
            'Position',[label_x + 0.01 .94 .3 .05],...
            'Units', 'pixels',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            ...'FontWeight','bold' ,...
            'HorizontalAlignment','left',...
            'String','Name:');
        
        uicontrol('Style','edit',...
            'Position',[.4 .94 .5 .05],...
            'Units', 'pixels',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            ...'FontWeight','bold' ,...
            'HorizontalAlignment','center',...
            'Tag', 'catalog_name_field',...
            'String',mycat.Name,...
            'Callback',@callback_update_catalog_name);
        
        % EQ's in catalog
        uicontrol('Style','text',...
            'Position',[label_x + 0.01 .88 .7 .05],...
            'Units', 'pixels',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            ...'FontWeight','bold' ,...
            'HorizontalAlignment','left',...
            'String',' EQs in catalog: ');
        
        uicontrol('Style','text',...
            'Position',[.70 .88 .22 .05],...
            'Units', 'pixels', ...
            'String',num2str(mycat.Count),...
            'Value',mycat.Count,...
            ...'FontWeight','bold',...
            'FontSize', ZmapGlobal.Data.fontsz.m,...
            'Tag','mapview_nquakes_field',...
            'Callback',@upate_numeric);
        
        filter_panel = uipanel('Parent',fignum,'Title','Catalog Parameters',...
            'Position',[.02 .4 .96 .45], 'Units', 'pixels');
        option_panel = uipanel('Parent',fignum,'Title','Additional Parameters',...
            'Position',[.02, .15, .96, .25], 'Units', 'pixels');
        
        % plot big events with M gt
        uicontrol('Parent',option_panel,...
            'Style','text',...
            'Position',[label_x 0.6 .7 .3 ],...
            'Units', 'pixels', ...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            ...'FontWeight','bold' ,...
            'HorizontalAlignment','left',...
            'String','Plot "Big" Events:    M >');
        
        uicontrol('Parent',option_panel,...
            'Style','edit','Position',[.75 .6 .22 .3],...
            'Units', 'pixels', ...
            'String',num2str(big_evt_minmag),...
            'Value',big_evt_minmag,...
            'Tag','mapview_big_evt_field',...
            'Callback',@update_editfield_value);
        
        % TODO: add reset button (would be nice...)
        
        %  beginning year
        uicontrol('Parent',filter_panel,...
            'Style','edit','Position',[.45 0.75 .52 all_h],...
            'Units','pixels',...
            'String',char(minti,'yyyy-MM-dd HH:mm:ss'),...
            'Value', datenum(minti),...
            'HorizontalAlignment','center',...
            'Callback',@update_editfield_date,...
            'Tag','mapview_start_field',...
            'tooltipstring', 'as decimal year or yyyy-mm-dd hh:mm:ss');
        
        uicontrol('Parent',filter_panel,...
            'Style','text',...
            'Position',[label_x 0.75 .395 all_h],...
            'Units', 'pixels', ...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            ...'FontWeight','bold' ,...
            'HorizontalAlignment','left',...
            'String','Beginning date: ');
        
        % ending year
        uicontrol('Parent',filter_panel,...
            'Style','edit','Position',[.45 0.55 .52 all_h],...
            'Units', 'pixels', ...
            'String',char(maxti,'yyyy-MM-dd HH:mm:ss'),...
            'Value', datenum(maxti),...
            'Callback',@update_editfield_date,...
            'Tag','mapview_end_field',...
            'tooltipstring', 'as decimal year or yyyy-mm-dd hh:mm:ss');
        
        
        uicontrol('Parent',filter_panel,...
            'Style','text',...
            'Position',[label_x 0.55 0.4 all_h],...
            'Units', 'pixels', ...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            ...'FontWeight','bold' ,...
            'HorizontalAlignment','left',...
            'String','Ending date: ');
        
        
        % Magnitude
        
        uicontrol('Parent',filter_panel,...
            'Style','text',...
            'Position',[label_x 0.29 0.5 all_h],...
            'Units', 'pixels', ...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            ...'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'String','Magnitude:');
        
        
        uicontrol('Parent',filter_panel,...
            'Style','text',...
            'Position',[0.63 0.29 0.4 all_h],...
            'Units', 'pixels', ...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            ...'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'String','<= M <=');
        
        uicontrol('Parent',filter_panel,...
            'Style','edit',...
            'Position',[.43 .3 .17 all_h],...
            'Units', 'pixels', ...
            'String',num2str(minma),...
            'Value', minma,...
            'Tag','mapview_minmag_field',...
            'Callback',@update_editfield_value);
        
        uicontrol('Parent',filter_panel,...
            'Style','edit','Position',[.80 .3 .17 all_h],...
            'Units', 'pixels', ...
            'String',num2str(maxma),...
            'Value', maxma,...
            'Tag','mapview_maxmag_field',...
            'Callback',@update_editfield_value);
        
        
        % Depth control
        uicontrol('Parent',filter_panel,...
            'Style','text',...
            'Position',[label_x 0.04 0.4 all_h],...
            'Units', 'pixels', ...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            ...'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'String','Depth:');
        
        
        uicontrol('Parent',filter_panel,...
            'Style','text',...
            'Position',[0.5 0.04 0.4 all_h],...
            'Units', 'pixels', ...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            ...'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'String','<= Z (km) <=');
        
        uicontrol('Parent',filter_panel,...
            'Style','edit','Position',[.29 .05 .2 all_h],...
            'Units', 'pixels', ...
            'String',num2str(mindep),...
            'Value', mindep,...
            'Tag','mapview_mindepth_field',...
            'Callback',@update_editfield_value);
        
        uicontrol('Parent',filter_panel,...
            'Style','edit','Position',[.77 .05 .2 all_h],...
            'Units', 'pixels', ...
            'String',num2str(maxdep),...
            'Value', maxdep,...
            'Tag','mapview_maxdepth_field',...
            'Callback',@update_editfield_value);
        
        % buttons
        uicontrol('Style','Pushbutton',...
            'Position',[.79 .02 .20 .10 ],...
            'Units', 'pixels', ...
            'Callback',@cancel_callback,'String','cancel');
        
        uicontrol('Style','Pushbutton',...
            'Position',[.58 .02 .20 .10 ],...
            'Units','pixels',...
            'Callback',@go_callback,...
            'String','Apply');
        
        uicontrol('Style','Pushbutton',...
            'Position',[.05 .02 .35 .10 ],...
            'Units', 'pixels', ...
            'Callback',{@distro_callback, mycat}, ...
            'String','see distributions');
        
        set(gcf,'visible','on')
    end
    
    function go_callback(src, ~)
        %TODO remove all the side-effects.  store relevent data somewhere specific
        %filter the catalog, then return
        disp(mycat)
        ZG = ZmapGlobal.Data;
        myparent=get(src,'Parent');
        
        h = findall(myparent,'Tag','mapview_maxdepth_field');
        maxdep = h.Value;
        h = findall(myparent,'Tag','mapview_minmag_field');
        minma = h.Value;
        h = findall(myparent,'Tag','mapview_maxmag_field');
        maxma = h.Value;
        h = findall(myparent,'Tag','mapview_mindepth_field');
        mindep = h.Value;
        h = findall(myparent,'Tag','mapview_start_field');
        minti = datetime(datevec(h.Value));
        h = findall(myparent,'Tag','mapview_end_field');
        maxti = datetime(datevec(h.Value));
        h = findall(myparent,'Tag','mapview_big_evt_field');
        ZG.big_eq_minmag = h.Value;
        h = findall(myparent,'Tag','catalog_name_field');
        mycat.Name = h.String;
        %h = findall(myparent,'Tag','mapview_binlen_field');
        %ZG.bin_dur = days(h.Value);
        
        % following code originally from sele_sub.m
        %    Create  reduced (in time and magnitude) catalogs "primeCatalog" and "newcat"
        %
        mycat.DepthRange=[mindep, maxdep];
        mycat.DateRange=[minti, maxti];
        mycat.MagnitudeRange=[minma, maxma];
        
        %create catalog of "big events" if not merged with the original one:
        %
        bigEventCat = mycat.subset(mycat.Magnitude > ZG.big_eq_minmag);
        
        %mycat.sort('Date');
        % ZG.Views.(mycatview)=mycat;
        
        % ZmapMessageCenter.update_catalog();
        %zmap_update_displays();
        
        close(main_dialog_figure('handle'));
        disp('changed to...')
        disp(mycat);
        % changes in bin length go to global 
    end
    
function callback_update_catalog_name(src,~)
    disp('in name callback')
    % if field should respond somehow to changes, do it here
end

end

function cancel_callback(~, ~)
    % return without making changes to catalog
    ZmapMessageCenter.update_catalog();
    %h=ZmapMessageCenter();
    %h.update_catalog();
    close(main_dialog_figure('handle'));
end

function distro_callback(src,~,mycat)
    watchon; drawnow;
    dlg = main_dialog_figure('handle');
    if numel(dlg) >1
        warning('multiple dialog windows found')
    end
        
    f = findall(0,'Tag','catoverview_distribution_pane');
    if isempty(f)
        % grow the catalog figure. create plots in the empty portion, change the button behavior
        dlg.Position = dlg.Position + [0 0 450 0];
        src.String = 'hide distributions';
        pp=uipanel('Parent',gcf,'Units','pixels','Position',[310 10 420 370],'Tag','catoverview_distribution_pane','Title','Distributions');
        %f = figure('Name','Catalog time, mag, depth distributions','MenuBar','none','NumberTitle','off','Tag','catoverview_distribution');
        t_p=subplot(3,1,1,'Parent',pp);
        m_p=subplot(3,1,2,'Parent',pp);
        d_p=subplot(3,1,3,'Parent',pp);
        histogram(t_p,mycat.Date);
        xlabel(t_p,'Time');
        histogram(m_p,mycat.Magnitude);
        xlabel(m_p,'Magnitude');
        histogram(d_p,mycat.Depth);
        xlabel(d_p,'Depth');
    else
        delete(findobj('Tag','catoverview_distribution_pane'));
        dlg.Position = dlg.Position - [0 0 450 0];
        
        src.String = 'show distributions';
        % delete the histograms, 
    end
    watchoff; drawnow;
end

%% Tag Name Helpers
function answer = main_dialog_figure(opt)
    % get
    % opt is either 'tag' or 'handle'
    s = 'catalog_overview_dlg';
    switch opt
        case 'tag'
            answer = s;
        case 'handle'
            answer = findobj('Tag', s);
        otherwise
            error('main_dialog_figure:invalid option, must be ''tag'' or ''handle''');
    end
end
    
    
