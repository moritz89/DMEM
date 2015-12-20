classdef ComponentManager
% COMPONENTMANAGER() The manager for all components.
%   Components are structured according to their type and variant:
%   Auto/Strecke/Ems:
%       (Type).(Variant)
%       (Type).([Variant 'List']).(Name)
%   Atm/Last/Eq/Gsq:
%       (Type).(SubType).(Variant)
%       (Type).(SubType).([Variant 'List']).(Name)
%
%   The currently active component for a given variant model is copied from
%   its respective 'List' struct and copied to the struct with its name,
%   i.e. for the 'V9' model variant of type 'Auto', the active component is
%   stored in Auto.V9 and all components for that variant in Auto.V9List
%   with their name being the fieldname in Auto.V9List
%
%   The logic for most manipulations has already been implemented in setter
%   and getter functions for each component type (Auto, Eq, Atm, ...).
%   Miscellansous functions are located at the end.
%   Only one instance of the class should be created (singleton)
    
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 5.6.2015
    
properties
    % DriveSim related components -----------------------------------------
    Auto = struct();
    Strecke = struct();
    
    % Energy Management System related components -------------------------
    Ems = struct();
    
    % Hardware related components -----------------------------------------
    Gsq = struct();
    Atm = struct();
    Last = struct();
    Eq = struct();
end

