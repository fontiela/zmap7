classdef ZmapGrid
    % ZMAPGRID evenly-spaced X,Y grid with ability to be masked
    %
    % ZmapGrid properties:
    %
    %     Name - name of this grid
    %
    %     GridPoints  - [X1,Y1 ; ... ; Xn,Yn] Nx2 matrix of positions
    %     X - all X positions (points will repeat, since they represent matrix nodes)
    %     Y - all Y positions (points will repeat, since they represent matrix nodes)
    %
    %     Units - degrees or kilometers
    %     ActivePoints - logical mask
    %
    %     Xactive - X positions for active points [read-only]
    %     Yactive - Y positions for active points [read-only]
    %
    % ZmapGrid methods:
    %
    %     Creation methods:
    %
    %     ZmapGrid - create a ZmapGrid
    %     AutoCreateDeg -create ZDataGrid based on current Map extent/Catalog extent, whichever is smaller
    %
    %     Plotting methods:
    %
    %     plot - plot the points in this grid
    %     pcolor - create a pcolor plot where each point of the grid is center of cell
    %
    %     Misc. methods:
    %
    %     ActiveGrid - [X Y; ..;Yn Yn] for active points [read-only]
    %     length - number of grid points
    %     isempty - true if no grid is defined
    %     MeshSize - [number of X, number of Y[, number of Z]]
    %     MaskWithShape - set the logicalmask to true where points are in polygon, false elsewhere
    %
    %     load - load grid from a .mat file [static method]
    %     save - save this grid to a .mat file
    %
    %     setGlobal - copy this grid into the globally used grid
    %
    %
    % see also gridfun, EventSelectionChoice, autogrid
    %
    properties
        Name % name of this grid
        Units % degrees or kilometers
        ActivePoints    % logical mask
        X % all X positions in matrix (points will repeat, since they represent matrix nodes)
        Y % all Y positions in matrix (points will repeat, since they represent matrix nodes)
    end
    properties(Dependent)
        Xactive % all X positions for active points
        Yactive % all Y positions for active points
        GridPoints % Nx2 vector of all grid points [X1,Y1 ; X2,Y2 ; ...]
    end
    properties(Constant,Hidden)
        POSSIBLY_TOO_MANY_POINTS = 1000 * 1000;
    end
    
    methods
        function obj = ZmapGrid(name, varargin)
            %ZMAPGRID create a ZmapGridStruc
            %   OBJ = ZMAPGRID(NAME, GPC_STRUCT) where gpc_struct has fields dx,dy, dx_units.
            %
            %   ZMAPGRID(NAME, ALL_X, ALL_Y, UNITS) create a grid, where the X is the provided ALL_X
            %   Y is the provided ALL_Y.  This creates a grid [X1 Y1; X1 Y2; ... Xn Ym
            %
            %   ZMAPGRID(NAME,ALL_POINTS,UNITS); % NOT RECOMMENDED
            %
            % see also: MESHGRID
            obj.Name = name;
            switch nargin
                case 2
                    if isnumeric(varargin{1})
                        % ZMAPGRID( NAME , [X1,Y1;...;XnYn] )
                        warning('ZmapGrid works best when provided with X and Y matrices of points');
                        assert(size(varargin{1},2)==2);
                        obj.Units='unk';
                        obj.X=varargin{1}(:,1);
                        obj.Y=varargin{1}(:,2);
                    elseif isstruct(varargin{1})
                        % assume it came from GridParameterChoice
                        g=varargin{1};
                        ax=gca;
                        obj.Units=g.dx_units;
                        axlims=axis(ax);
                        xvector=axlims(1) : g.dx : axlims(2);
                        yvector=axlims(3) : g.dy : axlims(4);
                        totpoints=numel(xvector)*numel(yvector);
                        if totpoints > ZmapGrid.POSSIBLY_TOO_MANY_POINTS
                            ZmapMessageCenter.set_warning(sprintf('Possibly too many points: %d',totpoints'));
                        end
                        [obj.X, obj.Y]=meshgrid(xvector, yvector);
                        if isfield(g,'GridEntireArea') && ~g.GridEntireArea
                            myshape=ZmapGlobal.Data.selection_shape;
                            if isempty(myshape)
                                ZmapMessageCenter.set_warning('Polygon not defined',...
                                    'Requested that grid is limited by the polygon, but no polygon is defined.');
                                switch questdlg('Choose a shape to define:','Polygon Not defined','polygon','circle','none','none')
                                    case 'circle'
                                        myshape = ShapeCircle.selectUsingMouse();
                                        myshape.plot(gca)
                                        pause(2);
                                        obj=obj.MaskWithShape(myshape.Lon,myshape.Lat);
                                        myshape.clearplot;
                                    case 'polygon'
                                        myshape=ShapePolygon();
                                        myshape.select_polygon();
                                        obj=obj.MaskWithShape(myshape.Lon,myshape.Lat);
                                    otherwise
                                        % do nothing
                                end
                            else
                                obj=obj.MaskWithShape(myshape.Points);
                            end
                        end
                    else
                        error('unknown');
                    end
                case 3
                    % ZMAPGRID( name, all_points, units)
                    warning('ZmapGrid works best when provided with X and Y matrices of points');
                    assert(size(varargin{1},2)==2);
                    obj.X=varargin{1}(:,1);
                    obj.Y=varargin{1}(:,2);
                    assert(ischar(varargin{2}));
                    obj.Units = varargin{2};
                case 4
                    % ZMAPGRID( name, Xmatrix, Ymatrix, units)
                    assert(isequal(size(varargin{1}),size(varargin{2})),'X and Y should be the same size');
                    obj.X=varargin{1};
                    obj.Y=varargin{2};
                    assert(ischar(varargin{3}));
                    obj.Units = varargin{3};
                    
                otherwise
                    error('incorrect number of arguments %d', nargin);
            end
            
            if isempty(obj.ActivePoints)
                obj.ActivePoints=true(size(obj.X));
            end
            
        end
        
        % basic access routines
        function gp = get.GridPoints(obj)
            if ~isempty(obj)
                gp=[obj.X(:), obj.Y(:)];
            else
                gp = [];
            end
        end
        
        % masked access routines
        function x = get.Xactive(obj)
            x=obj.X(obj.ActivePoints);
        end
        
        function y = get.Yactive(obj)
            y=obj.Y(obj.ActivePoints);
        end
        
        function points = ActiveGrid(obj)
            points=obj.GridPoints(obj.ActivePoints,:);
        end
        
        function obj = set.ActivePoints(obj, values)
            assert(isempty(values) || isequal(numel(values), length(obj.GridPoints))); %#ok<MCSUP>
            obj.ActivePoints = logical(values);
        end
        
        function val = length(obj)
            val = numel(obj.X);
        end
        
        function val = isempty(obj)
            val = isempty(obj.X);
        end
        
        function obj = MaskWithShape(obj,polyX, polyY)
            % MaskWithShape sets the mask according to a polygon
            % obj = obj.MaskWithShape() user selects polygon from gca
            % obj = obj.MaskWithShape(shape)
            % obj = obj.MaskWithShape(polyX, polyY) where polyX and polyY define the polygon
            report_this_filefun(mfilename('fullpath'));
            narginchk(1,3);
            nargoutchk(1,1);
            switch nargin
                case 2
                    if isa(polyX,'ShapeGeneral')
                        polyY=polyX.Lat;
                        polyX=polyX.Lon; 
                    end
                    
                case 1
                    ZG=ZmapGlobal.Data;
                    if ~isempty(ZG.selection_shape) && ~isnan(ZG.selection_shape.Points(1))
                        polyX=ZG.selection_shape.Lon; 
                        polyY=ZG.selection_shape.Lat;
                    end
                case 3
                    if polyX(1) ~= polyX(end) || polyY(1) ~= polyY(end)
                        warning('polygon is not closed. adding a point to close it.')
                        polyX(end+1)=polyX(1);
                        polyY(end+1)=polyY(1);
                    end
            end
            obj.ActivePoints = polygon_filter(polyX,polyY, obj.X, obj.Y, 'inside');
        end
        
        function prev_grid=plot(obj, ax,varargin)
            % plot the current grid over axes(ax)
            % obj.plot() plots on the current axes
            %  obj.plot(ax) plots on the specified axes. if ax is empty, then the current axes will
            %     be used
            %
            %  obj.plot(ax,'name',value,...) sets the grid's properties after plotting/updating
            %
            %  obj.plot(..., 'ActiveOnly') will only plot the active points. This is useful when
            %   displaying the vertices within a polygon, for example.
            %
            %  if this figure already has a grid with this name, then it will be modified.
            
            if ~exist('ax','var') || isempty(ax)
                ax=gca;
            end
            def_opts={'color',[.7 .7 .7],'displayname','grid points','markersize',5,'marker','.'};
            varargin=[def_opts,varargin];
            useActiveOnly= numel(varargin)>0 && strcmpi(varargin{end},'ActiveOnly');
            if useActiveOnly && ~isempty(obj.ActivePoints)
                varargin(end)=[];
                x='Xactive';
                y='Yactive';
            else
                x='X';
                y='Y';
            end
            if ~all(ishandle(ax))
                error('invalid axes provided. If not specifying axes, but are providing additional options, lead with "[]". ex. obj.plot([],''color'',[ 1 1 0])');
            end
            prev_grid = findobj(ax,'Tag',['grid_' obj.Name]);
            if ~isempty(prev_grid)
                prev_grid.XData=obj.(x)(:);
                prev_grid.YData=obj.(y)(:);
                disp('reusing grid on plot');
            else
                hold(ax,'on');
                prev_grid=plot(ax,obj.(x)(:),obj.(y)(:),'+k','Tag',['grid_' obj.Name]);
                hold(ax,'off');
                disp('created new grid on plot');
            end
            if numel(varargin)>1
                set(prev_grid,varargin{:});
            end
        end
        
        function h=pcolor(obj, ax, values, name)
            % pcolor create a pcolor plot where each point of the grid is center of cell
            % h = obj.pcolor(ax, values) plos the values as a pcolor plot, where
            % each grid point is contained within a color cell. the cells are divided halfway
            % between each point in the vector
            %  where :
            %    AX is the axis of choice (empty for gca)
            %    VALUES is a matrix of values that matches the grid in size.
            %
            %
            % h is a handle to the pcolor object
            %
            % see also gridpcolor
            if ~exist('name','var')
                name = '';
            end
            assert(numel(obj.X)==numel(values),'Number of values doesn''t match number of points')
            if isvector(values) && ~isvector(obj.X)
                values=reshape(values,size(obj.X));
            end
            h=gridpcolor(ax,obj.X, obj.Y, values, obj.ActivePoints, name);
        end
        
        function h=imagesc(obj, ax, values, name)
            % imagesc create a imagesc plot where each point of the grid is center of cell
            % h = obj.pcolor(ax, values) plots the values as a pcolor plot, where
            % each grid point is contained within a color cell. the cells are divided halfway
            % between each point in the vector
            %  where :
            %    AX is the axis of choice (empty for gca)
            %    VALUES is a matrix of values that matches the grid in size.
            %
            %
            % h is a handle to the pcolor object
            %
            % see also gridpcolor
            if ~exist('name','var')
                name = '';
            end
            assert(numel(values)==numel(obj.X),'expect same number of values');
            if ~isequal(size(values),size(obj.X))
                values = reshape(values,size(obj.X));
            end
            
            % corners for image
            x = [min(obj.X) max(obj.X)];
            y = [min(obj.Y) max(obj.Y)];
            values(~obj.ActivePoints)=nan;
            %axes ax
            imAlpha=ones(size(values));
            imAlpha(isnan(values))=0;
            %imAlpha=~obj.ActivePoints;
            h=imagesc(x, y, values,'AlphaData',imAlpha);%, obj.ActivePoints,name);
            set(gca,'YDir','normal');
        end
        
        function setGlobal(obj)
            % set the globally used grid to this one.
            ZG=ZmapGlobal.Data;
            ZG.grid=obj;
        end
        
        function save(obj, filename, pathname)
            % save grid to .mat file
            ZG=ZmapGlobal.Data;
            if ~exist('filename','var')
                filename = fullfile(pathname,['zmapgrid_',obj.Name,'.m']);
                uisave('zmapgrid',filename)
            elseif ~exist('path','var')
                filename = fullfile(ZG.data_dir,['zmapgrid_',obj.Name,'.m']);
                uisave('zmapgrid',filename)
            else
                uisave('zmapgrid',fullfile(pathname,filename));
            end
        end
    end
    
    methods(Static)
        function obj=AutoCreateDeg(name, ax, catalog)
            % creates a ZDataGrid based on current Map extent/Catalog extent, whichever is smaller.
            % obj = ZmapGrid.AutoCreate() greates a catalog based on mainmap and primary catalog
            % obj = ZmapGrid.Autocreate(ax, catalog) specifies a map axis handle and a catalog to use.
            
            % obj=ZmapGrid(name, x_start, dx, x_end, y_start, dy, y_end, units)
            XBINS=20;
            YBINS=20;
            %ZBINS=5;
            ZG=ZmapGlobal.Data;
            switch nargin
                case 0
                    name='unnamed';
                    ax=mainmap('axes');
                    catalog=ZG.primeCatalog;
                case 1
                    ax=mainmap('axes');
                    catalog=ZG.primeCatalog;
                case 3
                    assert(isa(catalog,'ZmapCatalog'));
                    assert(isvalid(ax));
                otherwise
                    error('Either use AutoCreate(name) or AutoCreate(name, ax, catalog)');
            end
            
            mapWESN = axis(ax);
            x_start = max(mapWESN(1), min(catalog.Longitude));
            x_end = min(mapWESN(2), max(catalog.Longitude));
            y_start = max(mapWESN(1), min(catalog.Latitude));
            y_end = min(mapWESN(2), max(catalog.Latitude));
            %z_start = 0;
            %z_end = max(catalog.Depth);
            dx= (x_end - x_start)/XBINS;
            dy= (y_end - y_start)/YBINS;
            %dz =  (z_end - z_start)/ZBINS;
            %TODO make spacing more intelligent. maybe.
            %FIXME map units and this unit might be out of whack.
            obj=ZmapGrid(name,x_start, dx, x_end, y_start, dy, y_end, 'deg');
        end
        
        function obj=FromVectors(name, x,y, units)
            % ZMAPGRID.FROMVECTORS creates a meshgrid from X and Y vectors
            % obj=FromVectors(name, x,y, units)
            
            [X, Y] =  meshgrid(x, y);
            obj=ZmapGrid(name,X,Y,units);
        end
        
        function obj=load(filename, pathname)
            % mygrid = ZmapGrid.load() prompts user for a zmap grid file
            %
            % mygrid = ZmapGrid.load('grid1') -> attempts to load 'grid1' or 'zmapgrid_grid1.m' from
            % the data directory, and then anywhere the matlab path.
            %
            % mygrid = ZmapGrid.load('grid1', 'mydir') - attempts to load 'grid1' or
            % 'zmapgrid_grid1.m' from the mydir directory.
            %
            % the grid must be contained in a variable named 'zmapgrid' and of type ZmapGrid
            switch nargin
                case 0
                    [filename, pathname] = uigetfile('zmapgrid_*.m', 'Pick a ZmapGrid file');
                    fullfilename= fullfile(pathname,filename);
                case 1
                    if exist(fullfile(ZG.data_dir,filename),'file')
                        fullfilename=fullfile(ZG.data_dir,filename);
                    elseif exist(filename,'file')
                        fullfilename=filename;
                    else
                        fullfilename=fullfile(ZG.data_dir,['zmapgrid_' filename '.m']);
                    end
                case 2
                    if exist(fullfile(pathname,filename),'file')
                        fullfilename=fullfile(pathname,filename);
                    else
                        fullfilename=fullfile(pathname,['zmapgrid_' filename '.m']);
                    end
            end
            try
                tmp=load(fullfilename,'zmapgrid');
                obj=tmp.zmapgrid;
                assert(isa(obj,'ZmapGrid'));
            catch ME
                errordlg(ME.message);
            end
        end
    end
end