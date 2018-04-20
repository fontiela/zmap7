function [mFMDC, mFMD] = calc_FMD(mCatalog)
% function [mFMDC, mFMD] = calc_FMD(mCatalog)
% -------------------------------------------
% Calculates the cumulative and non-cumulative frequency magnitude distribution
%   for a given earthquake catalog
%
% Input parameter:
%   mCatalog    earthquake catalog
%
% Output parameters:
%   mFMDC       cumulative frequency magnitude distribution
%               mFMDC(1,:) = magnitudes (x-axis)
%               mFMDC(2,:) = number of events (y-axis)
%   mFMD        non-cumulative frequency magnitude distribution
%
% Danijel Schorlemmer
% November 16, 2001

report_this_filefun();

% Determine the magnitude range
fMaxMagnitude = ceil(10 * max(mCatalog.Magnitude)) / 10;
fMinMagnitude = floor(min(mCatalog.Magnitude));
if fMinMagnitude > 0
  fMinMagnitude = 0;
end

% Naming convention:
%   xxxxR : Reverse order
%   xxxxC : Cumulative number

% Do the calculation
[vNumberEvents] = hist(mCatalog.Magnitude, (fMinMagnitude:0.1:fMaxMagnitude));
vNumberEventsR  = vNumberEvents(end:-1:1);
vNumberEventsCR = cumsum(vNumberEvents(end:-1:1));

% Create the x-axis values
vXAxis = (fMaxMagnitude:-0.1:fMinMagnitude);

% Merge the x-axis values with the FMDs and return them
mFMD  = [vXAxis; vNumberEventsR];
mFMDC = [vXAxis; vNumberEventsCR];
