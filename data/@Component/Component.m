classdef Component
% COMPONENT(type, subType, variant, name) Contains all variable
% configurations for a model variant.
%    The variables are stored in the Variables struct as ModelVariable
%    objects. The SetupFunction is run when setting the component as
%    active. Components are managed by the ComponentManager class object.

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 1.4.2015
%   @updated 9.7.2015

properties
    Name = '';% The name of the preset ({Bremo14/Bremo15/Bus}/{Bremen/Hockenheim})
    Type = '';% Type of Component (Auto/Strecke/Atm/Eq/Last/Ems)
    SubType = '';% Can be empty or (Real/Virtuell)
    Variant = '';% Name of the model variant ({V8/V9/Bimaq/Simple})
    Variables = struct(); % All variables pertaining to the component
    SetupFunction = ''; % Function which sets up the components variables
    Documentation = ''; % Short documentation about the component
    
    IsExperimentRun = 0; % If yes, belongs to an experiment run
    BasedOn = ''; % The component it is based on (copied from)
end

methods
    function obj = Component(type, subType, variant, name)
        obj.Type = type;
        obj.SubType = subType;
        obj.Variant = variant;
        obj.Name = name;
    end
    
    function obj = AddVariable(obj, variable)
        obj.Variables.(variable.Name) = variable;
    end
    
    function obj = NewVariable(obj, name, value)
        obj.Variables.(name) = ModelVariable(name, value);
    end
    
    function obj = DeleteVariable(obj, name)
        obj.Variables = rmfield(obj.Variables, name);
    end
    
    function variable = GetVariable(obj, name)
        variable = obj.Variables.(name);
    end
    
    function names = GetVariableNames(obj)
        names = fieldnames(obj.Variables);
    end
    
	function documentation = GetDocumentation(obj)
        documentation = obj.Documentation;
    end
    
    function obj = SetDocumentation(obj, documentation)
        obj.Documentation = documentation;
    end
    
    % Get / Set Variable Properties ---------------------------------------
    
    function value = GetVariableValue(obj, name)
        if(isfield(obj.Variables, name))
            value = obj.Variables.(name).Value;
        else
            warning(['Variable does not exist: ' name])
            value = 0;
        end
    end
    
    function obj = SetVariableValue(obj, variable, entry)
        if(not(isfield(obj.Variables, variable)))
            obj.Variables.(variable) = ModelVariable(variable, 0);
        end
        obj.Variables.(variable).Value = entry;
    end
    
    function obj = SetVariableUnit(obj, variable, entry)
        if(not(isfield(obj.Variables, variable)))
            obj.Variables.(variable) = ModelVariable(variable, 0);
        end
        obj.Variables.(variable).Unit = entry;
    end
    
    function obj = SetVariableMin(obj, variable, entry)
        if(not(isfield(obj.Variables, variable)))
            obj.Variables.(variable) = ModelVariable(variable, 0);
        end
        obj.Variables.(variable).Min = entry;
    end
    
    function obj = SetVariableMax(obj, variable, entry)
        if(not(isfield(obj.Variables, variable)))
            obj.Variables.(variable) = ModelVariable(variable, 0);
        end
        obj.Variables.(variable).Max = entry;
    end
    
    function obj = SetVariableMinAction(obj, variable, entry)
        if(not(isfield(obj.Variables, variable)))
            obj.Variables.(variable) = ModelVariable(variable, 0);
        end
        obj.Variables.(variable).MinAction = entry;
    end
    
    function obj = SetVariableMaxAction(obj, variable, entry)
        if(not(isfield(obj.Variables, variable)))
            obj.Variables.(variable) = ModelVariable(variable, 0);
        end
        obj.Variables.(variable).MaxAction = entry;
    end
    
    function obj = SetVariableDocumentation(obj, variable, entry)
        if(not(isfield(obj.Variables, variable)))
            obj.Variables.(variable) = ModelVariable(variable, 0);
        end
        obj.Variables.(variable).Documentation = entry;
    end
    
    % IsEqual Functions ---------------------------------------------------

    function equal = IsTypeSubTypeComponentEqual(obj, component)
        % Wrapper function for IsTypeSubTypeEqual
        equal = obj.IsVariantEqual(component.Type, component.SubType, component.Variant);
    end
    
    function equal = IsTypeSubTypeEqual(obj, type, subType, ~)
        % Checks if everything upto the variant is equal / Checks that both
        % components belong to the same variant. Returns 1 if it is equal,
        % 0 if not
        typeEqual = strcmp(obj.Type, type);
        if(isempty(subType) && isempty(obj.SubType))
            % If the subType is empty, but represented by different null
            % values, i.e. [] and ''
            subTypeEqual = 1;
        else
            subTypeEqual = strcmp(obj.SubType, subType);
        end
        if(typeEqual && subTypeEqual)
            equal = 1;
        else
            equal = 0;
        end
    end
    
    function equal = IsVariantComponentEqual(obj, component)
        % Wrapper function for IsVariantEqual
        equal = obj.IsVariantEqual(component.Type, component.SubType, component.Variant);
    end
    
    function equal = IsVariantEqual(obj, type, subType, variant)
        % Checks if everything upto the variant is equal / Checks that both
        % components belong to the same variant. Returns 1 if it is equal,
        % 0 if not
        typeEqual = strcmp(obj.Type, type);
        if(isempty(subType) && isempty(obj.SubType))
            % If the subType is empty, but represented by different null
            % values, i.e. [] and ''
            subTypeEqual = 1;
        else
            subTypeEqual = strcmp(obj.SubType, subType);
        end
        variantEqual = strcmp(obj.Variant, variant);
        if(typeEqual && subTypeEqual && variantEqual)
            equal = 1;
        else
            equal = 0;
        end
    end
    
    function equal = IsNameComponentEqual(obj, component)
        % Wrapper function for IsNameEqual
        equal = obj.IsNameEqual(component.Type, component.SubType, component.Variant, component.Name);
    end
    
    function equal = IsNameEqual(obj, type, subType, variant, name)
        % Checks if everything upto the name is equal / Checks that both
        % components belong to the same variant and have the same name.
        % Returns 1 if it is equal, 0 if not
        typeEqual = strcmp(obj.Type, type);
        if(isempty(subType) && isempty(obj.SubType))
            subTypeEqual = 1;
        else
            subTypeEqual = strcmp(obj.SubType, subType);
        end
        variantEqual = strcmp(obj.Variant, variant);
        nameEqual = strcmp(obj.Name, name);
        if(typeEqual && subTypeEqual && variantEqual && nameEqual)
            equal = 1;
        else
            equal = 0;
        end
    end
    
    % Miscellaneous Functions ---------------------------------------------
    
    function obj = EvalVariableSetup(obj)
        try
            eval(obj.SetupFunction);
        catch
            warning(['Could not run setup function component: ' obj.Name]);
        end
    end
    
    function path = GetComponentPath(obj)
        componentsPath = ComponentManager.GetComponentsPath();
        if(isempty(obj.SubType))
            path = fullfile(componentsPath, obj.Type, obj.Variant, [obj.Name '.mat']);
        else
            path = fullfile(componentsPath, obj.Type, obj.SubType, obj.Variant, [obj.Name '.mat']);
        end
    end
    
    function text = GetBasedOnText(obj)
        text = ['Based on: ' obj.BasedOn];
    end
end

end