methods
    function obj = ComponentManager(varargin)
        loaded = 0; % Set to 1 once the components have been loaded
        if(not(isempty(varargin)))
            if(strcmp(varargin{1}, 'load backup'))
                % Load the backup file instead of the seperated files
                obj = obj.LoadComponents();
                loaded = 1;
            end
        end
        if(loaded == 0)
            obj = obj.LoadSeperatedComponents();
        end
        obj = obj.Initialize();
        obj = obj.CheckComponents();
    end
                
    function obj = Initialize(obj)
        % Set the first object in each list as the active object
        for i = fieldnames(obj)'
            for j = fieldnames(obj.(i{:}))'
                if(strcmp(j{:}, 'Real') || strcmp(j{:}, 'Virtuell'))
                    % It is an Atm/Last/Eq/Gsq type
                    for k = fieldnames(obj.(i{:}).(j{:}))'
                        lK = length(k{:});
                        if(lK >= 4)
                            if(strcmp(k{:}(lK-3:lK), 'List'))
                                fields = fieldnames(obj.(i{:}).(j{:}).(k{:}));
                                if(not(isempty(fields)))
                                    field1 = fields(1);
                                    obj.(i{:}).(j{:}).(k{:}(1:lK-4)) = obj.(i{:}).(j{:}).(k{:}).(field1{:});
                                end
                            end
                        end
                    end
                else
                    % It is an Auto/Strecke/Ems type
                    lJ = length(j{:});
                    if(lJ >= 4)
                        if(strcmp(j{:}(lJ-3:lJ), 'List'))
                            fields = fieldnames(obj.(i{:}).(j{:}));
                            if(not(isempty(fields)))
                                field1 = fields(1);
                                obj.(i{:}).(j{:}(1:lJ-4)) = obj.(i{:}).(j{:}).(field1{:});
                            end
                        end
                    end
                end
            end
        end
    end
    
    function obj = CheckComponents(obj)
        % Check if for each variant its required components exist. If they
        % do not, create them. For more detail, see CreateComponentIfEmpty.
        % I.e., if the variant V10 for DriveSim exists but not its 
        % respective components, create the Auto and
        % Strecke List structs (Auto.V10List, Strecke.V10List) as well as
        % the active component struct (Auto.V10, Strecke.V10) and populate
        % them with empty components.
        global variantManager;
        % Check Auto
        [list, ~] = variantManager.GetDriveSim();
        for i = list
            obj = CreateComponentIfEmpty(obj, i{:}, 'Auto', 0);
        end
        % Check Strecke
        [list, ~] = variantManager.GetDriveSim();
        for i = list
            obj = CreateComponentIfEmpty(obj, i{:}, 'Strecke', 0);
        end
        % Check Ems
        [list, ~] = variantManager.GetEms();
        for i = list
            obj = CreateComponentIfEmpty(obj, i{:}, 'Ems', 0);
        end
        % Check Atm. Since the variants returned for all slots are equal,
        % only the first has to be tested
        [list, ~] = variantManager.GetAtm(1);
        for i = list
            obj = CreateComponentIfEmpty(obj, i{:}, 'Atm', 1);
        end
        % Check Last
        [list, ~] = variantManager.GetLast(1);
        for i = list
            obj = CreateComponentIfEmpty(obj, i{:}, 'Last', 1);
        end
        % Check Eq. Since the variants returned for all slots are equal,
        % only the first has to be tested
        [list, ~] = variantManager.GetEq(1);
        for i = list
            obj = CreateComponentIfEmpty(obj, i{:}, 'Eq', 1);
        end
        % Check Gsq
        [list, ~] = variantManager.GetGsq(1);
        for i = list
            obj = CreateComponentIfEmpty(obj, i{:}, 'Gsq', 1);
        end
        
        function obj = CreateComponentIfEmpty(obj, variantString, type, hasSubType)
            % Only to be used by CheckComponents() function. If the component
            % for the selected variant does not exist, create it. The List
            % struct and the respective active component struct are
            % created.
            if(not(strcmp(variantString, 'Null')))
                % Extract the variant type from the variant string
                if(not(hasSubType))
                    variant = variantString;
                else
                    % For variants with subtypes, the subtype is appended to
                    % the variant name, either 'Real' or 'Virtuell'
                    if(strcmp(variantString(1:4), 'Real'))
                        subType = 'Real';
                        variant = variantString(5:length(variantString));
                    else
                        subType = 'Virtuell';
                        variant = variantString(9:length(variantString));
                    end
                end
                % Create a new component list and add a component if it is
                % empty or does not exist
                variantList = ([variant 'List']);
                % The structure differs for variants with or without subtypes
                if(not(hasSubType))
                    % It is of type Auto/Strecke/Ems.
                    if(isfield(obj.(type), variantList))
                        % If the List struct exists and is empty or if it does
                        % not exist, add empty components and set their
                        % respective active struct field
                        if(isempty(obj.(type).(variantList)))
                            component = Component(type, '', variant, 'Initial');
                            obj = obj.AddComponent(component);
                            obj = obj.SetComponentAsActive(component);
                        end
                    else
                        component = Component(type, '', variant, 'Initial');
                        obj = obj.AddComponent(component);
                        obj = obj.SetComponentAsActive(component);
                    end
                else
                    % It is of type Atm/Last/Eq/Gsq
                    if(isfield(obj.(type), subType))
                    if(isfield(obj.(type).(subType), variantList))
                        % If the List struct exists and is empty or if it does
                        % not exist, add empty components and set their
                        % respective active struct field
                        if(isempty(obj.(type).(subType).(variantList)))
                            component = Component(type, subType, variant, 'Initial');
                            obj = obj.AddComponent(component);
                            obj = obj.SetComponentAsActive(component);
                        end
                    else
                        component = Component(type, subType, variant, 'Initial');
                        obj = obj.AddComponent(component);
                        obj = obj.SetComponentAsActive(component);
                    end
                    end
                end
            end
        end
    end
    
    % Save / Load Functions -----------------------------------------------
    
    function obj = LoadComponents(obj, fileName)
        % Loads the components from the 'component_manager_bak' file if
        % 'path' is empty else from the file specified in 'path'
        projectRoot = project_paths();
        if(isempty(fileName))
            loadPath = fullfile(projectRoot, 'backup', 'component_manager_bak');
        else
            loadPath = fullfile(projectRoot, fileName);
        end
        S = load(loadPath);
        obj = S.obj;
    end
    
    function obj = LoadSeperatedComponents(obj)
        componentsPath = obj.GetComponentsPath();
        % Find the component folders
        for i = dir(componentsPath)'
        % Exclude Unix '.', '..', and hidden directories
        if(not(strcmp(i.name(1), '.')))
            for j = dir(fullfile(componentsPath, i.name))'
            if(not(strcmp(j.name(1), '.')))
                % The dir contains Atm/Last/Eq/Gsq components
                if(strcmp(j.name, 'Real')|| strcmp(j.name, 'Virtuell'))
                    for k = dir(fullfile(componentsPath, i.name, j.name))'
                    if(not(strcmp(k.name(1), '.')))
                        for l = dir(fullfile(componentsPath, i.name, j.name, k.name))'
                        if(not(strcmp(l.name(1), '.')))
                            % i = Atm/Eq/... j = Real/Virtuell
                            % k = Bremergy/Htuc/... l = Original/Fast/...
                            if(strcmp(l.name(end-3:end), '.mat'))
                                S = load(fullfile(componentsPath, i.name, j.name, k.name, l.name));
                                obj = obj.SaveComponentToList(S.component);
                            end
                        end
                        end
                    end
                    end
                else
                    for k = dir(fullfile(componentsPath, i.name, j.name))'
                    if(not(strcmp(k.name(1), '.')))
                        % i = Auto/Ems/... j = V9/M2Eq5/...
                        % k = Bremen-Hamburg/VwGolf/...
                        if(strcmp(k.name(end-3:end), '.mat'))
                            S = load(fullfile(componentsPath, i.name, j.name, k.name));
                            obj = obj.SaveComponentToList(S.component);
                        end
                    end
                    end
                end
            end
            end
        end
        end
        noAuto = isempty(fieldnames(obj.Auto));
        noStrecke = isempty(fieldnames(obj.Strecke));
        noEms = isempty(fieldnames(obj.Ems));
        noAtm = isempty(fieldnames(obj.Atm));
        noLast = isempty(fieldnames(obj.Last));
        noEq = isempty(fieldnames(obj.Eq));
        noGsq = isempty(fieldnames(obj.Gsq));
        if(noAuto && noStrecke && noEms && noAtm && noLast && noEq && noGsq)
            fprintf(['No Components loaded by ComponentManager. \n\t' ...
                'Searched in: ' componentsPath '\n']);
        end
    end
    
    function SaveComponents(obj, fileName)
        % Saves the components from the 'component_manager_bak' file if
        % 'path' is empty else to the file specified in 'path'
        projectRoot = project_paths;
        if(isempty(fileName))
            savePath = fullfile(projectRoot, 'backup', 'component_manager_bak');
        else
            savePath = fullfile(projectRoot, fileName);
        end
        save(savePath, 'obj');
    end
    
    function SaveSeperatedComponents(obj)
        % Save active components to their respective list
        for i = fieldnames(obj)' 
            for j = fieldnames(obj.(i{:}))'
                % It is an Atm/Last/Eq/Gsq Component
                if(strcmp(j{:}, 'Real') || strcmp(j{:}, 'Virtuell'))
                    for k = fieldnames(obj.(i{:}).(j{:}))'
                        % If there is no 'List' suffix, save the active component
                        if(isempty(regexp(k{:}, 'a*List$', 'ONCE')))
                            % i = 'Atm'/'Eq'/..., j = 'Real'/'Virtuell',
                            % k = 'Bremergy'/'Htuc'/...
                            component = obj.(i{:}).(j{:}).(k{:});
                            obj.SaveComponentToList(component);
                        end
                    end
                % It is an Auto/Strecke/Ems Component
                else
                    % If there is no 'List' suffix, save the active component
                    if(isempty(regexp(j{:}, 'a*List$', 'ONCE')))
                        % i = 'Auto'/'Ems'/... , j = 'V8/M2Eq5'/...
                        component = obj.(i{:}).(j{:});
                        obj.SaveComponentToList(component);
                    end
                end
            end
        end
        % For each variant, create a folder and save each component to file
        for i = fieldnames(obj)' 
            for j = fieldnames(obj.(i{:}))'
                % It is an Atm/Last/Eq/Gsq Component
                if(strcmp(j{:}, 'Real') || strcmp(j{:}, 'Virtuell'))
                    for k = fieldnames(obj.(i{:}).(j{:}))'
                        % If there is a 'List' suffix, save all components of a variant to file
                        if(not(isempty(regexp(k{:}, 'a*List$', 'ONCE'))))
                            % i = 'Atm'/'Eq'/..., j = 'Real'/'Virtuell',
                            % k = 'BremergyList'/'HtucList'/...
                            for l = fieldnames(obj.(i{:}).(j{:}).(k{:}))';
                                ComponentManager.SaveComponent(obj.(i{:}).(j{:}).(k{:}).(l{:}));
                            end
                        end
                    end
                % It is an Auto/Strecke/Ems Component
                else
                    % If there is a 'List' suffix, save all components of a variant to file
                    if(not(isempty(regexp(j{:}, 'a*List$', 'ONCE'))))
                        % i = 'Auto'/'Ems'/... , j = 'V8/M2Eq5'/...
                        for k = fieldnames(obj.(i{:}).(j{:}))';
                            ComponentManager.SaveComponent(obj.(i{:}).(j{:}).(k{:}));
                        end
                    end
                end
            end
        end
    end
    
