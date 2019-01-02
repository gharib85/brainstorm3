function CMap = cmap_atlas(varargin)

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
    1.0000    1.0000    1.0000
    0.7961    0.5569    0.7961
         0    0.4588    0.4510
    0.7490    0.0902    0.0902
    0.7765    0.7765    0.0078
    0.5843    0.7961    0.7961
    0.4000    0.4000    0.4000
    0.7961    0.7961    0.4235
    0.5961    0.2706    0.1843
    0.6353    0.3176    0.7961
         0    0.9961         0
    0.7961    0.7961    0.0118
    0.2980    0.1843    0.4980
    0.2118    0.2118    0.7961
         0    0.7961         0
    0.6353         0    0.2118
    0.9961    0.9961    0.0157
    0.7216    0.5804    0.1529
         0    0.7961    0.7961
    0.5020    0.4000         0
         0    0.7961         0
    0.7961    0.5569    0.7961
    0.6353    0.2118    0.0510
    0.7961    0.7961    0.0118
    0.6353         0    0.2196
    0.7961    0.4000         0
         0    0.7843    0.7961
    0.3686         0    0.1020
    0.8000    0.8000    0.8000
    0.2824    0.2824    0.7843
    0.3176         0    0.6902
    0.6353         0    0.2118
    0.5255    0.2078         0
    0.4784    0.7961    0.2627
    0.3686    0.2706    0.2118
         0    0.5294    0.7961
    0.0510    0.6902    0.2627
         0    0.7843         0
    0.4235         0    0.6353
    0.2392    0.2392    0.7961
    0.7961    0.7961         0
    0.6353    0.2118    0.0510
    0.3686    0.0510    0.0510
    0.7961    0.2078         0
    0.1490         0    0.3255
    0.6353         0    0.2196
         0    0.3686    0.3608
    0.5020    0.4000         0
    0.5490    0.1412    0.1647
    0.2392    0.2392    0.7961
         0    0.5961    0.2510
    0.7961    0.5843    0.5843
         0    0.3686    0.3608
    0.7961         0    0.2627
    0.7961    0.5843    0.5843
    0.3686    0.0667    0.2980
    0.7961    0.2627    0.0627
    0.9373    0.1137    0.1137
    0.3961         0    0.8627
         0    0.9804         0
         0    0.7961         0
    0.7490    0.0902    0.0902
    0.5020    0.5020    0.5020
         0    0.4588    0.4510
    0.9020    0.7255    0.1922
    0.7922         0    0.2745
    0.2980    0.2980    0.9961
         0    0.4588    0.4510
         0    0.7961         0
    0.9961    0.9961         0
    0.9961    0.7294    0.7294
    0.7961    0.2627    0.0627
    0.4627         0    0.1294
    0.4627    0.3373    0.2667
    0.6353    0.3176    0.7961
         0    0.9961         0
    0.5843    0.7961    0.7961
    0.2627    0.2627    0.9961
    0.7961    0.2627    0.0627
    0.9961    0.7294    0.7294
    0.7490    0.0902    0.0902
    0.7765    0.7765    0.0078
    0.5294         0    0.7961
    0.4627    0.3373    0.2667
    0.2980    0.2980    0.9961
    0.6353    0.2118    0.0510
    0.6353         0    0.2118
    0.3725    0.2314    0.6235
    0.4627         0    0.1294
    0.7451    0.3373    0.2314
    0.3529    0.3529    0.9804
    0.2392    0.2392    0.7961
    0.4627    0.0824    0.3725
         0    0.4588    0.4510
    0.7961    0.7961    0.4235
    0.9961    0.6941    0.9961
    0.4627    0.0627    0.0627
    0.4000    0.4000    0.4000
         0    0.9804    0.9961
         0    0.4588    0.4510
    0.1843         0    0.4078
    0.6863    0.1765    0.2078
    0.7961         0    0.2627
    0.7961    0.5843    0.5843
    0.9961    0.7294    0.7294
    0.1843         0    0.4078
         0    0.6627    0.9961
    0.5961    0.9961    0.3294
    0.8510    0.8510    0.8510
    0.6353         0    0.2118
    0.7961    0.3961    0.9961
    0.7961    0.2627    0.0627
    0.4000    0.4000    0.4000
    0.9961    0.4980         0
    0.7961    0.3961    0.9961
    0.7961    0.5569    0.7961
    0.7961    0.5569    0.7961
    0.0627    0.8627    0.3294
    0.3725    0.2314    0.6235
    0.6275    0.4980         0
         0    0.4588    0.4510
    0.7961         0    0.2627
    0.5961    0.9961    0.3294
    0.6275    0.4980         0
    0.9373    0.1137    0.1137
    0.2980    0.2980    0.9961
    0.8000    0.8000    0.8000
    0.7961    0.2627    0.0627
    0.7961    0.5569    0.7961
         0    0.4588    0.4510
    0.7490    0.0902    0.0902
    0.7765    0.7765    0.0078
    0.5843    0.7961    0.7961
    0.4000    0.4000    0.4000
    0.7961    0.7961    0.4235
    0.5961    0.2706    0.1843
    0.6353    0.3176    0.7961
         0    0.9961         0
    0.7961    0.7961    0.0118
    0.2980    0.1843    0.4980
    0.2118    0.2118    0.7961
         0    0.7961         0
    0.6353         0    0.2118
    0.9961    0.9961    0.0157
    0.7216    0.5804    0.1529
         0    0.7961    0.7961
    0.5020    0.4000         0
         0    0.7961         0
    0.7961    0.5569    0.7961
    0.6353    0.2118    0.0510
    0.7961    0.7961    0.0118
    0.6353         0    0.2196
    0.7961    0.4000         0
         0    0.7843    0.7961
    0.3686         0    0.1020
    0.8000    0.8000    0.8000
    0.2824    0.2824    0.7843
    0.3176         0    0.6902
    0.6353         0    0.2118
    0.5255    0.2078         0
    0.4784    0.7961    0.2627
    0.3686    0.2706    0.2118
         0    0.5294    0.7961
    0.0510    0.6902    0.2627
         0    0.7843         0
    0.4235         0    0.6353
    0.2392    0.2392    0.7961
    0.7961    0.7961         0
    0.6353    0.2118    0.0510
    0.3686    0.0510    0.0510
    0.7961    0.2078         0
    0.1490         0    0.3255
    0.6353         0    0.2196
         0    0.3686    0.3608
    0.5020    0.4000         0
    0.5490    0.1412    0.1647
    0.2392    0.2392    0.7961
         0    0.5961    0.2510
    0.7961    0.5843    0.5843
         0    0.3686    0.3608
    0.7961         0    0.2627
    0.7961    0.5843    0.5843
    0.3686    0.0667    0.2980
    0.7961    0.2627    0.0627
    0.9961    0.6941    0.9961
    0.9961    0.9961         0
    0.7961    0.7961    0.0118
    0.6275    0.4980         0
    0.9961    0.2588         0
    0.9961    0.9961    0.0157
    0.8510    0.8510    0.8510
    0.3529    0.3529    0.9804
    0.9020    0.7255    0.1922
    0.6353         0    0.2196
    0.2980    0.2980    0.9961
    0.7961    0.7961    0.0118
         0    0.9804         0
    0.7922         0    0.2745
         0    0.4588    0.4510
    0.7961    0.2627    0.0627
         0    0.7451    0.3137
         0    0.6627    0.9961
    0.7961         0    0.2627
    0.9961    0.9961    0.0157
    0.7294    0.9961    0.9961
    0.9961    0.9961    0.5294
    0.6588    0.2588         0
    0.9961    0.2588         0
    0.6353         0    0.2196
    0.3961         0    0.8627
    0.7451    0.3373    0.2314
    0.5294         0    0.7961
    0.4627    0.0627    0.0627
         0    0.9961    0.9961
    0.9725    0.9725    0.0078
         0    0.9961    0.9961
         0    0.4588    0.4510
    0.4627    0.0824    0.3725
    0.2627    0.2627    0.9961
         0    0.9961         0
    0.5020    0.5020    0.5020
    0.6353    0.2118    0.0510
    0.2392    0.2392    0.7961
    0.9961    0.9961    0.5294
         0    0.3686    0.3608
    0.5961    0.2706    0.1843
    0.7961         0    0.2627
    0.9961    0.7294    0.7294
    0.7961    0.2627    0.0627
    0.6588    0.2588         0
    0.0627    0.8627    0.3294
         0    0.3686    0.3608
    0.7961         0    0.2627
    0.9961    0.9961    0.0157
    0.9373    0.1137    0.1137
    0.7294    0.9961    0.9961
    0.7961    0.7961    0.4235
         0    0.9961         0
         0    0.7451    0.3137
         0    0.9804    0.9961
    0.7765    0.7765    0.0078
    0.9961    0.9961    0.0157
         0    0.9961         0
    0.9961    0.9961    0.0157
    0.9373    0.1137    0.1137
    0.6275    0.4980         0
         0    0.4588    0.4510
    0.9725    0.9725    0.0078
    0.9961    0.9961    0.0157
    0.7961    0.5843    0.5843
    0.7961         0    0.2627
    0.6353    0.3176    0.7961
    0.8000    0.8000    0.8000
    0.6863    0.1765    0.2078
    0.5843    0.7961    0.7961
    0.9961    0.4980         0];
     
     
     
     