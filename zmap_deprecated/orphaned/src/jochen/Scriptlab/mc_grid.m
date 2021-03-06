% Scrip: mcgrid.m
% Calculates Magnitude shift map for two specific time periods
% Uses view_mcgrid to plot the results
%
% J. Woessner
% last update: 22.01.04

report_this_filefun(mfilename('fullpath'));


global no1 bo1 inb1 inb2 valeg valeg2 CO valm1

valeg = 1;
valm1 = min(a.Magnitude);
prf = NaN;
if sel == 'in'
    % Set the grid parameter
    %Initial values
    dx = 1;
    dy = 1;
    ni = 150;
    Nmin = 150;
    ra = 50;
    fMaxRadius = 5;
    fSplitTime = 2000.4;

    % cut catalog at mainshock time:
%     l = a.Date > maepi(1,3);
%     a = a.subset(l);

    % cat at selecte magnitude threshold
    l = a.Magnitude < valm1;
    a(l,:) = [];
    newt2 = a;

    ho2=true;
    timeplot
    ho2=false;


    %The definitions in the following line were present in the initial bvalgrid.m file.
    %stan2 = NaN; stan = NaN; prf = NaN; av = NaN;

    % make the interface
    % creates a dialog box to input grid parameters
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 650 250]);
    axis off