% Components---------------------------------------------------------------
    
    function obj = AddComponent(obj, component)
        % Save the component. Add it to its respective list, and if it is
        % active, overwrite the active component
        type = component.Type;
        subType = component.SubType;
        variant = component.Variant;
        name = component.Name;
        if(isempty(subType))
            % It is of Auto/Strecke/Ems type
            obj.(type).([variant 'List']).(name) = component;
            if(isfield(obj.(type), variant))
                % If it is the same named component, overwrite the active component
                if(obj.(type).(variant).IsNameEqual(type, subType, variant, name))
                    obj.(type).(variant) = component;
                end
            end
        else
            % It is of Atm/Last/Eq/Gsq type
            obj.(type).(subType).([variant 'List']).(name) = component;
            if(strcmp(obj.(type).(subType).(variant).Name, name))
                obj.(type).(subType).(variant) = component;
                if(isfield(obj.(type), variant))
                    % If it is the same named component, overwrite the active component
                    if(obj.(type).(subType).(variant).IsNameEqual(type, subType, variant, name))
                        obj.(type).(subType).(variant) = component;
                    end
                end
            end
        end
    end
    
    function obj = NewComponent(obj, type, subType, variant, name)
        obj = obj.AddComponent(Component(type, subType, variant, name));
    end
    
    function obj = DeleteComponent(obj, type, subType, variant, name)
        % Delete the component        
        if(isempty(subType))
            % Delete the saved Mat file containing the component, if it exists
            if(obj.IsComponentInList(type, subType, variant, name))
                path = obj.(type).([variant 'List']).(name).GetComponentPath();
                if(exist(path, 'file'))
                    delete(path);
                end
                % Remove the component from the List
                obj.(type).([variant 'List']) = rmfield(obj.(type).([variant 'List']), name);
            end
            % Overwrite the component, if active
            if(obj.IsComponentActive(type, subType, variant, name))
                if(strcmp(obj.(type).(variant).Name, name))
                    fields = fieldnames(obj.(type).([variant 'List']));
                    firstField = fields(1);
                    obj.(type).(variant) = obj.(type).([variant 'List']).(firstField{:});
                end
            end
        else
            if(obj.IsComponentInList(type, subType, variant, name))
                % Delete the saved Mat file containing the component, if it exists
                path = obj.(type).(subType).([variant 'List']).(name).GetComponentPath();
                if(exist(path, 'file'))
                    delete(path);
                end
                % Remove the component from the List
                obj.(type).(subType).([variant 'List']) = rmfield(obj.(type).(subType).([variant 'List']), name);
            end
            % Overwrite the component, if active
            if(obj.IsComponentActive(type, subType, variant, name))
                if(strcmp(obj.(type).(subType).(variant).Name, name))
                    fields = fieldnames(obj.(type).(subType).([variant 'List']));
                    firstField = fields(1);
                    obj.(type).(subType).(variant) = obj.(type).(subType).([variant 'List']).(firstField{:});
                end
            end
        end
    end
    
    function component = GetComponent(obj, type, subType, variant, name)
        if(isempty(subType))
            component = obj.(type).([variant 'List']).(name);
        else
            component = obj.(type).(subType).([variant 'List']).(name);
        end
    end
    
    % ---------------------------------------------------------------------
    
    function obj = NewAutoComponent(obj, name)
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        obj = obj.NewComponent('Auto', '', variant, name);
    end
    
    function obj = NewStreckeComponent(obj, name)
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        obj = obj.NewComponent('Strecke', '', variant, name);
    end
    
    function obj = NewEmsComponent(obj, name)
        global variantManager;
        variant = variantManager.GetActiveEms();
        obj = obj.NewComponent('Ems', '', variant, name);
    end
    
    function obj = NewAtmComponent(obj, name, slot)
        global variantManager;
        [variant, subType] = variantManager.GetActiveAtm(slot);
        obj = obj.NewComponent('Atm', subType, variant, name);
    end
    
    function obj = NewLastComponent(obj, name)
        global variantManager;
        [variant, subType] = variantManager.GetActiveLast();
        obj = obj.NewComponent('Atm', subType, variant, name);
    end
    
    function obj = NewEqComponent(obj, name, slot)
        global variantManager;
        [variant, subType] = variantManager.GetActiveEq(slot);
        obj = obj.NewComponent('Eq', subType, variant, name);
    end
    
    function obj = NewGsqComponent(obj, name)
        global variantManager;
        [variant, subType] = variantManager.GetActiveGsq();
        obj = obj.NewComponent('Gsq', subType, variant, name);
    end
    
    
    function obj = DeleteActiveAutoComponent(obj, name)
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        obj = obj.DeleteComponent('Auto', '', variant, name);
    end
    
    function obj = DeleteActiveStreckeComponent(obj, name)
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        obj = obj.DeleteComponent('Strecke', '', variant, name);
    end
    
    function obj = DeleteActiveEmsComponent(obj, name)
        global variantManager;
        variant = variantManager.GetActiveEms();
        obj = obj.DeleteComponent('Ems', '', variant, name);
    end
    
    function obj = DeleteActiveAtmComponent(obj, name, slot)
        global variantManager;
        [variant, subType] = variantManager.GetActiveAtm(slot);
        obj = obj.DeleteComponent('Atm', subType, variant, name);
    end
    
    function obj = DeleteActiveLastComponent(obj, name)
        global variantManager;
        [variant, subType] = variantManager.GetActiveLast();
        obj = obj.DeleteComponent('Last', subType, variant, name);
    end
    
    function obj = DeleteActiveEqComponent(obj, name, slot)
        global variantManager;
        [variant, subType] = variantManager.GetActiveEq(slot);
        obj = obj.DeleteComponent('Eq', subType, variant, name);
    end
    
    function obj = DeleteActiveGsqComponent(obj, name)
        global variantManager;
        [variant, subType] = variantManager.GetActiveGsq();
        obj = obj.DeleteComponent('Gsq', subType, variant, name);
    end
    
    
    function names = GetComponentNames(obj, type, subType, variant)
        % Return the names of all components belonging to a variant        
        if(isempty(subType))
            names = fieldnames(obj.(type).([variant 'List']));
        else
            names = fieldnames(obj.(type).(subType).([variant 'List']));
        end
    end
    
    function names = GetAutoComponentNames(obj)
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        if(strcmp(variant, 'Null'))
            names = {'Null'};
        else
            names = obj.GetComponentNames('Auto', '', variant);
        end
    end
    
    function names = GetStreckeComponentNames(obj)
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        if(strcmp(variant, 'Null'))
            names = {'Null'};
        else
            names = obj.GetComponentNames('Strecke', '', variant);
        end
    end
    
    function names = GetEmsComponentNames(obj)
        global variantManager;
        variant = variantManager.GetActiveEms();
        if(strcmp(variant, 'Null'))
            names = {'Null'};
        else
            names = obj.GetComponentNames('Ems', '', variant);
        end
    end
    
    function names = GetAtmComponentNames(obj, slot)
        global variantManager;
        [variant, subType] = variantManager.GetActiveAtm(slot);
        if(strcmp(variant, 'Null'))
            names = {'Null'};
        else
            type = 'Atm';
            names = obj.GetComponentNames(type, subType, variant);
        end
    end
    
    function names = GetLastComponentNames(obj)
        global variantManager;
        [variant, subType] = variantManager.GetActiveLast();
        if(strcmp(variant, 'Null'))
            names = {'Null'};
        else
            type = 'Last';
            names = obj.GetComponentNames(type, subType, variant);
        end
    end
    
    function names = GetEqComponentNames(obj, slot)
        global variantManager;
        [variant, subType] = variantManager.GetActiveEq(slot);
        if(strcmp(variant, 'Null'))
            names = {'Null'};
        else
            type = 'Eq';
            names = obj.GetComponentNames(type, subType, variant);
        end
    end
    
    function names = GetGsqComponentNames(obj)
        global variantManager;
        [variant, subType] = variantManager.GetActiveGsq();
        if(strcmp(variant, 'Null'))
            names = {'Null'};
        else
            type = 'Gsq';
            names = obj.GetComponentNames(type, subType, variant);
        end
    end
    
