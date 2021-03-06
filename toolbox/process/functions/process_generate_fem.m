function varargout = process_generate_fem( varargin )
% PROCESS_GENERATE_FEM: Generate tetrahedral/hexahedral FEM mesh.
%
% USAGE:     OutputFiles = process_generate_fem('Run',     sProcess, sInputs)
%         [isOk, errMsg] = process_generate_fem('Compute', iSubject, iMris=[default], isInteractive, OPTIONS)
%                          process_generate_fem('ComputeInteractive', iSubject, iMris=[default])
%                OPTIONS = process_generate_fem('GetDefaultOptions')
%                  label = process_generate_fem('GetFemLabel', label)
%             NewFemFile = process_generate_fem('SwitchHexaTetra', FemFile)
%                 errMsg = process_generate_fem('InstallIso2mesh', isInteractive)
%                 errMsg = process_generate_fem('InstallDuneuro', isInteractive)
%                 errMsg = process_generate_fem('InstallBrain2mesh', isInteractive)

% @=============================================================================
% This function is part of the Brainstorm software:
% https://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2020 University of Southern California & McGill University
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
%
% Authors: Francois Tadel, Takfarinas Medani, 2019-2020

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    OPTIONS = GetDefaultOptions();
    % Description the process
    sProcess.Comment     = 'Generate FEM mesh';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = {'Import', 'Import anatomy'};
    sProcess.Index       = 22;
    sProcess.Description = '';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'import'};
    sProcess.OutputTypes = {'import'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 0;
    sProcess.isSeparator = 1;
    % Subject name
    sProcess.options.subjectname.Comment = 'Subject name:';
    sProcess.options.subjectname.Type    = 'subjectname';
    sProcess.options.subjectname.Value   = '';
    % Method
    sProcess.options.method.Comment = {'<B>Iso2mesh</B>:<BR>Call iso2mesh to create a tetrahedral mesh from the <B>BEM surfaces</B><BR>', ...
                                       '<B>Brain2mesh</B>:<BR>Segment the <B>T1</B> (and <B>T2</B>) <B>MRI</B> with SPM12, mesh with Brain2Mesh<BR>', ...
                                       '<B>SimNIBS</B>:<BR>Call SimNIBS to segment and mesh the <B>T1</B> (and <B>T2</B>) <B>MRI</B>.', ...
                                       '<B>FieldTrip</B>:<BR> Call FieldTrip to create hexahedral mesh of the <B>T1 MRI</B>.'; ...
                                       'iso2mesh', 'brain2mash', 'simnibs', 'fieldtrip'};
    sProcess.options.method.Type    = 'radio_label';
    sProcess.options.method.Value   = 'iso2mesh';
    % SimNIBS/FieldTrip: NbLayers
    sProcess.options.nblayers.Comment = {...
        '3 layers : brain, skull, scalp', ...
        '4 layers : brain, csf, skull, scalp', ...
        '5 layers : white, gray, csf, skull, scalp'; ...
        '3','4','5'};
    sProcess.options.nblayers.Type    = 'radio_label';
    sProcess.options.nblayers.Value   = '3';
    % Iso2mesh options: 
    sProcess.options.opt1.Comment = '<BR><BR><B>Iso2mesh options</B>: ';
    sProcess.options.opt1.Type    = 'label';
    % Iso2mesh: Merge method
    sProcess.options.mergemethod.Comment = {'mergemesh', 'mergesurf', 'Input surfaces merged with:'; 'mergemesh', 'mergesurf', ''};
    sProcess.options.mergemethod.Type    = 'radio_linelabel';
    sProcess.options.mergemethod.Value   = 'mergemesh';
    % Iso2mesh: Max tetrahedral volume
    sProcess.options.maxvol.Comment = 'Max tetrahedral volume (10=coarse, 0.0001=fine, default=0.1): ';
    sProcess.options.maxvol.Type    = 'value';
    sProcess.options.maxvol.Value   = {OPTIONS.MaxVol, '', 4};
    % Iso2mesh: keepratio: Percentage of elements being kept after the simplification
    sProcess.options.keepratio.Comment = 'Percentage of elements kept (default=100%): ';
    sProcess.options.keepratio.Type    = 'value';
    sProcess.options.keepratio.Value   = {OPTIONS.KeepRatio, '%', 0};
    % SimNIBS options:
    sProcess.options.opt2.Comment = '<BR><B>SimNIBS options</B>: ';
    sProcess.options.opt2.Type    = 'label';
    % SimNIBS: Vertex density
    sProcess.options.vertexdensity.Comment = 'Vertex density: nodes per mm2 (0.1-1.5, default=0.5): ';
    sProcess.options.vertexdensity.Type    = 'value';
    sProcess.options.vertexdensity.Value   = {OPTIONS.VertexDensity, '', 2};
    % FieldTrip options:
    sProcess.options.opt3.Comment = '<BR><B>FieldTrip options</B>: ';
    sProcess.options.opt3.Type    = 'label';
    % FieldTrip: Downsample volume
    sProcess.options.downsample.Comment = 'Downsample volume (1=no downsampling): ';
    sProcess.options.downsample.Type    = 'value';
    sProcess.options.downsample.Value   = {OPTIONS.Downsample, '', 0};
    % FieldTrip: Node shift
    sProcess.options.nodeshift.Comment = 'Node shift [0 - 0.49]: ';
    sProcess.options.nodeshift.Type    = 'value';
    sProcess.options.nodeshift.Value   = {OPTIONS.NodeShift, '', 2};
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end


%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>
    OutputFiles = {};
    OPTIONS = struct();
    % Get subject name
    SubjectName = file_standardize(sProcess.options.subjectname.Value);
    if isempty(SubjectName)
        bst_report('Error', sProcess, [], 'Subject name is empty.');
        return;
    end
    % Get subject
    [sSubject, iSubject] = bst_get('Subject', SubjectName);
    if isempty(iSubject)
        bst_report('Error', sProcess, [], ['Subject "' SubjectName '" does not exist.']);
        return
    end
    % Method
    OPTIONS.Method = sProcess.options.method.Value;
    if isempty(OPTIONS.Method) || ~ischar(OPTIONS.Method) || ~ismember(OPTIONS.Method, {'iso2mesh','brain2mesh','simnibs','fieldtrip'})
        bst_report('Error', sProcess, [], 'Invalid method.');
        return
    end
    % Iso2mesh: Merge method
    OPTIONS.MergeMethod = sProcess.options.mergemethod.Value;
    if isempty(OPTIONS.MergeMethod) || ~ischar(OPTIONS.MergeMethod) || ~ismember(OPTIONS.MergeMethod, {'mergesurf','mergemesh'})
        bst_report('Error', sProcess, [], 'Invalid merge method.');
        return
    end
    % Iso2mesh: Maximum tetrahedral volume
    OPTIONS.MaxVol = sProcess.options.maxvol.Value{1};
    if isempty(OPTIONS.MaxVol) || (OPTIONS.MaxVol < 0.000001) || (OPTIONS.MaxVol > 20)
        bst_report('Error', sProcess, [], 'Invalid maximum tetrahedral volume.');
        return
    end
    % Iso2mesh: Keep ratio (percentage 0-1)
    OPTIONS.KeepRatio = sProcess.options.keepratio.Value{1};
    if isempty(OPTIONS.KeepRatio) || (OPTIONS.KeepRatio < 1) || (OPTIONS.KeepRatio > 100)
        bst_report('Error', sProcess, [], 'Invalid kept element percentage.');
        return
    end
    OPTIONS.KeepRatio = OPTIONS.KeepRatio ./ 100;
    % SimNIBS: Number of layers
    OPTIONS.NbLayers = str2num(sProcess.options.nblayers.Value);
    if isempty(OPTIONS.NbLayers)
        bst_report('Error', sProcess, [], 'Invalid number of layers.');
        return
    end
    % SimNIBS: Maximum tetrahedral volume
    OPTIONS.VertexDensity = sProcess.options.vertexdensity.Value{1};
    if isempty(OPTIONS.VertexDensity) || (OPTIONS.VertexDensity < 0.01) || (OPTIONS.VertexDensity > 5)
        bst_report('Error', sProcess, [], 'Invalid vertex density.');
        return
    end
    % FieldTrip: Node shift
    OPTIONS.NodeShift = sProcess.options.nodeshift.Value{1};
    if isempty(OPTIONS.NodeShift) || (OPTIONS.NodeShift < 0) || (OPTIONS.NodeShift >= 0.5)
        bst_report('Error', sProcess, [], 'Invalid node shift.');
        return
    end
    % FieldTrip: Downsample volume 
    OPTIONS.Downsample = sProcess.options.downsample.Value{1};
    if isempty(OPTIONS.Downsample) || (OPTIONS.Downsample < 1) || (OPTIONS.Downsample - round(OPTIONS.Downsample) ~= 0)
        bst_report('Error', sProcess, [], 'Invalid downsampling factor.');
        return
    end
    
    % Call processing function
    [isOk, errMsg] = Compute(iSubject, [], 0, OPTIONS);
    % Handling errors
    if ~isOk
        bst_report('Error', sProcess, [], errMsg);
    elseif ~isempty(errMsg)
        bst_report('Warning', sProcess, [], errMsg);
    end
    % Return an empty structure
    OutputFiles = {'import'};
end


%% ===== DEFAULT OPTIONS =====
function OPTIONS = GetDefaultOptions()
    OPTIONS = struct(...
        'Method',         'iso2mesh', ...      % {'iso2mesh', 'brain2mesh', 'simnibs', 'roast', 'fieldtrip'}
        'MeshType',       'tetrahedral', ...   % iso2mesh: 'tetrahedral';  simnibs: 'tetrahedral';  roast:'hexahedral'/'tetrahedral';  fieldtrip:'hexahedral'/'tetrahedral' 
        'NbLayers',       3, ...               % iso2mesh: {3,4};          simnibs: {3,4,5};        roast:{3,5};                       fieldtrip:{3,5}
        'MaxVol',         0.1, ...             % iso2mesh: Max tetrahedral volume (10=coarse, 0.0001=fine)
        'KeepRatio',      100, ...             % iso2mesh: Percentage of elements kept (1-100%)
        'BemFiles',       [], ...              % iso2mesh: List of layers to use for meshing (if not specified, use the files selected in the database 
        'MergeMethod',    'mergemesh', ...     % iso2mesh: {'mergemesh', 'mergesurf'} Function used to merge the meshes
        'VertexDensity',  0.5, ...             % SimNIBS : [0.1 - X] setting the vertex density (nodes per mm2)  of the surface meshes
        'NodeShift',      0.3, ...             % FieldTrip: [0 - 0.49] Improves the geometrical properties of the mesh
        'Downsample',     3);                  % FieldTrip: Integer, Downsampling factor to apply to the volumes before meshing
end


%% ===== COMPUTE FEM MESHES =====
function [isOk, errMsg] = Compute(iSubject, iMris, isInteractive, OPTIONS)
    isOk = 0;
    errMsg = '';

    % ===== DEFAULT OPTIONS =====
    Def_OPTIONS = GetDefaultOptions();
    if isempty(OPTIONS)
        OPTIONS = Def_OPTIONS;
    else
        OPTIONS = struct_copy_fields(OPTIONS, Def_OPTIONS, 0);
    end
    % Empty temporary folder, otherwise it reuses previous files in the folder
    gui_brainstorm('EmptyTempFolder');
            
    % ===== GET T1/T2 MRI =====
    % Get subject
    sSubject = bst_get('Subject', iSubject);
    if isempty(sSubject)
        errMsg = 'Subject does not exist.';
        return
    end
    % Check if a MRI is available for the subject
    if isempty(sSubject.Anatomy)
        errMsg = ['No MRI available for subject "' SubjectName '".'];
        return
    end
    % Get default MRI if not specified
    if isempty(iMris)
        iMris = 1:length(sSubject.Anatomy);
        tryDefaultT2 = 0;
    else
        tryDefaultT2 = 1;
    end
    % If there are multiple MRIs: order them to put the default one first (probably a T1)
    if (length(iMris) > 1)
        % Select the default MRI as the T1
        if ismember(sSubject.iAnatomy, iMris)
            iT1 = sSubject.iAnatomy;
            iMris = iMris(iMris ~= sSubject.iAnatomy);
        else
            iT1 = [];
        end
        % Find other possible T1
        if isempty(iT1)
            iT1 = find(~cellfun(@(c)isempty(strfind(c,'t1')), lower({sSubject.Anatomy(iMris).Comment})));
            if ~isempty(iT1)
                iT1 = iMris(iT1(1));
                iMris = iMris(iMris ~= iT1);
            end
        end
        % Find any possible T2
        iT2 = find(~cellfun(@(c)isempty(strfind(c,'t2')), lower({sSubject.Anatomy(iMris).Comment})));
        if ~isempty(iT2)
            iT2 = iMris(iT2(1));
            iMris = iMris(iMris ~= iT2);
        else
            iT2 = [];
        end
        % If not identified yet, use first MRI as T1
        if isempty(iT1)
            iT1 = iMris(1);
            iMris = iMris(2:end);
        end
        % If not identified yet, use following MRI as T2
        if isempty(iT2) && tryDefaultT2
            iT2 = iMris(1);
        end
    else
        iT1 = iMris(1);
        iT2 = [];
    end
    % Get full file names
    T1File = file_fullpath(sSubject.Anatomy(iT1).FileName);
    if ~isempty(iT2)
        T2File = file_fullpath(sSubject.Anatomy(iT2).FileName);
    else
        T2File = [];
    end
    
    % ===== GENERATE MESH =====
    switch lower(OPTIONS.Method)
        % Compute from OpenMEEG BEM layers: head, outerskull, innerskull
        case 'iso2mesh'
            % Install iso2mesh if needed
            if ~exist('iso2meshver', 'file') || ~isdir(bst_fullfile(bst_fileparts(which('iso2meshver')), 'doc'))
                errMsg = InstallIso2mesh(isInteractive);
                if ~isempty(errMsg) || ~exist('iso2meshver', 'file') || ~isdir(bst_fullfile(bst_fileparts(which('iso2meshver')), 'doc'))
                    return;
                end
            end
            % If surfaces are not passed in input: get default surfaces
            if isempty(OPTIONS.BemFiles)
                if ~isempty(sSubject.iScalp) && ~isempty(sSubject.iOuterSkull) && ~isempty(sSubject.iInnerSkull)
                    OPTIONS.BemFiles = {...
                        sSubject.Surface(sSubject.iInnerSkull).FileName, ...
                        sSubject.Surface(sSubject.iOuterSkull).FileName, ...
                        sSubject.Surface(sSubject.iScalp).FileName};
                    TissueLabels = {'brain', 'skull', 'scalp'};
                else
                    errMsg = ['Method "' OPTIONS.Method '" requires three surfaces: head, inner skull and outer skull.' 10 ...
                        'Create them with process "Generate BEM surfaces" first.'];
                    return;
                end
            % If surfaces are given: get their labels and sort from inner to outer
            else
                % Get tissue label
                for iBem = 1:length(OPTIONS.BemFiles)
                    [sSubject, iSubject, iSurface] = bst_get('SurfaceFile', OPTIONS.BemFiles{iBem});
                    if ~strcmpi(sSubject.Surface(iSurface).SurfaceType, 'Other')
                        TissueLabels{iBem} = GetFemLabel(sSubject.Surface(iSurface).SurfaceType);
                    else
                        TissueLabels{iBem} = GetFemLabel(sSubject.Surface(iSurface).Comment);
                    end
                end
                % Sort from inner to outer
                iSort = [];
                iOther = 1:length(OPTIONS.BemFiles);
                for label = {'white', 'gray', 'csf', 'skull', 'scalp'}
                    iLabel = find(strcmpi(label{1}, TissueLabels));
                    iSort = [iSort, iLabel];
                    iOther(iLabel) = NaN;
                end
                iSort = [iSort, iOther(~isnan(iOther))];
                OPTIONS.BemFiles = OPTIONS.BemFiles(iSort);
                TissueLabels = TissueLabels(iSort);
            end
            % Load surfaces
            bst_progress('text', 'Loading surfaces...');
            bemMerge = {};
            disp(' ');
            for iBem = 1:length(OPTIONS.BemFiles)
                disp(sprintf('FEM> %d. %5s: %s', iBem, TissueLabels{iBem}, OPTIONS.BemFiles{iBem}));
                BemMat = in_tess_bst(OPTIONS.BemFiles{iBem});
                bemMerge = cat(2, bemMerge, BemMat.Vertices, BemMat.Faces);
            end
            disp(' ');
            % Merge all the surfaces
            bst_progress('text', ['Merging surfaces (Iso2mesh/' OPTIONS.MergeMethod ')...']);
            switch (OPTIONS.MergeMethod)
                % Faster and simpler: Simple concatenation without intersection checks
                case 'mergemesh'
                    % Concatenate meshes
                    [newnode, newelem] = mergemesh(bemMerge{:});
                    % Remove duplicated elements
                    newelem = unique(sort(newelem,2),'rows');
                % Slower and more robust: Concatenates and checks for intersections (split intersecting elements)
                case 'mergesurf'
                    try
                        [newnode, newelem] = mergesurf(bemMerge{:});
                    catch
                        errMsg = 'Problem with the function MergeSurf. You can try with MergeMesh.';
                        bst_progress('stop');
                        return;
                    end
                otherwise
                    error(['Invalid merge method: ' OPTIONS.MergeMethod]);
            end
            % Find the seed point for each region
            center_inner = mean(bemMerge{end-1});
            % define seeds along the electrode axis
            orig = center_inner;
            v0 = [0 0 1];
            [t,tmp,tmp,faceidx] = raytrace(orig,v0,newnode,newelem);
            t = sort(t(faceidx)); 
            t = (t(1:end-1)+t(2:end))*0.5; 
            seedlen = length(t);
            regions = repmat(orig(:)',seedlen,1) + repmat(v0(:)',seedlen,1) .* repmat(t(:),1,3);

            % Create tetrahedral mesh
            bst_progress('text', 'Creating 3D mesh (Iso2mesh/surf2mesh)...');
            factor_bst = 1.e-6;
            [node,elem] = surf2mesh(newnode, newelem, min(newnode), max(newnode),...
                OPTIONS.KeepRatio, factor_bst .* OPTIONS.MaxVol, regions, []);
            
%             % Sorting compartments from the center of the head
%             allLabels = unique(elem(:,5));
%             dist = zeros(1, length(allLabels));
%             for iLabel = 1:length(allLabels)
%                 iElem = find(elem(:,5) == allLabels(iLabel));
%                 iVert = unique(reshape(elem(iElem,1:4), [], 1));
%                 dist(iLabel) = min(sum(node(iVert,:) .^ 2,2));
%             end
%             [tmp, I] = sort(dist);
%             allLabels = allLabels(I);
%             % Labels: the number of layers may change if one of the input surfaces contains multiple layers
%             if length(TissueLabels) == length(I)
%                 TissueLabels = TissueLabels(I);
%             else
%                 TissueLabels = [];
%             end

            % Relabelling from 1 to Ntissue
            bst_progress('text', 'Saving 3D mesh...');
            allLabels = unique(elem(:,5));
            elemLabel = ones(size(elem,1),1);
            for iLabel = 1:length(allLabels)
                elemLabel((elem(:,5) == allLabels(iLabel))) = iLabel;
            end
            elem(:,5) = elemLabel;
            % Mesh check and repair
            [no,el] = removeisolatednode(node,elem(:,1:4));
            % Orientation required for the FEM computation (at least with SimBio, may be not for Duneuro)
            newelem = meshreorient(no, el(:,1:4));
            elem = [newelem elem(:,5)];
            % Only tetra could be generated from this method
            OPTIONS.MeshType = 'tetrahedral';

        case 'brain2mesh'
            disp([10 'FEM> T1 MRI: ' T1File]);
            disp(['FEM> T2 MRI: ' T2File 10]);
            % Initialize SPM
            if ~bst_spm_init(isInteractive)
                errMsg = 'SPM12 must be in the Matlab path for using this feature.';
                return;
            end
            % Install brain2mesh if needed
            if ~exist('brain2mesh', 'file')
                errMsg = InstallBrain2mesh(isInteractive);
                if ~isempty(errMsg) || ~exist('brain2mesh', 'file')
                    return;
                end
            end
            % Get TPM.nii template
            tpmFile = bst_get('SpmTpmAtlas');
            if isempty(tpmFile) || ~file_exist(tpmFile)
                error('Missing file TPM.nii');
            end
            
            % === SAVE MRI AS NII ===
            bst_progress('text', 'Exporting MRI...');
            % Empty temporary folder, otherwise it may reuse previous files in the folder
            gui_brainstorm('EmptyTempFolder');
            % Create temporary folder for segmentation files
            tempDir = bst_fullfile(bst_get('BrainstormTmpDir'), 'brain2mesh');
            mkdir(tempDir);
            % Save MRI in .nii format
            subjid = strrep(sSubject.Name, '@', '');
            T1Nii = bst_fullfile(tempDir, [subjid 'T1.nii']);
            sMriT1 = in_mri_bst(T1File);
            out_mri_nii(sMriT1, T1Nii);
            if ~isempty(T2File)
                T2Nii = bst_fullfile(tempDir, [subjid 'T2.nii']);
                sMriT2 = in_mri_bst(T2File);
                out_mri_nii(sMriT2, T2Nii);
                % Check the size of the volumes
                if ~isequal(size(sMriT1.Cube), size(sMriT2.Cube)) || ~isequal(size(sMriT1.Voxsize), size(sMriT2.Voxsize))
                    errMsg = ['Input images have different dimension, you must register and reslice them first.' 10 ...
                              sprintf('T1:(%d x %d x %d),   T2:(%d x %d x %d)', size(sMriT1.Cube), size(sMriT2.Cube))];
                    return;
                end
            else
                T2Nii = [];
            end
            
            % === CALL SPM SEGMENTATION ===
            bst_progress('text', 'MRI segmentation with SPM12...');
            % SPM batch for segmentation
            matlabbatch{1}.spm.spatial.preproc.channel(1).vols = {[T1Nii ',1']};
            matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0.001;
            matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 60;
            matlabbatch{1}.spm.spatial.preproc.channel(1).write = [0 0];
            if ~isempty(T2Nii)
                matlabbatch{1}.spm.spatial.preproc.channel(2).vols = {[T2Nii ',1']};
                matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0.001;
                matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 60;
                matlabbatch{1}.spm.spatial.preproc.channel(2).write = [0 0];
            end
            matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[tpmFile, ',1']};
            matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
            matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[tpmFile, ',2']};
            matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
            matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[tpmFile, ',3']};
            matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
            matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[tpmFile, ',4']};
            matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
            matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[tpmFile, ',5']};
            matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
            matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[tpmFile, ',6']};
            matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
            matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
            matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
            matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
            matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
            matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
            % Call SPM batch
            spm_jobman('run', matlabbatch);
            % Check for success
            testFile = bst_fullfile(tempDir, ['c5' subjid 'T1.nii']);
            if ~file_exist(testFile)
                errMsg = ['SPM12 segmentation failed: missing output file "' testFile '".'];
                return;
            end
            % Read outputs
            sTpm = in_mri_nii(bst_fullfile(tempDir, ['c1' subjid 'T1.nii']));
            seg.gm = sTpm.Cube;
            sTpm = in_mri_nii(bst_fullfile(tempDir, ['c2' subjid 'T1.nii']));
            seg.wm = sTpm.Cube;
            sTpm = in_mri_nii(bst_fullfile(tempDir, ['c3' subjid 'T1.nii']));
            seg.csf = sTpm.Cube;
            sTpm = in_mri_nii(bst_fullfile(tempDir, ['c4' subjid 'T1.nii']));
            seg.skull = sTpm.Cube;
            sTpm = in_mri_nii(bst_fullfile(tempDir, ['c5' subjid 'T1.nii']));
            seg.scalp = sTpm.Cube;

            % ===== CALL BRAIN2MESH =====
            bst_progress('text', 'Meshing with Brain2Mesh...');
            [node,elem] = brain2mesh(seg);
            % Handle errors
            if isempty(elem)
                errMsg = 'Mesh generation with Brain2Mesh/tetgen1.5 failed.';
                return;
            end
            
        case 'simnibs'
            disp(['FEM> T1 MRI: ' T1File]);
            disp(['FEM> T2 MRI: ' T2File]);
            % Check for SimNIBS installation
            status = system('headreco --version');
            if (status ~= 0)
                errMsg = ['SimNIBS is not installed or not added to the system path:' 10 'the command "headreco" could not be found.' 10 10 'To install SimNIBS, visit: https://simnibs.github.io/simnibs'];
                return;
            end
            % Install bst_duneuro if needed
            if ~exist('bst_duneuro', 'file')
                errMsg = InstallDuneuro(isInteractive);
                if ~isempty(errMsg) || ~exist('bst_duneuro', 'file')
                    return;
                end
            end
            
            % === SAVE MRI AS NII ===
            bst_progress('text', 'Exporting MRI...');
            % Empty temporary folder, otherwise it may reuse previous files in the folder
            gui_brainstorm('EmptyTempFolder');
            % Create temporary folder for segmentation files
            simnibsDir = bst_fullfile(bst_get('BrainstormTmpDir'), 'simnibs');
            mkdir(simnibsDir);
            % Save MRI in .nii format
            subjid = strrep(sSubject.Name, '@', '');
            T1Nii = bst_fullfile(simnibsDir, [subjid 'T1.nii']);
            sMriT1 = in_mri_bst(T1File);
            out_mri_nii(sMriT1, T1Nii);
            if ~isempty(T2File)
                T2Nii = bst_fullfile(simnibsDir, [subjid 'T2.nii']);
                out_mri_nii(T2File, T2Nii);
            else
                T2Nii = [];
            end

            % === CALL SIMNIBS PIPELINE ===
            bst_progress('text', 'Calling SimNIBS/headreco...');
            % Go to simnibs working directory
            curDir = pwd;
            cd(simnibsDir);
            % Call headreco
             if OPTIONS.VertexDensity ~= 0.5
                strCall = ['headreco all --noclean -v ' num2str(OPTIONS.VertexDensity) ' subjid '  T1Nii '  ' T2Nii];
            else % call the default option, where VertexDensity is fixed to 0.5
                strCall = ['headreco all --noclean  ' subjid ' ' T1Nii ' ' T2Nii];
            end
            [status, result] = system(strCall);
            % Restore working directory
            cd(curDir);
            % If SimNIBS returned an error
            if (status ~= 0)
                errMsg = ['SimNIBS call: ', strrep(strCall, ' "', [10 '      "']),  10 10 ...
                          'SimNIBS error #' num2str(status) ': ' 10 result];
                return;
            end
                  
            % === IMPORT OUTPUT FOLDER ===
            bst_progress('text', 'Importing SimNIBS output...');
            % Import FEM mesh
            % load the mesh and change to bst coordinates :
            mshfilename = bst_fullfile(simnibsDir, [subjid '.msh']);
            femhead = in_tess(mshfilename, 'SIMNIBS', sMriT1); %  this could be loaded to bst as it is
            % Keep cortex surface
            cortexElem = femhead.Elements(femhead.Tissue <= 2, :);
            % Get the number of layers
            switch (OPTIONS.NbLayers)
                case 3
                    TissueLabels = {'brain', 'skull', 'scalp'};
                    % Replace the CSF, GM by WM and use unique label
                    femhead.Tissue(femhead.Tissue== 2) = 1; % gm to wm and all form brain label 1
                    femhead.Tissue(femhead.Tissue== 3) = 1; % csf to wm and all form brain label 1
                    femhead.Tissue(femhead.Tissue== 4) = 2; % skull label 2
                    femhead.Tissue(femhead.Tissue== 5) = 3; % scalp label 3
                case 4
                    TissueLabels = {'brain', 'csf', 'skull', 'scalp'};
                    % Replace the GM by WM and use unique label
                    femhead.Tissue(femhead.Tissue== 2) = 1; % gm to wm and all form brain with label 1
                    femhead.Tissue(femhead.Tissue== 3) = 2; % csf label 2
                    femhead.Tissue(femhead.Tissue== 4) = 3; % skull label 3
                    femhead.Tissue(femhead.Tissue== 5) = 4; % scalp label 4
                case 5   
                    TissueLabels = femhead.TissueLabels;   % {'white', 'gray', 'csf', 'skull', 'scalp'}
            end
            elem = [femhead.Elements femhead.Tissue];
            node = femhead.Vertices;
            % Only tetra could be generated from this method
            OPTIONS.MeshType = 'tetrahedral';

            % ===== EXTRACT THE FEM CORTEX SURFACE =====
            bst_progress('text', 'Saving cortex envelope...');
            % Create a surface for the outside surface of this tissue
            cortexFaces = tess_voledge(node, cortexElem);
            % Remove all the unused vertices
            cortexVertices = node;
            iRemoveVert = setdiff((1:size(cortexVertices,1))', unique(cortexFaces(:)));
            if ~isempty(iRemoveVert)
                [cortexVertices, cortexFaces] = tess_remove_vert(cortexVertices, cortexFaces, iRemoveVert);
            end
            % Remove small elements
            [cortexVertices, cortexFaces] = tess_remove_small(cortexVertices, cortexFaces);

            % ===== SAVE CORTEX =====
            % New surface structure
            NewTess = db_template('surfacemat');
            NewTess.Comment  = 'cortex_fem';
            NewTess.Vertices = cortexVertices;
            NewTess.Faces    = cortexFaces;
            % History: File name
            NewTess.History = 'Cortex extracted from FEM model by SimNibs Method';
            % Produce a default surface filename &   Make this filename unique
            CortexFile = file_unique(bst_fullfile(bst_fileparts(T1File), ...
                            sprintf('tess_%s_%dV.mat', ['cortex_' OPTIONS.Method], length(NewTess.Vertices))));
            % Save new surface in Brainstorm format
            bst_save(CortexFile, NewTess, 'v7'); 
            db_add_surface(iSubject, CortexFile, NewTess.Comment);

        case 'fieldtrip'
            % Setup FieldTrip
            isOk = bst_ft_init(isInteractive);
            if ~isOk
                errMsg = 'FieldTrip must be in the Matlab path for using this feature.';
                return;
            end

            % === CALL FIELDTRIP PIPELINE ===
            % Convert MRI to fieldtrip structure
            bst_progress('text', 'Reading T1 MRI...');
            bstMri = in_mri(T1File);
            ftMri = out_fieldtrip_mri(bstMri);
            % Segmentation
            bst_progress('text', 'MRI segmentation (FieldTrip/ft_volumesegment)...');
            cfg = [];
            TissueLabels = {'white','gray','csf','skull','scalp'};
            cfg.output = TissueLabels;
            segmentedmri = ft_volumesegment(cfg, ftMri);
            % Mesh
            bst_progress('text', 'Mesh generation (FieldTrip/ft_prepare_mesh)...');
            cfg = [];
            cfg.method = 'hexahedral';
            cfg.spmversion = 'spm12';
            cfg.downsample = OPTIONS.Downsample;
            cfg.shift = OPTIONS.NodeShift;
            mesh = ft_prepare_mesh(cfg, segmentedmri);
            
            % Reorder labels based on requested order
            iRelabel = cellfun(@(c)find(strcmpi(c,TissueLabels)), mesh.tissuelabel)';
            mesh.tissue = iRelabel(mesh.tissue);
            % Group tissues
            switch (OPTIONS.NbLayers)
                case 3
                    TissueLabels = {'brain', 'skull', 'scalp'};
                    % Replace the CSF, GM by WM and use unique label
                    mesh.tissue(mesh.tissue == 2) = 1; % gm to wm and all form brain label 1
                    mesh.tissue(mesh.tissue == 3) = 1; % csf to wm and all form brain label 1
                    mesh.tissue(mesh.tissue == 4) = 2; % skull label 2
                    mesh.tissue(mesh.tissue == 5) = 3; % scalp label 3
                case 4
                    TissueLabels = {'brain', 'csf', 'skull', 'scalp'};
                    % Replace the GM by WM and use unique label
                    mesh.tissue(mesh.tissue == 2) = 1; % gm to wm and all form brain with label 1
                    mesh.tissue(mesh.tissue == 3) = 2; % csf label 2
                    mesh.tissue(mesh.tissue == 4) = 3; % skull label 3
                    mesh.tissue(mesh.tissue == 5) = 4; % scalp label 4
                case 5   
                    % Nothing to change
            end
            % Convert from FieldTrip world coordinates back to FieldTrip voxel coordinates
            M = inv(ftMri.transform);
            node = [mesh.pos, ones(size(mesh.pos, 1),1)] * M(1:3,:)';
            % Convert to to Brainstorm voxel coordinates
            node(:,1) = node(:,1) + 1;
            node(:,2) = size(bstMri.Cube,2) - node(:,2);
            node(:,3) = size(bstMri.Cube,3) - node(:,3);
            % Convert to SCS coordinates
            node = cs_convert(bstMri, 'voxel', 'scs', node);
            % Return hexadrons
            elem = [mesh.hex mesh.tissue];
            % Only hexa could be generated from this method
            OPTIONS.MeshType = 'hexahedral';
            
%         case 'roast'
%             % Install ROAST if needed
%             if ~exist('roast', 'file')
%                 errMsg = InstallRoast(isInteractive);
%                 if ~isempty(errMsg) || ~exist('roast', 'file')
%                     return;
%                 end
%             end
%             
%             % === SAVE MRI AS NII ===
%             bst_progress('setimage', 'logo_splash_roast.gif');
%             % Create temporary folder for fieldtrip segmentation files
%             roastDir = bst_fullfile(bst_get('BrainstormTmpDir'), 'roast');
%             mkdir(roastDir);
%             % Save MRI in .nii format
%             T1Nii = bst_fullfile(roastDir, 'roastT1.nii');
%             out_mri_nii(T1File, T1Nii);
%             if ~isempty(T2File)
%                 T2Nii = bst_fullfile(roastDir, 'roastT2.nii');
%                 out_mri_nii(T2File, T2Nii);
%             end
% 
%             % === CALL ROAST PIPELINE ===
%             % Segmentation
%             bst_progress('text', 'MRI Segmentation...');
%             segment_by_roast(T1Nii, T2Nii);
%             % Convert the roast output to fieltrip in order to use prepare mesh
%             data = load_untouch_nii(bst_fullfile(roastDir, 'roast_T1orT2_masks.nii'));
%             allMask = data.img; 
%             % Getting the MRI data
%             ft_defaults
%             mri = ft_read_mri(T1Nii);
%             % Define layers
%             switch (OPTIONS.NbLayers)
%                 case 3
%                     white_mask = zeros(size(allMask)); white_mask(allMask == 1) = true;
%                     gray_mask  = zeros(size(allMask)); gray_mask(allMask == 2) = true;
%                     csf_mask   = zeros(size(allMask)); csf_mask(allMask == 3) = true;
%                     brain_mask = white_mask + gray_mask + csf_mask;
%                     bone_mask  = zeros(size(allMask)); bone_mask(allMask == 4) = true;
%                     skin_mask  = zeros(size(allMask)); skin_mask(allMask == 5) = true;
%                     segmentedmri.dim = size(skin_mask);
%                     segmentedmri.transform = [];
%                     segmentedmri.coordsys = 'ctf';
%                     segmentedmri.unit = 'mm';
%                     segmentedmri.brain = brain_mask;
%                     segmentedmri.skull = bone_mask;
%                     segmentedmri.scalp = skin_mask;
%                     segmentedmri.transform = mri.transform;
%                 case 5   % {'white', 'gray', 'csf', 'bone', 'skin', 'air'}
%                     white_mask = zeros(size(allMask)); white_mask(allMask == 1) = true;
%                     gray_mask  = zeros(size(allMask)); gray_mask(allMask == 2) = true;
%                     csf_mask   = zeros(size(allMask)); csf_mask(allMask == 3) = true;
%                     bone_mask  = zeros(size(allMask)); bone_mask(allMask== 4) = true;
%                     skin_mask  = zeros(size(allMask)); skin_mask(allMask == 5) = true;
%                     segmentedmri.dim = size(skin_mask);
%                     segmentedmri.transform = [];
%                     segmentedmri.coordsys = 'ctf';
%                     segmentedmri.unit = 'mm';
%                     segmentedmri.gray = gray_mask;
%                     segmentedmri.white = white_mask;
%                     segmentedmri.csf = csf_mask;
%                     segmentedmri.skull = bone_mask;
%                     segmentedmri.scalp = skin_mask;
%                     segmentedmri.transform = mri.transform;
%             end
% 
%             % Output mesh type
%             switch (OPTIONS.MeshType)
%                 case 'hexahedral'
%                     % Mesh using fieldtrip tools
%                     cfg        = [];
%                     cfg.shift  = OPTIONS.NodeShift ;
%                     cfg.method = 'hexahedral';
%                     mesh = ft_prepare_mesh(cfg,segmentedmri);
%                     % Visualisation : not for brainstorm ...
%                     %TODO : work on brainstom function to display the mesh better than the current version
%                     % convert the mesh to tetra in order to use plotmesh
%                     [el,pos,id] = hex2tet(mesh.hex,mesh.pos,mesh.tissue,2);
%                     elem = [el id];        clear el id
%                     figure;
%                     plotmesh(pos,elem,'x<50')
%                     title('Mesh hexa with vox2hexa')
%                     clear pos elem
%                     % save as hexa ...
%                     node = mesh.pos;
%                     elem = [mesh.hex mesh.tissue];
%                     %             %% convert the hexa to tetra (add the function hex2tet to the toolbox)
%                     %             [el, node, id]=hex2tet(mesh.hex,mesh.pos,mesh.tissue,2);
%                     %             elem = [el id];
%                     %             clear el id
%                 case 'tetrahedral'
%                     % Mesh by iso2mesh
%                     bst_progress('text', 'Mesh Generation...'); %
%                     %TODO ... Load the mask and apply Johannes process to generate the cubic Mesh
%                     % TODO : Add the T2 images to the segmenttion process.
%                     [node,elem] = mesh_by_iso2mesh(T1Nii, T2Nii);
%                     figure;
%                     plotmesh(node,elem,'x<90')
%                     title('Mesh tetra  with iso2mesh ')
%             end

        otherwise
            errMsg = ['Invalid method "' OPTIONS.Method '".'];
            return;
    end


    % ===== SAVE FEM MESH =====
    bst_progress('text', 'Saving FEM mesh...');
    % Create output structure
    FemMat = db_template('femmat');
    FemMat.Comment = sprintf('FEM %dV (%s, %d layers)', length(node), OPTIONS.Method, OPTIONS.NbLayers);
    FemMat.Vertices = node;
    if strcmp(OPTIONS.MeshType, 'tetrahedral')
        FemMat.Elements = elem(:,1:4);
        FemMat.Tissue = elem(:,5);
    else
        FemMat.Elements = elem(:,1:8);
        FemMat.Tissue = elem(:,9);
    end
    if ~isempty(TissueLabels)
        FemMat.TissueLabels = TissueLabels;
    else
        uniqueLabels = unique(FemMat.Tissue);
        for i = 1:length(uniqueLabels)
             FemMat.TissueLabels{i} = num2str(uniqueLabels(i));
        end
    end

    % Add history
    strOptions = '';
    for f = fieldnames(OPTIONS)'
        strOptions = [strOptions, f{1}, '='];
        if isnumeric(OPTIONS.(f{1}))
            strOptions = [strOptions, num2str(OPTIONS.(f{1}))];
        elseif ischar(OPTIONS.(f{1}))
            strOptions = [strOptions, '''', OPTIONS.(f{1}), ''''];
        elseif iscell(OPTIONS.(f{1})) && ~isempty(OPTIONS.(f{1}))
            strOptions = [strOptions, sprintf('''%s'',', OPTIONS.(f{1}){:})];
        end
        strOptions = [strOptions, ' '];
    end
    FemMat = bst_history('add', FemMat, 'process_generate_fem', strOptions);

    % Save to database
    FemFile = file_unique(bst_fullfile(bst_fileparts(T1File), sprintf('tess_fem_%s_%dV.mat', OPTIONS.Method, length(FemMat.Vertices))));
    bst_save(FemFile, FemMat, 'v7');
    db_add_surface(iSubject, FemFile, FemMat.Comment);
    % Return success
    isOk = 1;
end


%% ===== GET FEM LABEL =====
function label = GetFemLabel(label)
%     switch lower(label)
%         case {'skin','scalp','head'}
%             label = 'scalp';
%         case {'bone','skull','outer','outerskull'}
%             label = 'skull';
%         case 'csf'
%             label = 'csf';
%         case {'brain','grey','gray','greymatter','graymatter','gm','cortex','inner','innerskull'}
%             label = 'gray';
%         case {'white','whitematter','wm'}
%             label = 'white';
%     end
    label = lower(label);
    if ~isempty(strfind(label, 'white')) || ~isempty(strfind(label, 'wm'))
        label = 'white';
    elseif ~isempty(strfind(label, 'brain')) || ~isempty(strfind(label, 'grey')) || ~isempty(strfind(label, 'gray')) || ~isempty(strfind(label, 'gm')) || ~isempty(strfind(label, 'cortex'))
        label = 'gray';
    elseif ~isempty(strfind(label, 'csf')) || ~isempty(strfind(label, 'inner'))
        label = 'csf';
    elseif ~isempty(strfind(label, 'bone')) || ~isempty(strfind(label, 'skull')) || ~isempty(strfind(label, 'outer'))
        label = 'skull';
    elseif ~isempty(strfind(label, 'skin')) || ~isempty(strfind(label, 'scalp')) || ~isempty(strfind(label, 'head'))
        label = 'scalp';
    end
end


%% ===== COMPUTE/INTERACTIVE =====
function ComputeInteractive(iSubject, iMris, BemFiles) %#ok<DEFNU>
    % Get inputs
    if (nargin < 3) || isempty(BemFiles)
        BemFiles = [];
    end
    if (nargin < 2) || isempty(iMris)
        iMris = [];
    end
    % Get default options
    OPTIONS = GetDefaultOptions();
    % If BEM surfaces are selected, the only possible method is "iso2mesh"
    if ~isempty(BemFiles) && iscell(BemFiles)
        OPTIONS.Method = 'iso2mesh';
        OPTIONS.BemFiles = BemFiles;
        OPTIONS.NbLayers = length(BemFiles);
    % Otherwise: Ask for method to use
    else
        res = java_dialog('question', [...
            '<HTML><B>Iso2mesh</B>:<BR>Call iso2mesh to create a tetrahedral mesh from the <B>BEM surfaces</B><BR>' ...
            'generated with Brainstorm (head, inner skull, outer skull).<BR>' ...
            'Iso2mesh is downloaded and installed automatically by Brainstorm.<BR><BR>' ...
            '<B>Brain2mesh</B>:<BR>Segment the <B>T1</B> (and <B>T2</B>) <B>MRI</B> with SPM12, mesh with Brain2Mesh.<BR>' ...
            'Brain2Mesh is downloaded and installed automatically by Brainstorm.<BR>' ...
            'SPM12 must be installed on the computer first.<BR>' ...
            'Website: https://www.fil.ion.ucl.ac.uk/spm/software/spm12<BR><BR>', ...
            '<B>SimNIBS</B>:<BR>Call SimNIBS to segment and mesh the <B>T1</B> (and <B>T2</B>) <B>MRI</B>.<BR>' ...
            'SimNIBS must be installed on the computer first.<BR>' ...
            'Website: https://simnibs.github.io/simnibs<BR><BR>' ...
            ... '<B>ROAST</B>:<BR>Call ROAST to segment and mesh the <B>T1</B> (and <B>T2</B>) MRI.<BR>' ...
            ... 'ROAST is downloaded and installed automatically when needed.<BR><BR>'...
            '<B>FieldTrip</B>:<BR>Call FieldTrip to segment and mesh the <B>T1</B> MRI.<BR>' ...
            'FieldTrip must be installed on the computer first.<BR>' ...
            'Website: http://www.fieldtriptoolbox.org/download<BR><BR>' ...
            ], 'FEM mesh generation method', [], {'Iso2mesh','Brain2Mesh','SimNIBS','FieldTrip'}, 'Iso2mesh');
        if isempty(res)
            return
        end
        OPTIONS.Method = lower(res);
        OPTIONS.NbLayers = 3;
    end
    
    % Other options: Switch depending on the method
    switch (OPTIONS.Method)
        case 'iso2mesh'
            % Ask merging method
            res = java_dialog('question', [...
                '<HTML>Iso2mesh function used to merge the input surfaces:<BR><BR>', ...
                '<B>MergeMesh</B>: Default option (faster).<BR>' ...
                'Simply concatenates the meshes without any intersection checks.<BR><BR>' ...
                '<B>MergeSurf</B>: Advanced option (slower).<BR>' ...
                'Concatenates and checks for intersections, split intersecting elements.<BR><BR>' ...
                ], 'FEM mesh generation (Iso2mesh)', [], {'MergeMesh','MergeSurf'}, 'MergeMesh');
            if isempty(res)
                return
            end
            OPTIONS.MergeMethod = lower(res);
            % Ask BEM meshing options
            res = java_dialog('input', {'Max tetrahedral volume (10=coarse, 0.0001=fine):', 'Percentage of elements kept (1-100%):'}, ...
                'FEM mesh', [], {num2str(OPTIONS.MaxVol), num2str(OPTIONS.KeepRatio)});
            if isempty(res)
                return
            end
            % Get new values
            OPTIONS.MaxVol    = str2num(res{1});
            OPTIONS.KeepRatio = str2num(res{2}) ./ 100;
            if isempty(OPTIONS.MaxVol) || (OPTIONS.MaxVol < 0.000001) || (OPTIONS.MaxVol > 20) || ...
                    isempty(OPTIONS.KeepRatio) || (OPTIONS.KeepRatio < 0.01) || (OPTIONS.KeepRatio > 1)
                bst_error('Invalid options.', 'FEM mesh', 0);
                return
            end

        case 'brain2mesh'
            % No extra options
            
        case 'simnibs'
            % Ask for the tissues to segment
            opts = {...
                '3 layers : brain, skull, scalp', ...
                '4 layers : brain, csf, skull, scalp', ...
                '5 layers : white, gray, csf, skull, scalp'};
            [res, isCancel] = java_dialog('radio', '<HTML> Select the model to segment  <BR>', 'Select Model', [], opts, 1);
            if isCancel
                return
            end
            switch res
                case 1,  OPTIONS.NbLayers = 3;
                case 2,  OPTIONS.NbLayers = 4;
                case 3,  OPTIONS.NbLayers = 5;
            end          
           % Ask for the Vertex density
           res = java_dialog('input', '<HTML>Vertex density:<BR>Number of nodes per mm2 of the surface meshes (0.1 - 1.5)', ...
               'SimNIBS Vertex Density', [], num2str(OPTIONS.VertexDensity));
           if isempty(res) || (length(str2num(res)) ~= 1)
               return
           end
           % Get the value
           OPTIONS.VertexDensity = str2num(res);

        case 'fieldtrip'
            % Ask for the tissues to segment
            opts = {...
                '3 layers : brain, skull, scalp', ...
                '4 layers : brain, csf, skull, scalp', ...
                '5 layers : white, gray, csf, skull, scalp'};
            [res, isCancel] = java_dialog('radio', '<HTML> Select the model to segment  <BR>', 'Select Model', [], opts, 1);
            if isCancel
                return
            end
            switch res
                case 1,  OPTIONS.NbLayers = 3;
                case 2,  OPTIONS.NbLayers = 4;
                case 3,  OPTIONS.NbLayers = 5;
            end
            % Ask user for the downsampling factor
            [res, isCancel]  = java_dialog('input', ['Downsample volume before meshing:' 10 '(integer, 1=no downsampling)'], ...
                'FieldTrip FEM mesh', [], num2str(OPTIONS.Downsample));
            if isCancel || isempty(str2double(res))
                return
            end
            OPTIONS.Downsample = str2double(res);
            % Ask user for the node shifting
            [res, isCancel]  = java_dialog('input', 'Shift the nodes to fit geometry [0-0.49]:', ...
                'FieldTrip FEM mesh', [], num2str(OPTIONS.NodeShift));
            if isCancel || isempty(str2double(res))
                return
            end
            OPTIONS.NodeShift = str2double(res);
            
%         case 'roast'
%             % Set parameters
%             % Ask user for the the tissu to segment :
%             opts = {...
%                 '5 Layers : white,gray, csf, skull, scalp',...
%                 '3 Layers : brain, skull, scalp'};
%             [res, isCancel] = java_dialog('radio', '<HTML> Select the model to segment  <BR>', 'Select Model',[],opts, 1);
%             if isCancel
%                 return
%             end
%             if res == 1
%                 OPTIONS.TissueLabels = {'white', 'gray', 'csf', 'skull', 'scalp'};
%             end
%             if res == 2
%                 OPTIONS.TissueLabels = {'brain', 'skull', 'scalp'};
%             end
%             OPTIONS.NbLayers = length(OPTIONS.TissueLabels);
%             % Ask user for the mesh element type :
%             [res, isCancel]  = java_dialog('question', [...
%                 '<HTML><B>Hexahedral Mesh</B>:<BR> Use the hexa element for the mesh , <BR>' ...
%                 '<B>Tetrahedral Mesh</B>:<BR> Use the tetra element for the mesh <BR>(experimental : converts the hexa to tetra)<BR>' ], ...
%                 'Mesh type', [], {'hexahedral','tetrahedral'}, 'tetrahedral');
%             if isCancel
%                 return
%             end
%             OPTIONS.MeshType = res;
    end

    % Open progress bar
    bst_progress('start', 'Generate FEM mesh', ['Generating FEM mesh (' OPTIONS.Method ')...']);
    % Generate FEM mesh
    try
        [isOk, errMsg] = Compute(iSubject, iMris, 1, OPTIONS);
        % Error handling
        if ~isOk
            bst_error(errMsg, 'FEM mesh', 0);
        elseif ~isempty(errMsg)
            java_dialog('msgbox', ['Warning: ' errMsg]);
        end
    catch
        bst_error();
        bst_error(['The FEM mesh generation failed.' 10 'Check the Matlab command window for additional information.' 10], 'Generate FEM mesh', 0);
    end
    % Close progress bar
    bst_progress('stop');
end



% %% ===== INSTALL ROAST =====
% function errMsg = InstallRoast(isInteractive)
%     % Initialize variables
%     errMsg = [];
%     curdir = pwd;
%     % Download URL
%     url = 'https://www.parralab.org/roast/roast-3.0.zip';
% 
%     % Check if already available in path
%     if exist('roast', 'file')
%         disp([10, 'ROAST path: ', bst_fileparts(which('roast')), 10]);
%         return;
%     end
%     % Local folder where to install ROAST
%     roastDir = bst_fullfile(bst_get('BrainstormUserDir'), 'roast');
%     exePath = bst_fullfile(roastDir, 'roast-3.0', 'roast.m');
%     % If dir doesn't exist in user folder, try to look for it in the Brainstorm folder
%     if ~isdir(roastDir)
%         roastDirMaster = bst_fullfile(bst_get('BrainstormHomeDir'), 'roast');
%         if isdir(roastDirMaster)
%             roastDir = roastDirMaster;
%         end
%     end
% 
%     % URL file defines the current version
%     urlFile = bst_fullfile(roastDir, 'url');
%     % Read the previous download url information
%     if isdir(roastDir) && file_exist(urlFile)
%         fid = fopen(urlFile, 'r');
%         prevUrl = fread(fid, [1 Inf], '*char');
%         fclose(fid);
%     else
%         prevUrl = '';
%     end
%     % If file doesnt exist: download
%     if ~isdir(roastDir) || ~file_exist(exePath) || ~strcmpi(prevUrl, url)
%         % If folder exists: delete
%         if isdir(roastDir)
%             file_delete(roastDir, 1, 3);
%         end
%         % Create folder
%         res = mkdir(roastDir);
%         if ~res
%             errMsg = ['Error: Cannot create folder' 10 roastDir];
%             return
%         end
%         % Message
%         if isInteractive
%             isOk = java_dialog('confirm', ...
%                 ['ROAST is not installed on your computer (or out-of-date).' 10 10 ...
%                 'Download and the latest version of ROAST?'], 'ROAST');
%             if ~isOk
%                 errMsg = 'Download aborted by user';
%                 return;
%             end
%         end
%         % Download file
%         zipFile = bst_fullfile(roastDir, 'roast.zip');
%         errMsg = gui_brainstorm('DownloadFile', url, zipFile, 'Download ROAST');
%         % If file was not downloaded correctly
%         if ~isempty(errMsg)
%             errMsg = ['Impossible to download ROAST:' 10 errMsg1];
%             return;
%         end
%         % Display again progress bar
%         bst_progress('text', 'Installing ROAST...');
%         % Unzip file
%         cd(roastDir);
%         unzip(zipFile);
%         file_delete(zipFile, 1, 3);
%         cd(curdir);
%         % Save download URL in folder
%         fid = fopen(urlFile, 'w');
%         fwrite(fid, url);
%         fclose(fid);
%     end
%     % If installed but not in path: add roast to path
%     if ~exist('roast', 'file')
%         addpath(bst_fileparts(exePath));
%         disp([10, 'ROAST path: ', bst_fileparts(roastDir), 10]);
%         % If the executable is still not accessible
%     else
%         errMsg = ['ROAST could not be installed in: ' roastDir];
%     end
% end


%% ===== INSTALL ISO2MESH =====
function errMsg = InstallIso2mesh(isInteractive)
    % Initialize variables
    errMsg = [];
    curdir = pwd;
    % Check if already available in path
    if exist('iso2meshver', 'file') && isdir(bst_fullfile(bst_fileparts(which('iso2meshver')), 'doc'))
        disp([10, 'Iso2mesh path: ', bst_fileparts(which('iso2meshver')), 10]);
        return;
    end

    % Get default url
    osType = bst_get('OsType', 0);
    switch (osType)
        case 'linux64',  url = 'https://github.com/fangq/iso2mesh/releases/download/v1.9.2/iso2mesh-1.9.2-linux64.zip';
        case 'mac32',    url = 'https://github.com/fangq/iso2mesh/releases/download/v1.9.2/iso2mesh-1.9.2-osx32.zip';
        case 'mac64',    url = 'https://github.com/fangq/iso2mesh/releases/download/v1.9.2/iso2mesh-1.9.2-osx64.zip';
        case 'win32',    url = 'https://github.com/fangq/iso2mesh/releases/download/v1.9.2/iso2mesh-1.9.2-win32.zip';
        case 'win64',    url = 'https://github.com/fangq/iso2mesh/releases/download/v1.9.2/iso2mesh-1.9.2-win32.zip';
        otherwise,       error(['Iso2mesh software does not exist for your operating system (' osType ').']);
    end

    % Local folder where to install iso2mesh
    isoDir = bst_fullfile(bst_get('BrainstormUserDir'), 'iso2mesh', osType);
    exePath = bst_fullfile(isoDir, 'iso2mesh', 'iso2meshver.m');
    % If dir doesn't exist in user folder, try to look for it in the Brainstorm folder
    if ~isdir(isoDir)
        isoDirMaster = bst_fullfile(bst_get('BrainstormHomeDir'), 'iso2mesh');
        if isdir(isoDirMaster)
            isoDir = isoDirMaster;
        end
    end

    % URL file defines the current version
    urlFile = bst_fullfile(isoDir, 'url');
    % Read the previous download url information
    if isdir(isoDir) && file_exist(urlFile)
        fid = fopen(urlFile, 'r');
        prevUrl = fread(fid, [1 Inf], '*char');
        fclose(fid);
    else
        prevUrl = '';
    end
    % If executable doesn't exist or is outdated: download
    if ~isdir(isoDir) || ~file_exist(exePath) || ~strcmpi(prevUrl, url)
        % If folder exists: delete
        if isdir(isoDir)
            file_delete(isoDir, 1, 3);
        end
        % Create folder
        res = mkdir(isoDir);
        if ~res
            errMsg = ['Error: Cannot create folder' 10 isoDir];
            return
        end
        % Message
        if isInteractive
            isOk = java_dialog('confirm', ...
                ['Iso2mesh is not installed on your computer (or out-of-date).' 10 10 ...
                'Download and the latest version of Iso2mesh?'], 'Iso2mesh');
            if ~isOk
                errMsg = 'Download aborted by user';
                return;
            end
        end
        % Download file
        zipFile = bst_fullfile(isoDir, 'iso2mesh.zip');
        errMsg = gui_brainstorm('DownloadFile', url, zipFile, 'Download Iso2mesh');
        % If file was not downloaded correctly
        if ~isempty(errMsg)
            errMsg = ['Impossible to download Iso2mesh automatically:' 10 errMsg];
            if ~exist('isdeployed', 'builtin') || ~isdeployed
                errMsg = [errMsg 10 10 ...
                    'Alternative download solution:' 10 ...
                    '1) Copy the URL below from the Matlab command window: ' 10 ...
                    '     ' url 10 ...
                    '2) Paste it in a web browser' 10 ...
                    '3) Save the file and unzip it' 10 ...
                    '4) Add the folder "iso2mesh" to your Matlab path.'];
            end
            return;
        end
        % Display again progress bar
        bst_progress('text', 'Installing Iso2mesh...');
        % Unzip file
        cd(isoDir);
        unzip(zipFile);
        file_delete(zipFile, 1, 3);
        cd(curdir);
        % Save download URL in folder
        fid = fopen(urlFile, 'w');
        fwrite(fid, url);
        fclose(fid);
    end
    % If installed but not in path: add to path
    if ~exist('iso2meshver', 'file') && isdir(bst_fullfile(bst_fileparts(which('iso2meshver')), 'doc'))
        addpath(bst_fileparts(exePath));
        disp([10, 'Iso2mesh path: ', bst_fileparts(exePath), 10]);
        % Set iso2mesh temp folder
        assignin('base', 'ISO2MESH_TEMP', bst_get('BrainstormTmpDir'));
    else
        errMsg = ['Iso2mesh could not be installed in: ' isoDir];
    end
end


%% ===== INSTALL BRAIN2MESH =====
function errMsg = InstallBrain2mesh(isInteractive)
    % Initialize variables
    errMsg = [];
    curdir = pwd;
    % Check if already available in path
    if exist('brain2mesh', 'file')
        disp([10, 'Brain2Mesh path: ', bst_fileparts(which('brain2mesh')), 10]);
        return;
    end
    % Download url
    url = 'https://neuroimage.usc.edu/bst/getupdate.php?d=Brain2Mesh_alpha.zip';
    % Local folder where to install iso2mesh
    installDir = bst_fullfile(bst_get('BrainstormUserDir'), 'brain2mesh');
    exePath = bst_fullfile(installDir, 'brain2mesh', 'brain2mesh.m');
    % If dir doesn't exist in user folder, try to look for it in the Brainstorm folder
    if ~isdir(installDir)
        installDirMaster = bst_fullfile(bst_get('BrainstormHomeDir'), 'brain2mesh');
        if isdir(installDirMaster)
            installDir = installDirMaster;
        end
    end

    % URL file defines the current version
    urlFile = bst_fullfile(installDir, 'url');
    % Read the previous download url information
    if isdir(installDir) && file_exist(urlFile)
        fid = fopen(urlFile, 'r');
        prevUrl = fread(fid, [1 Inf], '*char');
        fclose(fid);
    else
        prevUrl = '';
    end
    % If executable doesn't exist or is outdated: download
    if ~isdir(installDir) || ~file_exist(exePath) || ~strcmpi(prevUrl, url)
        % If folder exists: delete
        if isdir(installDir)
            file_delete(installDir, 1, 3);
        end
        % Create folder
        res = mkdir(installDir);
        if ~res
            errMsg = ['Error: Cannot create folder' 10 installDir];
            return
        end
        % Message
        if isInteractive
            isOk = java_dialog('confirm', ...
                ['Brain2Mesh is not installed on your computer (or out-of-date).' 10 10 ...
                'Download and the latest version of Brain2Mesh?'], 'Brain2Mesh');
            if ~isOk
                errMsg = 'Download aborted by user';
                return;
            end
        end
        % Download file
        zipFile = bst_fullfile(installDir, 'brain2mesh.zip');
        errMsg = gui_brainstorm('DownloadFile', url, zipFile, 'Download Brain2Mesh');
        % If file was not downloaded correctly
        if ~isempty(errMsg)
            errMsg = ['Impossible to download Brain2Mesh automatically:' 10 errMsg];
            if ~exist('isdeployed', 'builtin') || ~isdeployed
                errMsg = [errMsg 10 10 ...
                    'Alternative download solution:' 10 ...
                    '1) Copy the URL below from the Matlab command window: ' 10 ...
                    '     ' url 10 ...
                    '2) Paste it in a web browser' 10 ...
                    '3) Save the file and unzip it' 10 ...
                    '4) Add the folder "brain2mesh" to your Matlab path.'];
            end
            return;
        end
        % Display again progress bar
        bst_progress('text', 'Installing Brain2Mesh...');
        % Unzip file
        cd(installDir);
        unzip(zipFile);
        file_delete(zipFile, 1, 3);
        cd(curdir);
        % Save download URL in folder
        fid = fopen(urlFile, 'w');
        fwrite(fid, url);
        fclose(fid);
    end
    % If installed but not in path: add to path
    if ~exist('brain2mesh', 'file') && isdir(bst_fullfile(bst_fileparts(which('brain2mesh')), 'doc'))
        addpath(bst_fileparts(exePath));
        disp([10, 'Brain2Mesh path: ', bst_fileparts(exePath), 10]);
    else
        errMsg = ['Brain2Mesh could not be installed in: ' installDir];
    end
end


%% ===== INSTALL DUNEURO =====
function errMsg = InstallDuneuro(isInteractive)
    % Initialize variables
    errMsg = [];
    curdir = pwd;
    % Check if already available in path
    if exist('bst_duneuro', 'file')
        disp([10, 'bst-duneuro path: ', bst_fileparts(which('bst_duneuro')), 10]);
        return;
    end
    
    % === GET CURRENT ONLINE VERSION ===
    % Reading function: urlread replaced with webread in Matlab 2014b
    if (bst_get('MatlabVersion') <= 803)
        url_read_fcn = @urlread;
    else
        url_read_fcn = @webread;
    end
    % Read online version.txt
    try
        str = url_read_fcn('https://neuroimage.usc.edu/bst/getversion_duneuro.php');
    catch
        errMsg = 'Could not get current online version of bst_duneuro.';
        return;
    end
    if (length(str) < 6)
        return;
    end
    DuneuroVersion = str(1:6);
    % Get download URL
    url = ['https://neuroimage.usc.edu/bst/getupdate.php?d=bst_duneuro_' DuneuroVersion '.zip'];

    % Local folder where to install the program
    installDir = bst_fullfile(bst_get('BrainstormUserDir'), 'bst_duneuro');
    downloadDir = bst_get('BrainstormUserDir');
    exePath = bst_fullfile(installDir, 'bst_duneuro.m');
    % If dir doesn't exist in user folder, try to look for it in the Brainstorm folder
    if ~isdir(installDir)
        installDirMaster = bst_fullfile(bst_get('BrainstormHomeDir'), 'bst_duneuro');
        if isdir(installDirMaster)
            installDir = installDirMaster;
        end
    end

    % URL file defines the current version
    urlFile = bst_fullfile(installDir, 'url');
    % Read the previous download url information
    if isdir(installDir) && file_exist(urlFile)
        fid = fopen(urlFile, 'r');
        prevUrl = fread(fid, [1 Inf], '*char');
        fclose(fid);
    else
        prevUrl = '';
    end
    % If file doesnt exist: download
    if ~isdir(installDir) || ~file_exist(exePath) || ~strcmpi(prevUrl, url)
        % If folder exists: delete
        if isdir(installDir)
            file_delete(installDir, 1, 3);
        end
        % Message
        if isInteractive
            isOk = java_dialog('confirm', ...
                ['bst-duneuro is not installed on your computer (or out-of-date).' 10 10 ...
                'Download and the latest version of bst-duneuro?'], 'bst-duneuro');
            if ~isOk
                errMsg = 'Download aborted by user';
                return;
            end
        end
        % Download file
        zipFile = bst_fullfile(downloadDir, 'bst_duneuro.zip');
        errMsg = gui_brainstorm('DownloadFile', url, zipFile, 'Download bst-duneuro');
        % If file was not downloaded correctly
        if ~isempty(errMsg)
            errMsg = ['Impossible to download bst-duneuro:' 10 errMsg];
            return;
        end
        % Display again progress bar
        bst_progress('text', 'Installing bst-duneuro...');
        % Unzip file
        cd(downloadDir);
        unzip(zipFile);
        file_delete(zipFile, 1, 3);
        cd(curdir);
        % Save download URL in folder
        fid = fopen(urlFile, 'w');
        fwrite(fid, url);
        fclose(fid);
    end
    % If installed but not in path: add to path
    if ~exist('bst_duneuro', 'file')
        addpath(installDir);
        addpath(bst_fullfile(installDir, 'matlab'));
        addpath(bst_fullfile(installDir, 'matlab', 'external'));
        addpath(bst_fullfile(installDir, 'matlab', 'external', 'gibbon'));
        addpath(bst_fullfile(installDir, 'matlab', 'external', 'eig2nifti'));
        disp([10, 'bst-duneuro path: ', installDir, 10]);
        % If the executable is still not accessible
    else
        errMsg = ['bst-duneuro could not be installed in: ' installDir];
    end
end


%% ===== HEXA <=> TETRA =====
function NewFemFile = SwitchHexaTetra(FemFile, isInteractive) %#ok<DEFNU>
    % Install bst_duneuro if needed
    if ~exist('bst_duneuro', 'file')
        errMsg = InstallDuneuro(isInteractive);
        if ~isempty(errMsg) || ~exist('bst_duneuro', 'file')
            return;
        end
    end
    % Get file in database
    [sSubject, iSubject] = bst_get('SurfaceFile', FemFile);
    FemFullFile = file_fullpath(FemFile);
    % Get dimensions of the Elements variable
    elemSize = whos('-file', FemFullFile, 'Elements');
    % Check type of the mesh
    if isempty(elemSize) || (length(elemSize.size) ~= 2) || ~ismember(elemSize.size(2), [4 8])
        error(['Invalid FEM mesh file: ' FemFile]);
    elseif (elemSize.size(2) == 8)
        [iNewTess, NewFemFile] = fem_hexa2tetra(iSubject, FemFullFile, 'BSTFEM', isInteractive);
    elseif (elemSize.size(2) == 4)
        [iNewTess, NewFemFile] = fem_tetra2hexa(iSubject, FemFullFile, 'BSTFEM', isInteractive);
    end
end
