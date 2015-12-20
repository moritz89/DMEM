classdef ExperimentRunManager < handle
%EXPERIMENTRUNMANAGER() The manager for all components.
%   All experiment runs are saved in the ExperimentRuns struct. The 
%   experiment name and run id of the active experiment run is found in
%   ActiveExperimentName and ActiveRunId. The active components and
%   variants of the preset mode are saved when entering the experiment
%   mode. They are set as active again when exiting the experiment mode.
%   ActiveStateChanged is used to indicate that the active component has
%   changed. When set to 1, the ActiveExperimentRunChanged event is 
%   triggered, and all GUI's are notified to update their state.

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 1.6.2015

properties
    ExperimentRuns = struct();
    ActiveExperimentName = '';
    ActiveRunId = 0;
    PresetModeVariants
    PresetModeComponents
    ActiveStateChanged = 0;
end

events
    ActiveExperimentRunChanged
end

methods
    function obj = ExperimentRunManager(varargin)
        loaded = 0; % Set to 1 once the experiment runs have been loaded
        if(not(isempty(varargin)))
            if(strcmp(varargin{1}, 'load backup'))
                % Load the backup file instead of the seperated files
                obj = obj.LoadExperimentRuns();
                loaded = 1;
            end
        end
        if(loaded == 0)
            obj = obj.LoadSeperatedExperimentRuns();
        end
    end

    function obj = NotifyExperimentRunChanged(obj)
        notify(obj,'ActiveExperimentRunChanged');
    end
    
    function SaveExperimentRuns(obj, fileName)
        projectRoot = project_paths();
        if(isempty(fileName))
            savePath = fullfile(projectRoot, 'backup', 'experiment_run_manager_bak');
        else
            savePath = fullfile(projectRoot, fileName);
        end
        save(savePath, 'obj');
    end
    
    function SaveSeperatedExperimentRuns(obj)
        % For each experiment name create a folder and save each experiment
        % run to a mat file
        
        for i = fieldnames(obj.ExperimentRuns)'
            for j = fieldnames(obj.ExperimentRuns.(i{:}))'
                % i = experimentName, j = 'runId'
                obj.SaveExperimentRun(obj.ExperimentRuns.(i{:}).(j{:}));
            end
        end
    end
    
    function obj = LoadExperimentRuns(obj, path)
        projectRoot = project_paths();
        if(isempty(path))
            loadPath = fullfile(projectRoot, 'backup', 'experiment_run_manager_bak');
        else
            loadPath = fullfile(projectRoot, fileName);
        end
        s = load(loadPath);
        obj = s.obj;
    end
    
    function obj = LoadSeperatedExperimentRuns(obj)
        experimentRunsPath = obj.GetExperimentRunsPath();
        % Find the component folders
        for i = dir(experimentRunsPath)'
        if(not(strcmp(i.name(1), '.')))
            for j = dir(fullfile(experimentRunsPath, i.name))'
            if(not(strcmp(j.name(1), '.')))
                if(strcmp(j.name(end-3:end), '.mat'))
                    s = load(fullfile(experimentRunsPath, i.name, j.name));
                    obj = obj.AddExperimentRun(s.experimentRun);
                end
            end
            end
        end
        end
        if(isempty(fieldnames(obj.ExperimentRuns)))
            fprintf(['No ExperimentRuns loaded by ExperimentRunManager. \n\t' ...
                'Searched in: ' experimentRunsPath '\n']);
        end
    end
    
    % Activate / Deactivate ExperimentRuns --------------------------------
    
    function obj = DeactivateExperimentRunMode(obj)
        % Deactivate the previous ExperimentRun
        obj.ClearExperimentRunFromComponentManager()
        obj.ActiveExperimentName = '';
        obj.ActiveRunId = 0;

        % Restore components and variants from the preset mode
        componentManager = evalin('base', 'componentManager');
        global variantManager;
        variantManager.SetAllNull();
        for i = obj.PresetModeVariants
            if(variantManager.SetVariant(i))
                mE = MException('ExperimentRunManager:DeactivateExperimentRunMode', ...
                    'Could not activate variant: %s',i.Name);
                throw(mE);
            end
        end
        obj.PresetModeVariants = [];
        for i = obj.PresetModeComponents
            componentManager = componentManager.SaveComponentToList(i);
        end
        obj.PresetModeComponents = [];
        assignin('base', 'componentManager', componentManager);
    end
    
    function obj = ActivateExperimentRunMode(obj)
        % Backup the component and variant state of the preset mode
        componentManager = evalin('base', 'componentManager');
        global variantManager;
        obj.PresetModeComponents = componentManager.GetAllActiveComponents();
        obj.PresetModeVariants = variantManager.GetAllActive();
        assignin('base', 'componentManager', componentManager);
        
        obj = obj.ActivateExperimentRun('', 0);
    end
    
    function obj = ActivateExperimentRun(obj, experimentName, runId)
        % Remove the Components inserted from the previously active
        % ExperimentRun into the ComponentManager
        obj.ClearExperimentRunFromComponentManager();

        % componentManager is changed in ClearExperimentRunFromComponentManager
        componentManager = evalin('base', 'componentManager');
        global variantManager;
        runIdNum = ExperimentRun.ParseRunId(runId);
        % Check for empty input
        if(isempty(experimentName) || runIdNum <= 0)
            % If empty, use the first experimentName and runId
            experimentNames = fieldnames(obj.ExperimentRuns);
            firstExperimentName = experimentNames(1);
            experimentName = firstExperimentName{:};
            runIds = fieldnames(obj.ExperimentRuns.(experimentName));
            firstRunId = runIds(1);
            runIdNum = ExperimentRun.ParseRunId(firstRunId{:});
        end
        % Activate the new ExperimentRun
        runIdChar = num2str(runIdNum);
        experimentRun = obj.ExperimentRuns.(experimentName).(['Run' runIdChar]);
        for i = experimentRun.Components
            componentManager = componentManager.SaveComponentToList(i);
            componentManager = componentManager.SetComponentAsActive(i);
        end
        variantManager.SetAllNull();
        for i = experimentRun.Variants
            variantManager.SetVariant(i);
        end
        
        obj.ActiveRunId = runIdNum;
        obj.ActiveExperimentName = experimentName;
        assignin('base', 'componentManager', componentManager);
    end
    
    function ClearExperimentRunFromComponentManager(obj)
        % If there is an active ExperimentRun, clear its components from
        % the componentManager
        if(not(isempty(obj.ActiveExperimentName)) && obj.ActiveRunId ~= 0)
            componentManager = evalin('base', 'componentManager');
            experimentRun = obj.ExperimentRuns.(obj.ActiveExperimentName). ...
                (['Run' num2str(obj.ActiveRunId)]);
            for i = experimentRun.Components
                componentManager = componentManager.DeleteComponent(i.Type, i.SubType, i.Variant, i.Name);
            end
            assignin('base', 'componentManager', componentManager);
        end
    end
    
    function state = IsExperimentRunMode(obj)
        if(isempty(obj.ActiveExperimentName) && obj.ActiveRunId == 0)
            state = 0;
        else
            state = 1;
        end
    end
    
    % Get / Set ExperimentRuns --------------------------------------------

    function obj = AddExperimentRun(obj, experimentRun)
        % Add an experimentRun to the ExperimentRunManager. If the
        % experimentName group does not exist, create the respective field.
        % Overwrites existing ExperimentRuns if the name and id match
        
        % Create the field if it does not exist
        if(not(isfield(obj.ExperimentRuns, experimentRun.ExperimentName)))
            obj.ExperimentRuns.(experimentRun.ExperimentName) = struct();
        end
        obj.ExperimentRuns.(experimentRun.ExperimentName).(['Run' num2str(experimentRun.RunId)]) = experimentRun;
    end

    function obj = NewExperimentRun(obj, experimentName, runId)
        % Create a new ExperimentRun. If experimentName is empty, use the
        % activeExperimentName. If runId is empty, use the next runId in
        % the experimentName group. Does not set it as active
        if(isempty(experimentName))
            [experimentName, runIdNum] = obj.NextExperimentNameAndRunId(runId);
        else
            runIdNum = ExperimentRun.ParseRunId(runId);
        end
        % Create a new experiment run and set it as active
        experimentRun = ExperimentRun(experimentName, runIdNum);
        obj = obj.AddExperimentRun(experimentRun);
    end

    function obj = DeleteExperimentRun(obj, experimentName, runId)
        % Delete the ExperimentRun and its struct field if no other runs in
        % the experimentName group any longer exist. Clear the active
        % ExperimentName and RunId values if they become invalid
        runIdNum = ExperimentRun.ParseRunId(runId);
        if(not(isfield(obj.ExperimentRuns.(experimentName), ['Run' num2str(runIdNum)])))
            % If the ExperimentRun to be delete does not exist, abort
            return;
        end
        
        lRuns = length(fieldnames(obj.ExperimentRuns.(experimentName)));
        if(lRuns <= 1)
            % If there are no ExperimentRuns in the experimentName struct,
            % delete the struct field
            obj.ExperimentRuns = rmfield(obj.ExperimentRuns, experimentName);
        else
            obj.ExperimentRuns.(experimentName) = rmfield(obj.ExperimentRuns.(experimentName), ['Run' num2str(runIdNum)]);
        end
        % Clear the active ExperimentName and RunId values if the active
        % experiment run was deleted
        if(strcmp(experimentName, obj.ActiveExperimentName) && runIdNum == obj.ActiveRunId)
            obj.ActiveExperimentName = '';
            obj.ActiveRunId = 0;
        end
    end
    
    function obj = DeleteActiveExperimentRun(obj)
        % Delete the active experiment run. Please note that this will
        % clear the active experiment name and run id values.
        
        obj = obj.DeleteExperimentRun(obj.ActiveExperimentName, obj.ActiveRunId);
    end
    
    function experimentRun = GetExperimentRun(obj, experimentName, runId)
        runIdNum = ExperimentRun.ParseRunId(runId);
        experimentNameExists = isfield(obj.ExperimentRuns, experimentName);
        runIdExists = 0;
        if(experimentNameExists)
            runIdExists = isfield(obj.ExperimentRuns.(experimentName), ['Run' num2str(runIdNum)]);
        end
        if(experimentNameExists && runIdExists)
            experimentRun = obj.ExperimentRuns.(experimentName).(['Run' num2str(runIdNum)]);
        else
            experimentRun = ExperimentRun(experimentName, runIdNum);
        end
    end
    
    function experimentRun = GetActiveExperimentRun(obj)
        % Returns the active Experiment Run
        
        % If an active experimentRun does not exist, select the first one
        experimentNameExists = isfield(obj.ExperimentRuns, obj.ActiveExperimentName);
        runIdExists = 0;
        if(experimentNameExists)
            runIdExists = isfield(obj.ExperimentRuns.(obj.ActiveExperimentName), ['Run' num2str(obj.ActiveRunId)]);
        end
        if(not(experimentNameExists) || not(runIdExists))
            experimentNames = fieldnames(obj.ExperimentRuns);
            firstExperimentName = experimentNames(1);
            obj.ActiveExperimentName = firstExperimentName{:};
            runIds = fieldnames(obj.ExperimentRuns.(obj.ActiveExperimentName));
            firstRunId = runIds(1);
            obj.ActiveRunId = ExperimentRun.ParseRunId(firstRunId{:});
        end
        
        experimentRun = obj.ExperimentRuns.(obj.ActiveExperimentName).(['Run' num2str(obj.ActiveRunId)]);
    end
    
    function [experimentName, runId] = GetActiveExperimentNameAndRunId(obj)
        experimentName = obj.ActiveExperimentName;
        runId = obj.ActiveRunId;
    end
    
    function obj = SetActiveExperimentRun(obj, experimentName, runId)
        runIdNum = ExperimentRun.ParseRunId(runId);
        obj.ActiveExperimentName = experimentName;
        obj.ActiveRunId = runIdNum;
        experimentRun = obj.GetActiveExperimentRun();
        experimentRun.LoadSavedVariants();
        experimentRun.LoadSavedComponents();
        % Updates all GUI's listening for experimentRun changes
        obj.NotifyExperimentRunChanged();
    end
    
    function obj = ActivateNextExperimentRun(obj, experimentName, runId)
        % Set a new ActiveExperimentRun active. If ExperimentName no longer
        % exist, take the first ExperimentName. The same applies to RunId
        
        % If no experiment run with the experiment name exists, use the
        % first experiment name and run id
        if(not(isfield(obj.ExperimentRuns, experimentName)))
            experimentNames = fieldnames(obj.ExperimentRuns);
            firstExperimentName = experimentNames(1);
            nextExperimentName = firstExperimentName{:};
            
            runIds = fieldnames(obj.ExperimentRuns.(nextExperimentName));
            firstRunId = runIds(1);
            nextRunId = ExperimentRun.ParseRunId(firstRunId);
        else
            % Set the default values if a next higher experiment run can
            % not be found.
            nextExperimentName = experimentName;
            runIds = fieldnames(obj.ExperimentRuns.(experimentName));
            firstRunId = runIds(1);
            nextRunId = ExperimentRun.ParseRunId(firstRunId{:});
            % Search for the next higher experiment run
            for i = fieldnames(obj.ExperimentRuns.(experimentName))'
                if(runId < ExperimentRun.ParseRunId(i{:}))
                    nextRunId = ExperimentRun.ParseRunId(i{:});
                    break;
                end
            end
        end
        obj = obj.SetActiveExperimentRun(nextExperimentName, nextRunId);
    end
    
    function obj = SetActiveExperimentName(obj, experimentName)
        if(not(strcmp(experimentName, obj.ActiveExperimentName)))
            runIds = fieldnames(obj.ExperimentRuns.(experimentName));
            runId = runIds(1);
            obj = obj.SetActiveExperimentRun(experimentName, runId{:});
        end
    end
    
    function obj = SetActiveRunId(obj, runId)
        obj = obj.SetActiveExperimentRun(obj.ActiveExperimentName, runId);
    end
        
    function [list, index] = GetExperimentNames(obj)
        list = fieldnames(obj.ExperimentRuns);
        list = sort(list);
        index = 1;
        for i = 1:length(list)
            listI = list(i);
            if(strcmp(listI{:}, obj.ActiveExperimentName))
                index = i;
                return;
            end
        end
    end
    
    function [list, index] = GetRunIds(obj, experimentName)
        list = fieldnames(obj.ExperimentRuns.(experimentName));
        list = sort(list);
        index = 1;
        for i = 1:length(list)
            listI = list(i);
            if(ExperimentRun.ParseRunId(listI{:}) == obj.ActiveRunId)
                index = i;
                return;
            end
        end
    end
    
    function [list, index] = GetActiveRunIds(obj)
        if(not(isempty(obj.ActiveExperimentName)))
            [list, index] = obj.GetRunIds(obj.ActiveExperimentName);
        else
            list = [];
            index = 0;
        end
    end
    
    function state = IsExperimentRun(obj, experimentName, runId)
        state = 0;
        runIdNum = ExperimentRun.ParseRunId(runId);
        if(isfield(obj.ExperimentRuns, experimentName))
            if(isfield(obj.ExperimentRuns.(experimentName), ['Run' num2str(runIdNum)]))
                state = 1;
            end
        end
    end
    
    % ---
    
    function [experimentName, runIdNum] = NextExperimentNameAndRunId(obj, runId)
        runIdNum = ExperimentRun.ParseRunId(runId);
        if(isempty(obj.ActiveExperimentName))
            % Need atleast a valid experimentName
            experimentName = '';
            runIdNum = 0;
            return;
        end
        experimentName = obj.ActiveExperimentName;
        % If the run id is not valid, try to derive a valid run id
        if(not(isfield(obj.ExperimentRuns, experimentName)) && isnan(runIdNum))
            % If there exist no other experiment runs with the same name
            % and the run id is not valid set the run id as one and later 
            % create a new field in experimentRunManager with the
            % experiment name
            runIdNum = 1;
        elseif(runIdNum < 1 || isnan(runIdNum))
            % Find the highest run id and set the active run id one higher
            runIdNum = 1;
            for i = fieldnames(obj.ExperimentRuns.(experimentName))'
                if(obj.ExperimentRuns.(experimentName).(i{:}).RunId >= runIdNum)
                    runIdNum = obj.ExperimentRuns.(experimentName).(i{:}).RunId + 1;
                end
            end
        end
    end
    
    % Save / Load Components / Variants to ExperimentRun ------------------
    
    function obj = SaveComponentToActiveExperimentRun(obj, component)
        experimentRun = obj.GetActiveExperimentRun();
        experimentRun = experimentRun.AddComponent(component);
        obj = obj.AddExperimentRun(experimentRun);
    end
    
    function obj = SaveVariantsToActiveExperimentRun(obj)
        obj.ExperimentRuns.(obj.ActiveExperimentName).(['Run' num2str(obj.ActiveRunId)]) = ...
            obj.ExperimentRuns.(obj.ActiveExperimentName).(['Run' num2str(obj.ActiveRunId)]).SaveActiveVariants();
    end
    
    function LoadComponentFromActiveExperimentRun(obj, type, subType, variant)
        componentManager = evalin('base', 'componentManager');
        component = obj.GetActiveExperimentRun.GetComponent(type, subType, variant);
        if(not(isempty(component)))
            componentManager = componentManager.AddComponent(component);
            componentManager = componentManager.SetComponentAsActive(component);
            assignin('base', 'componentManager', componentManager);
        else
            warning('Component not found');
        end
    end
    
    % Load / Save Simulation Data -----------------------------------------
    
    function obj = SaveSimulationToActive(obj, simOut)
        obj.ExperimentRuns.(obj.ActiveExperimentName).(['Run' num2str(obj.ActiveRunId)]).SimOut = simOut;
    end
    
    function obj = LoadRunFromActive(obj)
        experimentRun = obj.GetActiveExperimentRun();
        experimentRun = experimentRun.LoadRunToSdi();
        obj = obj.AddExperimentRun(experimentRun);
    end
    
    function obj = RemoveRunFromActive(obj)
        experimentRun = obj.GetActiveExperimentRun();
        experimentRun = experimentRun.RemoveRunFromSdi();
        obj = obj.AddExperimentRun(experimentRun);
    end
    
    % Notify Callbacks ----------------------------------------------------
    
    function obj = OnActiveExperimentNameChange(obj, experimentName)
        if(not(strcmp(obj.ActiveExperimentName, experimentName)))
            obj.ActiveExperimentName = experimentName;
            notify(obj, 'ActiveExperimentRunChanged');
        end
    end
    
    function obj = OnActiveRunIdChange(obj, runId)
        runIdNum = ExperimentRun.ParseRunId(runId);
        if(obj.ActiveRunId ~= runIdNum)
            obj.ActiveRunId = runIdNum;
            notify(obj, 'ActiveExperimentRunChanged');
        end
    end
end

methods (Static)
	function SaveExperimentRun(experimentRun)
        % Get the experiment runs path
        experimentRunsPath = ExperimentRunManager.GetExperimentRunsPath();
        % Concatenate the directory to save the component in
        experimentRunDir = fullfile(experimentRunsPath, experimentRun.ExperimentName);
        % Create the dir if it does not exist
        if(not(isdir(experimentRunDir)))
            mkdir(experimentRunDir);
        end
        experimentRunPath = fullfile(experimentRunDir, [experimentRun.ExperimentName ...
            '_Run' num2str(experimentRun.RunId)]);
        save(experimentRunPath, 'experimentRun');
    end
    
    function path = GetExperimentRunsPath()
        [projectRoot, ~] = project_paths();
        path = fullfile(projectRoot, 'data', 'experiment_runs');
    end
end
end