% Active Components -------------------------------------------------------
    
    function component = GetActiveComponent(obj, type, subType, variant)
        if(not(strcmp(type, 'Null')))
            if(isempty(subType))
                component = obj.(type).(variant);
            else
                component = obj.(type).(subType).(variant);
            end
        end
    end
    
    function component = GetActiveAutoComponent(obj)
        global variantManager
        type = 'Auto';
        subType = '';
        name = variantManager.GetActiveDriveSim();
        if(not(strcmp(name, 'Null')))
            component = obj.GetActiveComponent(type, subType, name);
        else
            component = [];
        end
    end
    
    function component = GetActiveStreckeComponent(obj)
        global variantManager
        type = 'Strecke';
        subType = '';
        name = variantManager.GetActiveDriveSim();
        if(not(strcmp(name, 'Null')))
            component = obj.GetActiveComponent(type, subType, name);
        else
            component = [];
        end
    end
    
    function component = GetActiveEmsComponent(obj)
        global variantManager
        type = 'Ems';
        subType = '';
        name = variantManager.GetActiveEms();
        if(not(strcmp(name, 'Null')))
            component = obj.GetActiveComponent(type, subType, name);
        else
            component = [];
        end
    end
    
    function component = GetActiveAtmComponent(obj, slot)
        global variantManager
        type = 'Atm';
        [name, subType] = variantManager.GetActiveAtm(slot);
        if(not(strcmp(name, 'Null')))
            component = obj.GetActiveComponent(type, subType, name);
        else
            component = [];
        end
    end
    
    function component = GetActiveLastComponent(obj)
        global variantManager
        type = 'Last';
        [name, subType] = variantManager.GetActiveLast();
        if(not(strcmp(name, 'Null')))
            component = obj.GetActiveComponent(type, subType, name);
        else
            component = [];
        end
    end
    
    function component = GetActiveEqComponent(obj, slot)
        global variantManager
        type = 'Eq';
        [name, subType] = variantManager.GetActiveEq(slot);
        if(not(strcmp(name, 'Null')))
            component = obj.GetActiveComponent(type, subType, name);
        else
            component = [];
        end
    end
    
    function component = GetActiveGsqComponent(obj)
        global variantManager
        type = 'Gsq';
        [name, subType] = variantManager.GetActiveGsq();
        if(not(strcmp(name, 'Null')))
            component = obj.GetActiveComponent(type, subType, name);
        else
            component = [];
        end
    end
    
    function components = GetAllActiveComponents(obj)
        components = {};
        global variantManager;
        % Auto
        component = obj.GetActiveAutoComponent();
        if(not(isempty(component)))
            components = [components component];
        end
        % Strecke
        component = obj.GetActiveStreckeComponent();
        if(not(isempty(component)))
            components = [components component];
        end
        % Ems
        component = obj.GetActiveEmsComponent();
        if(not(isempty(component)))
            components = [components component];
        end
        % Atm
        for i = 1:variantManager.VariantsInfo.AtmLastVirtuellAnzahl
            component = obj.GetActiveAtmComponent(i);
            if(not(isempty(component)))
                components = [components component];
            end
        end
        % Last
        component = obj.GetActiveLastComponent();
        if(not(isempty(component)))
            components = [components component];
        end
        % Eq
        for i = 1:variantManager.VariantsInfo.EqVirtuellAnzahl
            component = obj.GetActiveEqComponent(i);
            if(not(isempty(component)))
                components = [components component];
            end
        end
        % Gsq
        component = obj.GetActiveGsqComponent();
        if(not(isempty(component)))
            components = [components component];
        end
    end
    
    
    function name = GetActiveAutoComponentName(obj)
        type = 'Auto';
        subType = '';
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        if(strcmp(variant, 'Null'))
            name = 'Null';
        else
            name = obj.GetActiveComponent(type, subType, variant).Name;
        end
    end
    
    function name = GetActiveStreckeComponentName(obj)
        type = 'Strecke';
        subType = '';
        global variantManager;
        variant = variantManager.GetActiveDriveSim();
        if(strcmp(variant, 'Null'))
            name = 'Null';
        else
            name = obj.GetActiveComponent(type, subType, variant).Name;
        end
    end
    
    function name = GetActiveEmsComponentName(obj)
        type = 'Ems';
        subType = '';
        global variantManager;
        variant = variantManager.GetActiveEms();
        if(strcmp(variant, 'Null'))
            name = 'Null';
        else
            name = obj.GetActiveComponent(type, subType, variant).Name;
        end
    end
    
    function name = GetActiveAtmComponentName(obj, slot)
        type = 'Atm';
        global variantManager;
        [variant, subType] = variantManager.GetActiveAtm(slot);
        if(strcmp(variant, 'Null'))
            name = 'Null';
        else
            name = obj.GetActiveComponent(type, subType, variant).Name;
        end
    end
    
    function name = GetActiveLastComponentName(obj)
        type = 'Last';
        global variantManager;
        [variant, subType] = variantManager.GetActiveLast();
        if(strcmp(variant, 'Null'))
            name = 'Null';
        else
            name = obj.GetActiveComponent(type, subType, variant).Name;
        end
    end
    
    function name = GetActiveEqComponentName(obj, slot)
        type = 'Eq';
        global variantManager;
        [variant, subType] = variantManager.GetActiveEq(slot);
        if(strcmp(variant, 'Null'))
            name = 'Null';
        else
            name = obj.GetActiveComponent(type, subType, variant).Name;
        end
    end
    
    function name = GetActiveGsqComponentName(obj)
        type = 'Gsq';
        global variantManager;
        [variant, subType] = variantManager.GetActiveGsq();
        if(strcmp(variant, 'Null'))
            name = 'Null';
        else
            name = obj.GetActiveComponent(type, subType, variant).Name;
        end
    end
    
    
    function variable = GetActiveComponentVariable(obj, type, slot, name)
        global variantManager;
        switch type
            case 'Auto'
                variant = variantManager.GetActiveDriveSim();
                variable = obj.(type).(variant).Variables.(name);
            case 'Strecke'
                variant = variantManager.GetActiveDriveSim();
                variable = obj.(type).(variant).Variables.(name);
            case 'Ems'
                variant = variantManager.GetActiveEms();
                variable = obj.(type).(variant).Variables.(name);
            case 'Atm'
                [variant, subType] = variantManager.GetActiveAtm(slot);
                variable = obj.(type).(subType).(variant).Variables.(name);
            case 'Last'
                [variant, subType] = variantManager.GetActiveLast();
                variable = obj.(type).(subType).(variant).Variables.(name);
            case 'Eq'
                [variant, subType] = variantManager.GetActiveEq(slot);
                variable = obj.(type).(subType).(variant).Variables.(name);
            case 'Gsq'
                [variant, subType] = variantManager.GetActiveGsq();
                variable = obj.(type).(subType).(variant).Variables.(name);
            otherwise
                variable = 0;
        end
    end
    
    function variable = GetActiveAutoComponentVariable(obj, name)
        variable = obj.GetActiveComponentVariable('Auto', 0, name);
    end
        
    function variable = GetActiveStreckeComponentVariable(obj, name)
        variable = obj.GetActiveComponentVariable('Strecke', 0, name);
    end
    
    function variable = GetActiveEmsComponentVariable(obj, name)
        variable = obj.GetActiveComponentVariable('Ems', 0, name);
    end
    
    function variable = GetActiveAtmComponentVariable(obj, name, slot)
        variable = obj.GetActiveComponentVariable('Atm', slot, name);
    end
    
    function variable = GetActiveLastComponentVariable(obj, name)
        variable = obj.GetActiveComponentVariable('Last', 0, name);
    end
    
    function variable = GetActiveEqComponentVariable(obj, name, slot)
        variable = obj.GetActiveComponentVariable('Eq', slot, name);
    end
    
    function variable = GetActiveGsqComponentVariable(obj, name)
        variable = obj.GetActiveComponentVariable('Gsq', 0, name);
    end
    
    
    function names = GetActiveComponentVariableNames(obj, type, slot)
        global variantManager;
        switch type
            case 'Auto'
                variant = variantManager.GetActiveDriveSim();
                if(strcmp(variant, 'Null'))
                    names = {};
                else
                    names = fieldnames(obj.GetActiveComponent(type, '', variant).Variables);
                end
            case 'Strecke'
                variant = variantManager.GetActiveDriveSim();
                if(strcmp(variant, 'Null'))
                    names = {};
                else
                    names = fieldnames(obj.GetActiveComponent(type, '', variant).Variables);
                end
            case 'Ems'
                variant = variantManager.GetActiveEms();
                if(strcmp(variant, 'Null'))
                    names = {};
                else
                    names = fieldnames(obj.GetActiveComponent(type, '', variant).Variables);
                end
            case 'Atm'
                [variant, subType] = variantManager.GetActiveAtm(slot);
                if(strcmp(variant, 'Null'))
                    names = {};
                else
                    names = fieldnames(obj.GetActiveComponent(type, subType, variant).Variables);
                end
            case 'Last'
                [variant, subType] = variantManager.GetActiveLast();
                if(strcmp(variant, 'Null'))
                    names = {};
                else
                    names = fieldnames(obj.GetActiveComponent(type, subType, variant).Variables);
                end
            case 'Eq'
                [variant, subType] = variantManager.GetActiveEq(slot);
                if(strcmp(variant, 'Null'))
                    names = {};
                else
                    names = fieldnames(obj.GetActiveComponent(type, subType, variant).Variables);
                end
            case 'Gsq'
                [variant, subType] = variantManager.GetActiveGsq();
                if(strcmp(variant, 'Null'))
                    names = {};
                else
                    names = fieldnames(obj.GetActiveComponent(type, subType, variant).Variables);
                end
        end
    end
    
    function names = GetActiveAutoComponentVariableNames(obj)
        names = obj.GetActiveComponentVariableNames('Auto', 0);
    end
    
    function names = GetActiveStreckeComponentVariableNames(obj)
        names = obj.GetActiveComponentVariableNames('Strecke', 0);
    end
    
    function names = GetActiveEmsComponentVariableNames(obj)
        names = obj.GetActiveComponentVariableNames('Ems', 0);
    end
    
    function names = GetActiveAtmComponentVariableNames(obj, slot)
        names = obj.GetActiveComponentVariableNames('Atm', slot);
    end
    
    function names = GetActiveLastComponentVariableNames(obj)
        names = obj.GetActiveComponentVariableNames('Last', 0);
    end
    
    function names = GetActiveEqComponentVariableNames(obj, slot)
        names = obj.GetActiveComponentVariableNames('Eq', slot);
    end
    
    function names = GetActiveGsqComponentVariableNames(obj)
        names = obj.GetActiveComponentVariableNames('Gsq', 0);
    end

    % Check Components ----------------------------------------------------
    
    function state = IsComponentInList(obj, type, subType, variant, name)
        % If the component exists in the list return 1, else 0        
        state = 0;
        if(isprop(obj, type))
            variantList = [variant 'List'];
            % Whether the component has the SubType property
            if(isempty(subType))
                if(isfield(obj.(type), variantList))
                    if(isfield(obj.(type).(variantList), name))
                        state = 1;
                    end
                end
            else
                if(isfield(obj.(type), subType))
                    if(isfield(obj.(type).(subType), variantList))
                        if(isfield(obj.(type).(subType).(variantList), name))
                            state = 1;
                        end
                    end
                end
            end
        end
    end
    
    function state = IsComponentActive(obj, type, subType, variant, name)
        % If the component is active for the variant return 1, else 0
        state = 0;
        if(isprop(obj, type))
            % If the component does not have the SubType property (Auto, Strecke, Ems)
            if(isempty(subType))
                if(isfield(obj.(type), variant))
                    if(strcmp(obj.(type).(variant).Name, name))
                        state = 1;
                    end
                end
            else
            % If the component has the SubType property (Atm, Gsq, Eq, Last)
                if(isfield(obj.(type), subType))
                    if(isfield(obj.(type).(subType), variant))
                        if(strcmp(obj.(type).(subType).(variant).Name, name))
                            state = 1;
                        end
                    end
                end
            end
        end
    end
    
    % Types / SubTypes ----------------------------------------------------
    
    function types = GetTypes(obj)
        types = fieldnames(obj);
    end
    
    function subTypes = GetSubTypes(obj, type)
        if(obj.HasSubType(type))
            subTypes = fieldnames(obj.(type));
        else
            subTypes = '';
        end
    end
    
    function state = HasSubType(obj, type)
        global variantManager;
        if(variantManager.HasSubType(type) && isprop(obj, type))
            state = 1;
        else
            state = 0;
        end
    end
    
    function variants = GetVariants(obj, type, subType)
        if(obj.HasSubType(type))
            fields = fieldnames(obj.(type).(subType));
        else
            fields = fieldnames(obj.(type));
        end
        
        variants = [];
        for i = fields'
            if(length(i{:}) > 4)
                if(not(strcmp(i{:}(end-3:end), 'List')))
                    variants = [variants; i];
                end
            else
                variants = [variants; i];
            end
        end
    end
    
    
    % Miscellaneous Functions ---------------------------------------------
    
    function obj = SetComponentAsActive(obj, component)
        obj = obj.AddComponent(component);
        if(isempty(component.SubType))
            obj.(component.Type).(component.Variant) = component;
        else
            obj.(component.Type).(component.SubType).(component.Variant) = component;
        end
    end
    
    function obj = SetActiveComponent(obj, type, slot, name)
        global variantManager;
        switch type
            case 'Auto'
                variant = variantManager.GetActiveDriveSim();
                component = obj.(type).([variant 'List']).(name).EvalVariableSetup();
                obj.(type).([variant 'List']).(name) = component;
                obj.(type).(variant) = component;
            case 'Strecke'
                variant = variantManager.GetActiveDriveSim();
                component = obj.(type).([variant 'List']).(name).EvalVariableSetup();
                obj.(type).([variant 'List']).(name) = component;
                obj.(type).(variant) = component;
            case 'Ems'
                variant = variantManager.GetActiveEms();
                component = obj.(type).([variant 'List']).(name).EvalVariableSetup();
                obj.(type).([variant 'List']).(name) = component;
                obj.(type).(variant) = component;
            case 'Atm'
                [variant, subType] = variantManager.GetActiveAtm(slot);
                component = obj.(type).(subType).([variant 'List']).(name).EvalVariableSetup();
                obj.(type).(subType).([variant 'List']).(name) = component;
                obj.(type).(subType).(variant) = component;
            case 'Last'
                [variant, subType] = variantManager.GetActiveLast();
                component = obj.(type).(subType).([variant 'List']).(name).EvalVariableSetup();
                obj.(type).(subType).([variant 'List']).(name) = component;
                obj.(type).(subType).(variant) = component;
            case 'Eq'
                [variant, subType] = variantManager.GetActiveEq(slot);
                component = obj.(type).(subType).([variant 'List']).(name).EvalVariableSetup();
                obj.(type).(subType).([variant 'List']).(name) = component;
                obj.(type).(subType).(variant) = component;
            case 'Gsq'
                [variant, subType] = variantManager.GetActiveGsq();
                component = obj.(type).(subType).([variant 'List']).(name).EvalVariableSetup();
                obj.(type).(subType).([variant 'List']).(name) = component;
                obj.(type).(subType).(variant) = component;
        end
    end
    
    function obj = SaveActiveComponentToList(obj, type, slot)
        % Save the active component to its respective list
        global variantManager;
        switch type
            case 'Auto'
                variant = variantManager.GetActiveDriveSim();
                name = obj.(type).(variant).Name;
                obj.(type).([variant 'List']).(name) = obj.(type).(variant);
            case 'Strecke'
                variant = variantManager.GetActiveDriveSim();
                name = obj.(type).(variant).Name;
                obj.(type).([variant 'List']).(name) = obj.(type).(variant);
            case 'Ems'
                variant = variantManager.GetActiveEms();
                name = obj.(type).(variant).Name;
                obj.(type).([variant 'List']).(name) = obj.(type).(variant);
            case 'Atm'
                [variant, subType] = variantManager.GetActiveAtm(slot);
                name = obj.(type).(subType).(variant).Name;
                obj.(type).(subType).([variant 'List']).(name) = obj.(type).(subType).(variant);
            case 'Last'
                [variant, subType] = variantManager.GetActiveLast();
                name = obj.(type).(subType).(variant).Name;
                obj.(type).(subType).([variant 'List']).(name) = obj.(type).(subType).(variant);
            case 'Eq'
                [variant, subType] = variantManager.GetActiveEq(slot);
                name = obj.(type).(subType).(variant).Name;
                obj.(type).(subType).([variant 'List']).(name) = obj.(type).(subType).(variant);
            case 'Gsq'
                [variant, subType] = variantManager.GetActiveGsq();
                name = obj.(type).(subType).(variant).Name;
                obj.(type).(subType).([variant 'List']).(name) = obj.(type).(subType).(variant);
        end
    end
    
    function obj = SaveComponentToList(obj, component)
        type = component.Type;
        subType = component.SubType;
        variant = component.Variant;
        name = component.Name;
        switch type
            case 'Auto'
                obj.(type).([variant 'List']).(name) = component;
            case 'Strecke'
                obj.(type).([variant 'List']).(name) = component;
            case 'Ems'
                obj.(type).([variant 'List']).(name) = component;
            case 'Atm'
                obj.(type).(subType).([variant 'List']).(name) = component;
            case 'Last'
                obj.(type).(subType).([variant 'List']).(name) = component;
            case 'Eq'
                obj.(type).(subType).([variant 'List']).(name) = component;
            case 'Gsq'
                obj.(type).(subType).([variant 'List']).(name) = component;
        end
    end    
