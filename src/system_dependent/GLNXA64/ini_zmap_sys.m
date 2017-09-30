function ini_zmap()
    %    This is the  ZMAP default file used for LINUX systems.
    %    It's purpose is to modify the ZmapGlobal variables as necessary
    %    to fit the system.
    report_this_filefun(mfilename('fullpath'));
    
    ZG=ZmapGlobal.Data;
    % Marker sizes
    ZG.ms6 = 3;
    
    %set the recursion slightly, to avoid error (specialy with ploop functions)
    set(0,'RecursionLimit',750)
    
    set(0,'DefaultAxesFontName','Arial');
    set(0,'DefaultTextFontName','Arial');
    set(0,'DefaultAxesTickLength',[0.01 0.01]);
    set(0,'DefaultFigurePaperPositionMode','auto');
    
    system_dependent(14,'on') % helps with possible wierd copy/paste issues with windows
end