%     labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature) | Constant Mc'];
%     labelPos = [0.2 0.8  0.6  0.08];
%     hndl2=uicontrol(...
%         'Style','popup',...
%         'Position',labelPos,...
%         'Units','normalized',...
%         'String',labelList2,...
%         'Callback','inb2 =get(hndl2,''Value''); ');
%
%     set(hndl2,'value',5);


    % creates a dialog box to input grid parameters
    %

    oldfig_button = uicontrol('BackGroundColor',[.60 .92 .84], ...
        'Style','checkbox','string','Plot in Current Figure',...
        'Position',[.78 .7 .20 .08],...
        'Units','normalized');

    set(oldfig_button,'value',1);


    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .60 .12 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .08],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .12 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .080],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    freq_field4=uicontrol('Style','edit',...
        'Position',[.6 .30 .12 .080],...
        'Units','normalized','String',num2str(fSplitTime),...
        'Callback','fSplitTime=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(fSplitTime));');

    freq_field7=uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .080],...
        'Units','normalized','String',num2str(Nmin),...
        'Callback','Nmin=str2double(get(freq_field7,''String'')); set(freq_field7,''String'',num2str(Nmin));');

    freq_field8=uicontrol('Style','edit',...
        'Position',[.6 .60 .12 .080],...
        'Units','normalized','String',num2str(fMaxRadius),...
        'Callback','fMaxRadius=str2double(get(freq_field8,''String'')); set(freq_field8,''String'',num2str(fMaxRadius));');

    tgl1 = uicontrol('Style','radiobutton',...
        'string','Number of Events:',...
        'Position',[.05 .60 .2 .0800], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    set(tgl1,'value',0);

    tgl2 =  uicontrol('Style','radiobutton',...
        'string','OR: Constant Radius',...
        'Position',[.05 .50 .2 .080], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');
    set(tgl2,'value',1);

    create_grid =  uicontrol('Style','radiobutton',...
        'string','Calculate a new grid', 'Callback','set(load_grid,''value'',0), set(prev_grid,''value'',0)','Position',[.78 .55 .2 .080],...
        'Units','normalized');

    set(create_grid,'value',1);

    prev_grid =  uicontrol('Style','radiobutton',...
        'string','Reuse the previous grid', 'Callback','set(load_grid,''value'',0),set(create_grid,''value'',0)','Position',[.78 .45 .2 .080],...
        'Units','normalized');


    load_grid =  uicontrol('Style','radiobutton',...
        'string','Load a previously saved grid', 'Callback','set(prev_grid,''value'',0),set(create_grid,''value'',0)','Position',[.78 .35 .2 .080],...
        'Units','normalized');

    save_grid =  uicontrol('Style','checkbox',...
        'string','Save selected grid to file',...
        'Position',[.78 .22 .2 .080],...
        'Units','normalized');



    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');prev_grid = get(prev_grid,''Value'');create_grid = get(create_grid,''Value''); load_grid = get(load_grid,''Value''); save_grid = get(save_grid,''Value''); oldfig_button = get(oldfig_button,''Value''); close,sel =''ca'', mc_grid',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.10 0.98 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose an Mc estimation option   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.75 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.3 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.18 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. No. of events > Mc:');

    txt9 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.28 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Time window:');

    txt11 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.62 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Max. Radius /[km]:');

    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'



    %In the following line, the program .m is called, which creates a rectangular grid from which then selects,
    %on the basis of the vector ll, the points within the selected poligon.

    % get new grid if needed
    if load_grid == 1
        [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
        if length(path1) > 1
            think
            load([path1 file1])
        end
        plot(newgri(:,1),newgri(:,2),'k+')
    elseif load_grid ==0  &&  prev_grid == 0
        selgp
        if length(gx) < 2  ||  length(gy) < 2
            errordlg('Selection too small! (Dx and Dy are in degreees! ');
            return
        end
    elseif prev_grid == 1
        plot(newgri(:,1),newgri(:,2),'k+')
    end
    %   end

    gll = ll;

    if save_grid == 1

        sFile = ['*.mat'];
        sPath = pwd;
        [file1,path1] = uiputfile([sFile], 'Grid File Name?');
        sSaveFile = [path1 file1];
        save(sSaveFile, 'newgri', 'dx', 'dy', 'gx', 'gy', 'xvect', 'yvect', 'tmpgri', 'll', 'fSplitTime', 'Nmin', 'ra', 'a');
    end

    %   selgp
    itotal = length(newgri(:,1));
%     if length(gx) < 4 | length(gy) < 4
%         errordlg('Selection too small! (Dx and Dy are in degreees! ');
%         return
%     end

    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(a.Date)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i1 = 0.;
    mRes =[];
    mResult = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','Rate change grid - percent done');
    drawnow

    % loop over all points
    for i= 1:length(newgri(:,1))
        i/length(newgri(:,1));
        % Grid node point
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;


        % calculate distance from center point and sort with distance
        l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
        [s,is] = sort(l);
        mCat = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
        % Use Radius to determine grid node catalogs
        l3 = l <= ra;
        mCat = a.subset(l3);      % new data per grid point (mCat) is sorted in distance


        %         % Select earthquakes in non-overlapping rectangles
        %         vSel = (a.Longitude >= (newgri(i,1)-dx/2)) & (a.Longitude < (newgri(i,1)+dx/2)) &...
        %             (a.Latitude >= (newgri(i,2)-dy/2)) & (a.Latitude < (newgri(i,2)+dy/2));
        %         % Select earthquakes in overlapping rectangles
        %         vSel = (a.Longitude >= (newgri(i,1)-dx)) & (a.Longitude < (newgri(i,1)+dx)) &...
        %             (a.Latitude >= (newgri(i,2)-dy)) & (a.Latitude < (newgri(i,2)+dy));
        %         mCat = a.subset(vSel);

        % Initialize
        fMinTime = min(mCat(:,3));
        fMaxTime = max(mCat(:,3));

        % Select data from 2 time periods
        vSelT = mCat(:,3) < fSplitTime;
        mCat1 = mCat(vSelT,:);
        mCat2 = mCat(~vSelT,:);
        % Length of catalog (resolution)
        nNumevents1 = length(mCat1(:,1));
        nNumevents2 = length(mCat2(:,1));

        % Minimum bin: essential for computing difference in FMD
        fMinBin = roundn(min(mCat(:,6)),-1);
        fMaxBin = roundn(max(mCat(:,6)),-1);

        if (length(mCat1(:,1)) >=Nmin & length(mCat2(:,1)) >= Nmin)
            % Compute change in FMD normalized by time period
            % Time periods
            fPeriod1 = max(mCat1(:,3))-min(mCat1(:,3));
            fPeriod2 = max(mCat2(:,3))-min(mCat2(:,3));
            [vFMD1, vBin1] = hist(mCat1(:,6),fMinBin:0.1:fMaxBin);
            [vFMD2, vBin2] = hist(mCat2(:,6),fMinBin:0.1:fMaxBin);
            fChFMD = max(cumsum(abs(vFMD2./fPeriod2-vFMD1./fPeriod1)));
            % Calculate shift
            [fMshift, fProbability, fAICc, mProblikelihood, bH] = calc_loglikelihood_dM2(mCat1, mCat2);
            % Check for validity of model using KS-Test result to produce validated result of magnitude shift
            if (bH == 1 | fMshift == 0)
                fMshift_valid = NaN;
            else
                fMshift_valid = fMshift;
            end
            % Calculate Mc
            [mResult1, fMls1, fMc1, fMu1, fSigma1, mDatPredBest1,...
                    vPredBest1, fBvalue1, fAvalue1, bH1] = calc_McEMR_kstest(mCat1, 0.1);
            [mResult2, fMls2, fMc2, fMu2, fSigma2, mDatPredBest2,...
                    vPredBest2, fBvalue2, fAvalue2, bH2] = calc_McEMR_kstest(mCat2, 0.1);
            % Mc change
            fdMc = fMc2-fMc1;
            if (bH1 ==0  &&  bH2 == 0)
                fdMc_val = fdMc;
            else
                fdMc_val = NaN;
            end
            % Calculate Utsu-Test
            [dA, fProbEqual, fProbDifferent] = calc_Utsu(fBvalue1, fBvalue2, nNumevents1, nNumevents2);
            % Create result matrix
            mResult = [mResult; i fMshift fProbability fAICc bH nNumevents1 nNumevents2 fMshift_valid fChFMD fMc1 fMc2 fdMc fdMc_val dA fProbEqual fProbDifferent bH1 fBvalue1 fAvalue1 bH2 fBvalue2 fAvalue2];
        else
            % Create result matrix
            mResult = [mResult; i NaN NaN NaN NaN nNumevents1 nNumevents2 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
        end
        waitbar(allcount/itotal)
    end  % for newgr

    % Save the data to rcval_grid.mat
    save  mcgrid.mat mResult gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll bo1 newgri gll ra maepi fSplitTime
    disp('Saving data to mcgrid.mat in current directory')

    close(wai)
    watchoff

    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    % Magnitude shift
    normlap2(ll)= mResult(:,2);
    mMagShift = reshape(normlap2,length(yvect),length(xvect));


    % KS-Test-Value
    normlap2(ll)= mResult(:,5);
    mHkstest = reshape(normlap2,length(yvect),length(xvect));

    %%% Resolution parameters
    % Number of events per grid node in first time period
    normlap2(ll)= mResult(:,6);
    mNumevents1 = reshape(normlap2,length(yvect),length(xvect));

    % Number of events per grid node in first time period
    normlap2(ll)= mResult(:,7);
    mNumevents2 = reshape(normlap2,length(yvect),length(xvect));

    % Validated magnitude shift
    normlap2(ll)= mResult(:,8);
    mMagShift_valid = reshape(normlap2,length(yvect),length(xvect));

    % Absolute FMD difference
    normlap2(ll)= mResult(:,9);
    mChFMD = reshape(normlap2,length(yvect),length(xvect));

    % Mc Periode 1
    normlap2(ll)= mResult(:,10);
    mMc1 = reshape(normlap2,length(yvect),length(xvect));

    % Mc Periode 2
    normlap2(ll)= mResult(:,11);
    mMc2 = reshape(normlap2,length(yvect),length(xvect));

    % Mc change
    normlap2(ll)= mResult(:,12);
    mdMc = reshape(normlap2,length(yvect),length(xvect));

    % Mc change validated by KS-Test
    normlap2(ll)= mResult(:,13);
    mdMc_val = reshape(normlap2,length(yvect),length(xvect));

    % Difference of AIC for Utsu-Test
    normlap2(ll)= mResult(:,14);
    mdAIC_Utsu = reshape(normlap2,length(yvect),length(xvect));

    % Probability of stationarity (favoring stationarity)
    normlap2(ll)= mResult(:,15);
    mStationary1_Utsu = reshape(normlap2,length(yvect),length(xvect));

    % Probability of stationarity (favoring non-stationarity)
    normlap2(ll)= mResult(:,16);
    mStationary2_Utsu = reshape(normlap2,length(yvect),length(xvect));

    % Data to plot first map
    re3 = mMagShift;
    lab1 = 'Magnitude shift';


    % View the map
    view_mcgrid

end   % if sel = na

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])

        normlap2=ones(length(tmpgri(:,1)),1)*nan;

        % Magnitude shift
        normlap2(ll)= mResult(:,2);
        mMagShift = reshape(normlap2,length(yvect),length(xvect));

        % KS-Test-Value
        normlap2(ll)= mResult(:,5);
        mHkstest = reshape(normlap2,length(yvect),length(xvect));

        %%% Resolution parameters
        % Number of events per grid node in first time period
        normlap2(ll)= mResult(:,6);
        mNumevents1 = reshape(normlap2,length(yvect),length(xvect));

        % Number of events per grid node in first time period
        normlap2(ll)= mResult(:,7);
        mNumevents2 = reshape(normlap2,length(yvect),length(xvect));

        try
            % Validated magnitude shift
            normlap2(ll)= mResult(:,8);
            mMagShift_valid = reshape(normlap2,length(yvect),length(xvect));

            % Absolute FMD difference
            normlap2(ll)= mResult(:,9);
            mChFMD = reshape(normlap2,length(yvect),length(xvect));
            % Mc Periode 1
            normlap2(ll)= mResult(:,10);
            mMc1 = reshape(normlap2,length(yvect),length(xvect));

            % Mc Periode 2
            normlap2(ll)= mResult(:,11);
            mMc2 = reshape(normlap2,length(yvect),length(xvect));

            % Mc change
            normlap2(ll)= mResult(:,12);
            mdMc = reshape(normlap2,length(yvect),length(xvect));

            % Mc change
            normlap2(ll)= mResult(:,13);
            mdMc_val = reshape(normlap2,length(yvect),length(xvect));

            % Difference of AIC for Utsu-Test
            normlap2(ll)= mResult(:,14);
            mdAIC_Utsu = reshape(normlap2,length(yvect),length(xvect));

            % Probability of stationarity (favoring stationarity)
            normlap2(ll)= mResult(:,15);
            mStationary1_Utsu = reshape(normlap2,length(yvect),length(xvect));

            % Probability of stationarity (favoring non-stationarity)
            normlap2(ll)= mResult(:,16);
            mStationary2_Utsu = reshape(normlap2,length(yvect),length(xvect));

        catch
            disp('Validated magnitude shift map not available');
        end
        % Initial map set to relative rate change
        re3 = mMagShift;
        lab1 = 'Magnitude shift';

        old = re3;
        % Plot
        view_mcgrid;
    else
        return
    end
end
