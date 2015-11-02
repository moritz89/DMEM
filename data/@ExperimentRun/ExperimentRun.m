classdef ExperimentRun
% EXPERIMENTRUN(experimentName, runNumber) Each instance conatins the
%   signals, variants, components, and documentation of an experiment run

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 11.6.2015
%   @updated 9.7.2015

properties
    % Identification
    ExperimentName = '';
    RunId = 0;
    % Result related information
    Author
    Supervisor
    DspaceModel
    DateCreated = now;
    ExternalScriptName
    ExperimentDocumentation
    RunDocumentation
    % Simulink Data Inspector
    SimOut
    SdiRunId = 0;
    % Script Callbacks
    PreviewScript = '';
    EvaluationScript = '';
    SdiPreparationScript = '';
    % Variants and Components
    Variants = [];
    Components = [];
end

methods
    function obj = ExperimentRun(experimentName, runNumber)
        obj.ExperimentName = experimentName;
        if(runNumber < 1)
            obj.RunId = 1;
        else
            obj.RunId = runNumber;
        end
    end
    
    % Variant related functions -------------------------------------------
    
    function obj = AddVariant(obj, variant)
        % Add a variant to the variants list. Use slots = 0 for no slot
        
        for i = 1:length(obj.Variants)
            % If the component with the same type exists, overwrite it
            if(obj.Variants(i).IsTypeSlotVariantEqual(variant))
                obj.Variants(i) = variant;
                return;
            end
        end
        % Else prepend it to the list of components
        obj.Variants = [obj.Variants variant];
    end
    
    function obj = RemoveVariant(obj, type, slot)
        % Remove a variant from the variants list. Use slot = 0 if the
        % variant does not have slots and subType = '' for empty subType
        
        for i = 1:length(obj.Variants)
            % If the component with the same type exists, remove it
            if(obj.Variants(i).IsTypeSlotEqual(type, slot))
                if(i == 1)
                    % If it is the first item in the list
                    obj.Variants = obj.Variants(i+1:end);
                elseif(i == length(obj.Variants))
                    % If it is the last item in the list
                    obj.Variants = obj.Variants(1:i-1);
                else
                    % If it is in the middle of the list
                    obj.Variants = [obj.Variants(1:i-1) obj.Variants(i+1:end)];
                end
                return;
            end
        end
    end
    
    function obj = SaveActiveVariants(obj)
        % Save all active variants
        
        global variantManager;
        obj.Variants = variantManager.GetAllActive();
    end
    
    function LoadSavedVariants(obj)
        % Activate the saved variants to the variantManager
        
        global variantManager;
        variantManager.SetAllNull();
        for i = obj.Variants
            variantManager.SetVariant(i);
        end
    end
    
    % Component related functions -----------------------------------------
    
    function obj = AddComponent(obj, component)
        % Add a component to the list of components. Overwrite component if
        % the same type/variant of component already exists
        
        % Rename Component to mark it as belonging to an experimentRun
        if(not(component.IsExperimentRun))
            component.BasedOn = component.Name;
        end
        component.IsExperimentRun = 1;
        component.Name = 'ExperimentRun';
        for i = 1:length(obj.Components)
            % If the component with the same type/variant exists, overwrite it
            if(obj.Components(i).IsTypeSubTypeComponentEqual(component))
                obj.Components(i) = component;
                return;
            end
        end
        % Else prepend it to the list of components
        obj.Components = [obj.Components component];
    end
    
    function component = GetComponent(obj, type, subType, variant)
        for i = obj.Components
            if(i.IsVariantEqual(type, subType, variant))
                component = i;
                return;
            end
        end
        component = [];
    end
    
    function obj = RemoveComponent(obj, type, subType)
        % Remove a component from the list of components
        for i = 1:length(obj.Components)
            if(obj.Components(i).IsTypeSubTypeEqual(type, subType))
                if(i == 1)
                    obj.Components = obj.Components(i+1:end);
                elseif(i == length(obj.Components))
                    obj.Components = obj.Components(1:i-1);
                else
                    obj.Components = [obj.Components(1:i-1) obj.Components(i+1:end)];
                end
                return;
            end 
        end
    end
    
    function obj = SaveActiveComponents(obj)
        componentManager = evalin('base', 'componentManager');
        obj.Components = componentManager.GetAllActiveComponents();
        % Set the ExperimentRun flag in the components
        for i = 1:length(obj.Components)
            obj.Components(i).Name = 'ExperimentRun';
        end
    end
    
    function LoadSavedComponents(obj)
        componentManager = evalin('base', 'componentManager');
        for i = obj.Components
            componentManager = componentManager.SaveComponentToList(i);
            componentManager = componentManager.SetComponentAsActive(i);
        end
        assignin('base', 'componentManager', componentManager);
    end
    
    % SDI Signals
    function obj = LoadRunToSdi(obj)
        % Loads the Sim data to the SDI as a Run. If the run already exists,
        % overwrite the previous run.
        if(Simulink.sdi.isValidRunID(obj.SdiRunId))
            Simulink.sdi.deleteRun(obj.SdiRunId);
        end
        simOut = obj.SimOut;
        obj.SdiRunId = Simulink.sdi.createRun([obj.ExperimentName ': Run' ...
            num2str(obj.RunId)], 'vars', simOut);
        eval(obj.SdiPreparationScript);
        Simulink.sdi.refresh();
    end
    
    function obj = RemoveRunFromSdi(obj)
        % Removes the Run from the SDI
        if(Simulink.sdi.isValidRunID(obj.SdiRunId))
            Simulink.sdi.deleteRun(obj.SdiRunId);
        end
    end
end

methods (Static)
    function runIdNum = ParseRunId(runId)
        if(not(isnumeric(runId)))
            % Assume runId == '2'
            runIdNum = str2double(runId);
            if(isnan(runIdNum))
                % Assume runId == 'run2'
                runIdNum = str2double(runId(4:length(runId)));
            end
        else
            % Assume runId == 2
            runIdNum = runId;
        end
    end
end
end