end
methods (Static)
    function SaveComponent(component)
        % Do not save components belonging to experiment runs. They are
        % saved by the ExperimentRunManager
        if(component.IsExperimentRun || strcmp(component.Name, 'ExperimentRun'))
            return;
        end
        % Get the components path
        componentsPath = ComponentManager.GetComponentsPath();
        % Concatenate the directory to save the component in
        if(isempty(component.SubType))
            componentDir = fullfile(componentsPath, component.Type, ...
                component.Variant);
        else
            componentDir = fullfile(componentsPath, component.Type, ...
                component.SubType, component.Variant);
        end
        % Create the dir if it does not exist
        if(not(isdir(componentDir)))
            mkdir(componentDir);
        end
        % Save the component to file
        componentPath = fullfile(componentDir, component.Name);
        save(componentPath, 'component');
    end
    
    function path = GetComponentsPath()
        [projectRoot, ~] = project_paths();
        path = fullfile(projectRoot, 'data', 'components');
    end
    
    function path = GetActiveVariablePath(type, subType, variant, variable)
        % Returns the path to the ModelVariable through the
        % componentManager variable
        
        % If a required input is empty, abort and return an empty string
        if(isempty(type) || isempty(variant) || isempty(variable))
            path = '';
            return;
        end
        
        % The path structure differs for types with or without subTypes
        if(isempty(subType))
            path = ['componentManager.' type '.' variant '.Variables.' variable];
        else
            path = ['componentManager.' type '.' subType '.' variant '.Variables.' variable];
        end
    end
end
end

