function CMap = cmap_nih(varargin)

% @=============================================================================
% This function is part of the Brainstorm software:
% https://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2019 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@

CMap =[
         0         0         0
    0.0196         0    0.0431
    0.0431         0    0.0863
    0.0667         0    0.1333
    0.0863         0    0.1765
    0.1098         0    0.2196
    0.1333         0    0.2667
    0.1529         0    0.3098
    0.1765         0    0.3529
    0.2000         0    0.4000
    0.2196         0    0.4431
    0.2431         0    0.4863
    0.2667         0    0.5333
    0.2863         0    0.5765
    0.3098         0    0.6196
    0.3333         0    0.6667
    0.3098         0    0.6431
    0.2902         0    0.6235
    0.2706         0    0.6039
    0.2471         0    0.5804
    0.2275         0    0.5608
    0.2078         0    0.5412
    0.1843         0    0.5176
    0.1647         0    0.4980
    0.1451         0    0.4784
    0.1216         0    0.4549
    0.1020         0    0.4353
    0.0824         0    0.4157
    0.0588         0    0.3922
    0.0392         0    0.3725
    0.0196         0    0.3529
         0         0    0.3333
         0         0    0.3529
         0         0    0.3725
         0         0    0.3922
         0         0    0.4157
         0         0    0.4353
         0         0    0.4549
         0         0    0.4784
         0         0    0.4980
         0         0    0.5176
         0         0    0.5412
         0         0    0.5608
         0         0    0.5804
         0         0    0.6039
         0         0    0.6235
         0         0    0.6431
         0         0    0.6667
         0         0    0.6863
         0         0    0.7059
         0         0    0.7255
         0         0    0.7490
         0         0    0.7686
         0         0    0.7882
         0         0    0.8118
         0         0    0.8314
         0         0    0.8510
         0         0    0.8745
         0         0    0.8941
         0         0    0.9137
         0         0    0.9373
         0         0    0.9569
         0         0    0.9765
         0         0    1.0000
         0    0.0196    1.0000
         0    0.0392    1.0000
         0    0.0588    1.0000
         0    0.0824    1.0000
         0    0.1020    1.0000
         0    0.1216    1.0000
         0    0.1451    1.0000
         0    0.1647    1.0000
         0    0.1843    1.0000
         0    0.2078    1.0000
         0    0.2275    1.0000
         0    0.2471    1.0000
         0    0.2706    1.0000
         0    0.2902    1.0000
         0    0.3098    1.0000
         0    0.3333    1.0000
         0    0.3529    0.9765
         0    0.3725    0.9569
         0    0.3922    0.9373
         0    0.4157    0.9137
         0    0.4353    0.8941
         0    0.4549    0.8745
         0    0.4784    0.8510
         0    0.4980    0.8314
         0    0.5176    0.8118
         0    0.5412    0.7882
         0    0.5608    0.7686
         0    0.5804    0.7490
         0    0.6039    0.7255
         0    0.6235    0.7059
         0    0.6431    0.6863
         0    0.6667    0.6667
         0    0.6863    0.6667
         0    0.7059    0.6667
         0    0.7255    0.6667
         0    0.7490    0.6667
         0    0.7686    0.6667
         0    0.7882    0.6667
         0    0.8118    0.6667
         0    0.8314    0.6667
         0    0.8510    0.6667
         0    0.8745    0.6667
         0    0.8941    0.6667
         0    0.9137    0.6667
         0    0.9373    0.6667
         0    0.9569    0.6667
         0    0.9765    0.6667
         0    1.0000    0.6667
         0    1.0000    0.6235
         0    1.0000    0.5804
         0    1.0000    0.5412
         0    1.0000    0.4980
         0    1.0000    0.4549
         0    1.0000    0.4157
         0    1.0000    0.3725
         0    1.0000    0.3333
         0    1.0000    0.2902
         0    1.0000    0.2471
         0    1.0000    0.2078
         0    1.0000    0.1647
         0    1.0000    0.1216
         0    1.0000    0.0824
         0    1.0000    0.0392
         0    1.0000         0
    0.0196    1.0000    0.0196
    0.0392    1.0000    0.0392
    0.0588    1.0000    0.0588
    0.0824    1.0000    0.0824
    0.1020    1.0000    0.1020
    0.1216    1.0000    0.1216
    0.1451    1.0000    0.1451
    0.1647    1.0000    0.1647
    0.1843    1.0000    0.1843
    0.2078    1.0000    0.2078
    0.2275    1.0000    0.2275
    0.2471    1.0000    0.2471
    0.2706    1.0000    0.2706
    0.2902    1.0000    0.2902
    0.3098    1.0000    0.3098
    0.3333    1.0000    0.3333
    0.3725    1.0000    0.3098
    0.4157    1.0000    0.2902
    0.4549    1.0000    0.2706
    0.4980    1.0000    0.2471
    0.5412    1.0000    0.2275
    0.5804    1.0000    0.2078
    0.6235    1.0000    0.1843
    0.6667    1.0000    0.1647
    0.7059    1.0000    0.1451
    0.7490    1.0000    0.1216
    0.7882    1.0000    0.1020
    0.8314    1.0000    0.0824
    0.8745    1.0000    0.0588
    0.9137    1.0000    0.0392
    0.9569    1.0000    0.0196
    1.0000    1.0000         0
    1.0000    0.9765         0
    1.0000    0.9569         0
    1.0000    0.9373         0
    1.0000    0.9137         0
    1.0000    0.8941         0
    1.0000    0.8745         0
    1.0000    0.8510         0
    1.0000    0.8314         0
    1.0000    0.8118         0
    1.0000    0.7882         0
    1.0000    0.7686         0
    1.0000    0.7490         0
    1.0000    0.7255         0
    1.0000    0.7059         0
    1.0000    0.6863         0
    1.0000    0.6667         0
    1.0000    0.6431         0
    1.0000    0.6235         0
    1.0000    0.6039         0
    1.0000    0.5804         0
    1.0000    0.5608         0
    1.0000    0.5412         0
    1.0000    0.5176         0
    1.0000    0.4980         0
    1.0000    0.4784         0
    1.0000    0.4549         0
    1.0000    0.4353         0
    1.0000    0.4157         0
    1.0000    0.3922         0
    1.0000    0.3725         0
    1.0000    0.3529         0
    1.0000    0.3333         0
    1.0000    0.3176         0
    1.0000    0.3059         0
    1.0000    0.2941         0
    1.0000    0.2784         0
    1.0000    0.2667         0
    1.0000    0.2549         0
    1.0000    0.2431         0
    1.0000    0.2275         0
    1.0000    0.2157         0
    1.0000    0.2039         0
    1.0000    0.1922         0
    1.0000    0.1765         0
    1.0000    0.1647         0
    1.0000    0.1529         0
    1.0000    0.1373         0
    1.0000    0.1255         0
    1.0000    0.1137         0
    1.0000    0.1020         0
    1.0000    0.0863         0
    1.0000    0.0745         0
    1.0000    0.0627         0
    1.0000    0.0510         0
    1.0000    0.0353         0
    1.0000    0.0235         0
    1.0000    0.0118         0
    1.0000         0         0
    0.9882         0         0
    0.9804         0         0
    0.9725         0         0
    0.9647         0         0
    0.9529         0         0
    0.9451         0         0
    0.9373         0         0
    0.9294         0         0
    0.9176         0         0
    0.9098         0         0
    0.9020         0         0
    0.8941         0         0
    0.8824         0         0
    0.8745         0         0
    0.8667         0         0
    0.8588         0         0
    0.8471         0         0
    0.8392         0         0
    0.8314         0         0
    0.8235         0         0
    0.8157         0         0
    0.8039         0         0
    0.7961         0         0
    0.7882         0         0
    0.7804         0         0
    0.7686         0         0
    0.7608         0         0
    0.7529         0         0
    0.7451         0         0
    0.7333         0         0
    0.7255         0         0
    0.7176         0         0
    0.7098         0         0
    0.6980         0         0
    0.6902         0         0
    0.6824         0         0
    0.6784         0         0
         0         0         0];
     
     
     
     