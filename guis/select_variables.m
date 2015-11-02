function varargout = select_variables(varargin)
% SELECT_VARIABLES MATLAB code for select_variables.fig
%      SELECT_VARIABLES, by itself, creates a new SELECT_VARIABLES or raises the existing
%      singleton*.
%
%      H = SELECT_VARIABLES returns the handle to a new SELECT_VARIABLES or the handle to
%      the existing singleton*.
%
%      SELECT_VARIABLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_VARIABLES.M with the given input arguments.
%
%      SELECT_VARIABLES('Property','Value',...) creates a new SELECT_VARIABLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_variables_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_variables_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 4.2.2015
%   @updated 9.7.2015

% Edit the above text to modify the response to help select_variables

% Last Modified by GUIDE v2.5 13-Oct-2015 15:31:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_variables_OpeningFcn, ...
                   'gui_OutputFcn',  @select_variables_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before select_variables is made visible.
function select_variables_OpeningFcn(hObject, eventdata, handles, varargin)
imshow('bimaq_logo.png','Parent',handles.bimaq_logo);

% Listen for changes to the active experiment run. Trigger an update to all
% relevant widgets
global experimentRunManager;
lh = addlistener(experimentRunManager, 'ActiveExperimentRunChanged', @update_experiment_run);
if(experimentRunManager.IsExperimentRunMode())
    experimentRunManager.NotifyExperimentRunChanged();
    enable_experiment_run_widgets(handles);
else    
    disable_experiment_run_widgets(handles);
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles);
    update_component_popupmenus(handles, eventdata)
end

handles.ExperimentRunChangedlistener = lh;
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = select_variables_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function select_variables_CloseRequestFcn(hObject, eventdata, handles)
% Disable experiment mode and remove experimentRun injections from
% componentManager if not required

global experimentRunManager;
select_results = findobj('type', 'figure', 'tag', 'select_results');
if(experimentRunManager.IsExperimentRunMode() && isempty(select_results))
    experimentRunManager = experimentRunManager.DeactivateExperimentRunMode();
end
% Remove notifyExperimentRunChanged listener from experimentRunManager
delete(handles.ExperimentRunChangedlistener)

% Hint: delete(hObject) closes the figure
delete(hObject);

%--------------------------------------------------------------------------
% System
%--------------------------------------------------------------------------

function preset_mode_radiobutton_Callback(hObject, eventdata, handles)
if(get(hObject, 'Value') == 0)
    set(hObject, 'Value', 1)
else
    set(handles.experiment_mode_radiobutton, 'Value', 0);
    select_results = findobj('type', 'figure', 'tag', 'select_results');
    if(not(isempty(select_results)))
        close(select_results);
    end
    disable_experiment_mode(handles, eventdata);
end

function experiment_mode_radiobutton_Callback(hObject, eventdata, handles)
if(get(hObject, 'Value') == 0)
    set(hObject, 'Value', 1)
else
    set(handles.preset_mode_radiobutton, 'Value', 0);
    enable_experiment_mode(handles, eventdata);
end

function enable_experiment_mode(handles, eventdata)
global experimentRunManager;
experimentRunManager = experimentRunManager.ActivateExperimentRunMode();
enable_experiment_run_widgets(handles);
experiment_popupmenu_CreateFcn(handles.experiment_popupmenu, eventdata, handles)

function disable_experiment_mode(handles, eventdata)
global experimentRunManager;
disable_experiment_run_widgets(handles);
experimentRunManager = experimentRunManager.DeactivateExperimentRunMode();
experiment_popupmenu_CreateFcn(handles.experiment_popupmenu, eventdata, handles)

function status = is_experiment_mode(handles)
if(isempty(handles))
    status = 0;
else
    status = get(handles.experiment_mode_radiobutton, 'Value');
end

function help_pushbutton_Callback(hObject, eventdata, handles)
open('README.txt');

%--------------------------------------------------------------------------
% Experiment / Run
%--------------------------------------------------------------------------

function experiment_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
if(is_experiment_mode(handles))
    [list, index] = experimentRunManager.GetExperimentNames();
else
    list = {'Disabled'};
    index = 1;
end
set(hObject, 'String', list);
set(hObject, 'Value', index);
if(not(isempty(handles)))
    % Updates run_popupmenu and all variant and component popupmenus
    run_popupmenu_CreateFcn(handles.run_popupmenu, eventdata, handles)
end

function experiment_popupmenu_Callback(hObject, eventdata, handles)
global experimentRunManager;
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
experimentName = items{index_selected};
if(not(strcmp(experimentName, 'Disabled')))
    experimentRunManager = experimentRunManager.SetActiveExperimentName(experimentName);
end

function run_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
if(is_experiment_mode(handles))
    [list, index] = experimentRunManager.GetActiveRunIds();
else
    list = {'Disabled'};
    index = 1;
end
set(hObject, 'String', list);
set(hObject, 'Value', index);
if(not(isempty(handles)))
	% Update all variant and component popupmenus
    update_variant_popupmenus(handles, eventdata)
    update_component_popupmenus(handles, eventdata)
end

function run_popupmenu_Callback(hObject, eventdata, handles)
% Callback for the run id selection. Set the selected run id as the active
% run id in experimentRunManager and then all component and variant widgets

global experimentRunManager;
% Get the run id string and set is as the active run id
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
runId = items{index_selected};
experimentRunManager = experimentRunManager.SetActiveRunId(runId);

function run_new_pushbutton_Callback(hObject, eventdata, handles)
global experimentRunManager;
[experiment_name, run_id_num] = experimentRunManager.NextExperimentNameAndRunId(0);
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.RunId = run_id_num;
experimentRunManager.AddExperimentRun(experimentRun);
experimentRunManager.SetActiveExperimentRun(experiment_name, run_id_num);

function experiment_new_pushbutton_Callback(hObject, eventdata, handles)
% Create a new ExperimentRun. Launch the new_experiment_run dialog which
% asks for the experiment name and run id. It also presents the option of
% copying the component and variant state of another experimentRun

global experimentRunManager;
[experiment_name, run_id, parent_experiment_name, parent_run_id] = ...
    new_experiment_run(experimentRunManager.ActiveExperimentName, experimentRunManager.ActiveRunId);
run_id_num = ExperimentRun.ParseRunId(run_id);
parent_run_id_num = ExperimentRun.ParseRunId(parent_run_id);
if(not(isempty(experiment_name)) && run_id_num >= 1)
    if(not(isempty(parent_experiment_name)) && parent_run_id_num >= 1)
        % If a parent experiment name and run id are returned, create a copy of
        % that ExperimentRun but change the experiment name and run id
        experimentRun = experimentRunManager.GetExperimentRun(parent_experiment_name, parent_run_id_num);
        experimentRun.ExperimentName = experiment_name;
        experimentRun.RunId = run_id_num;
        timeNow = datestr(now); % Round time to the current date
        experimentRun.DateCreated = datenum(timeNow);
        experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);
    else
        % If they are empty, create a new ExperimentRun object
        experimentRunManager = experimentRunManager.NewExperimentRun(experiment_name, run_id_num);
    end
    experimentRunManager = experimentRunManager.ActivateExperimentRun(experiment_name, run_id_num);
end
% Update the popupmenus in the GUI
experimentRunManager.NotifyExperimentRunChanged();

function experiment_delete_pushbutton_Callback(hObject, eventdata, handles)
global experimentRunManager;
[experiment_name, run_id] = experimentRunManager.GetActiveExperimentNameAndRunId();
experimentRunManager = experimentRunManager.DeleteActiveExperimentRun();
experimentRunManager = experimentRunManager.ActivateNextExperimentRun(experiment_name, run_id);

function disable_experiment_run_widgets(handles)
set(handles.experiment_popupmenu, 'Enable', 'off')
set(handles.run_popupmenu, 'Enable', 'off')
set(handles.experiment_new_pushbutton, 'Enable', 'off')
set(handles.experiment_delete_pushbutton, 'Enable', 'off')
set(handles.experiment_filter_edit, 'Enable', 'off')
set(handles.run_new_pushbutton, 'Enable', 'off')
hide_based_on_widgets(handles)

function enable_experiment_run_widgets(handles)
set(handles.experiment_popupmenu, 'Enable', 'on')
set(handles.run_popupmenu, 'Enable', 'on')
set(handles.experiment_new_pushbutton, 'Enable', 'on')
set(handles.experiment_delete_pushbutton, 'Enable', 'on')
set(handles.experiment_filter_edit, 'Enable', 'off')
set(handles.run_new_pushbutton, 'Enable', 'on')
show_based_on_widgets(handles)

function show_based_on_widgets(handles)
set(handles.auto_based_on_text, 'Visible', 'on');
set(handles.strecke_based_on_text, 'Visible', 'on');
set(handles.ems_based_on_text, 'Visible', 'on');
set(handles.hardware_based_on_text, 'Visible', 'on');

function hide_based_on_widgets(handles)
set(handles.auto_based_on_text, 'Visible', 'off');
set(handles.strecke_based_on_text, 'Visible', 'off');
set(handles.ems_based_on_text, 'Visible', 'off');
set(handles.hardware_based_on_text, 'Visible', 'off');

% ExperimentRunManager Listeners ------------------------------------------

function update_experiment_run(src, event)
% Update the GUI through an external caller. This is useful when there has 
% been an update to the data that the GUI represents. The function is
% registered to a listener which is notified when the experimentrun changes

global experimentRunManager;
% Find the handle for the select_variables GUI
select_variables = findobj('type', 'figure', 'tag', 'select_variables');

% This createFunction causes an update of all experimentRun data widgets
if(not(isempty(select_variables)))
    % The 'handles' variable used in all Create and Callback functions
    handles = guidata(select_variables);
    isExperimentMode = experimentRunManager.IsExperimentRunMode();
    set(handles.preset_mode_radiobutton, 'Value', not(isExperimentMode));
    set(handles.experiment_mode_radiobutton, 'Value', isExperimentMode);
    experiment_popupmenu_CreateFcn(handles.experiment_popupmenu, 0, handles)
    update_variant_popupmenus(handles, 0)
    update_component_popupmenus(handles, 0)
end

%--------------------------------------------------------------------------
% Execute Buttons
%--------------------------------------------------------------------------

function execute_build_pushbutton_Callback(hObject, eventdata, handles)
open_system('Versuchsstand');
set_param('Versuchsstand', 'SimulationCommand', 'update');

function execute_simulate_pushbutton_Callback(hObject, eventdata, handles)
open_system('Versuchsstand');
global experimentRunManager;
if(is_experiment_mode(handles))
    simOut = sim('Versuchsstand','SaveOutput','on', ...
        'SaveFormat', 'StructureWithTime', 'ReturnWorkspaceOutputs','on');  
    experimentRunManager = experimentRunManager.SaveSimulationToActive(simOut);
else
    set_param('Versuchsstand', 'SimulationCommand', 'start');
end

function execute_results_pushbutton_Callback(hObject, eventdata, handles)
if(is_experiment_mode(handles))
    select_results
else
    Simulink.sdi.view
end

%--------------------------------------------------------------------------
% Save Buttons
%--------------------------------------------------------------------------

function save_components_pushbutton_Callback(hObject, eventdata, handles)
fprintf('Saving component manager...\n');

global componentManager;
componentManager.SaveSeperatedComponents();

function save_experiments_pushbutton_Callback(hObject, eventdata, handles)
fprintf('Saving experiment run manager...\n');

global experimentRunManager;
experimentRunManager.SaveSeperatedExperimentRuns();

%--------------------------------------------------------------------------
% Varianten Configuration
%--------------------------------------------------------------------------

function hardware_i_o_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetHardwareIo();
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function hardware_i_o_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
global variantManager;
variantManager.SetHardwareIo(item_selected)
% Save the variant to experimentRunManager
global experimentRunManager;
if(is_experiment_mode(handles))
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    name = variantManager.GetActiveHardwareIo();
    if(strcmp(item_selected, 'Null'))
        % If 'Null' is selected, remove the variant from the experimentRun
        experimentRun = experimentRun.RemoveVariant('HardwareIo', 0);
    else
        % Else save the selected variant to the experimentRun
        variant = Variant(name, 'HardwareIo', '', 0);
        experimentRun = experimentRun.AddVariant(variant);
    end
    experimentRunManager.AddExperimentRun(experimentRun);
end

function virtuell_hardware_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetVirtuellHardware();
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function virtuell_hardware_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
global variantManager;
variantManager.SetVirtuellHardware(item_selected)
% Save the variant to experimentRunManager
global experimentRunManager;
if(is_experiment_mode(handles))
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    name = variantManager.GetActiveVirtuellHardware();
    if(strcmp(item_selected, 'Null'))
        % If 'Null' is selected, remove the variant from the experimentRun
        experimentRun = experimentRun.RemoveVariant('VirtuellHardware', 0);
    else
        % Else save the selected variant to the experimentRun
        variant = Variant(name, 'VirtuellHardware', '', 0);
        experimentRun = experimentRun.AddVariant(variant);
    end
    experimentRunManager.AddExperimentRun(experimentRun);
end

function drive_sim_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetDriveSim();
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function drive_sim_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
global variantManager;
variantManager.SetDriveSim(item_selected);
% Save the variant to experimentRunManager
global experimentRunManager;
if(is_experiment_mode(handles))
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    name = variantManager.GetActiveDriveSim();
    if(strcmp(item_selected, 'Null'))
        % If 'Null' is selected, remove the variant from the experimentRun
        experimentRun = experimentRun.RemoveVariant('DriveSim', 0);
        experimentRun = experimentRun.RemoveComponent('Auto', '');
        experimentRun = experimentRun.RemoveComponent('Strecke', '');
    else
        % Else save the selected variant to the experimentRun
        variant = Variant(name, 'DriveSim', '', 0);
        experimentRun = experimentRun.AddVariant(variant);
    end
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for auto and strecke widgets
auto_popupmenu_CreateFcn(handles.auto_popupmenu, eventdata, handles);
strecke_popupmenu_CreateFcn(handles.strecke_popupmenu, eventdata, handles);

function ems_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetEms();
set(hObject, 'String', list);
set(hObject, 'Value', mode)

function ems_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
global variantManager;
variantManager.SetEms(item_selected)
% Save the variant to experimentRunManager
global experimentRunManager;
if(is_experiment_mode(handles))
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    name = variantManager.GetActiveEms();
    if(strcmp(item_selected, 'Null'))
        % If 'Null' is selected, remove the variant from the experimentRun
        experimentRun = experimentRun.RemoveVariant('Ems', 0);
        experimentRun = experimentRun.RemoveComponent('Ems', '');
    else
        % Else save the selected variant to the experimentRun
        variant = Variant(name, 'Ems', '', 0);
        experimentRun = experimentRun.AddVariant(variant);
    end
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for ems widgets
ems_popupmenu_CreateFcn(handles.ems_popupmenu, eventdata, handles)

% ATM / Motor Varianten ---------------------------------------------------

function atm_1_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetAtm(1);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function atm_1_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};

global variantManager;
global experimentRunManager;
% Remove respective component if 'Null' variant is selected
if(is_experiment_mode(handles) && strcmp(item_selected, 'Null'))
    [~, subType] = variantManager.GetActiveAtm(1);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % If 'Null' is selected, remove the variant from the experimentRun
    experimentRun = experimentRun.RemoveVariant('Atm', 1);
    experimentRun = experimentRun.RemoveComponent('Atm', subType);
	experimentRunManager.AddExperimentRun(experimentRun);
end
% Set the selected variant
if(variantManager.SetAtm(item_selected, 1))
    variantManager.SetAtm('Null', 1);
    set(hObject, 'Value', 1);
    warndlg('Eine reale Antriebsmaschine darf nicht mehr als einmal aktiv sein','Ungueltige Varianten Auswahl','modal');
end
% Save the variant to experimentRunManager
if(is_experiment_mode(handles) && not(strcmp(item_selected, 'Null')))
    [name, subType] = variantManager.GetActiveAtm(1);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % Else save the selected variant to the experimentRun
    variant = Variant(name, 'Atm', subType, 1);
    experimentRun = experimentRun.AddVariant(variant);
    experimentRunManager.AddExperimentRun(experimentRun);
end

% Update the preset/component for ems widgets
atm_1_component_popupmenu_CreateFcn(handles.atm_1_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

function atm_2_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetAtm(2);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function atm_2_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
global variantManager;
global experimentRunManager;
% Remove respective component if 'Null' variant is selected
if(is_experiment_mode(handles) && strcmp(item_selected, 'Null'))
    [~, subType] = variantManager.GetActiveAtm(2);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % If 'Null' is selected, remove the variant from the experimentRun
    experimentRun = experimentRun.RemoveVariant('Atm', 2);
    experimentRun = experimentRun.RemoveComponent('Atm', subType);
	experimentRunManager.AddExperimentRun(experimentRun);
end
% Set the selected variant
if(variantManager.SetAtm(item_selected, 2))
    variantManager.SetAtm('Null', 2);
    set(hObject, 'Value', 1);
    warndlg('Eine reale Antriebsmaschine darf nicht mehr als einmal aktiv sein','Ungueltige Varianten Auswahl','modal');
end
% Save the variant to experimentRunManager
if(is_experiment_mode(handles) && not(strcmp(item_selected, 'Null')))
    [name, subType] = variantManager.GetActiveAtm(2);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % Else save the selected variant to the experimentRun
    variant = Variant(name, 'Atm', subType, 2);
    experimentRun = experimentRun.AddVariant(variant);
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for ems widgets
atm_2_component_popupmenu_CreateFcn(handles.atm_2_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

% Energiequelle / Batterie Varianten --------------------------------------

function eq_1_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetEq(1);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_1_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% Get the global managers
global variantManager;
global experimentRunManager;
% Remove respective component if 'Null' variant is selected
if(is_experiment_mode(handles) && strcmp(item_selected, 'Null'))
    [~, subType] = variantManager.GetActiveEq(1);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % If 'Null' is selected, remove the variant from the experimentRun
    experimentRun = experimentRun.RemoveVariant('Eq', 1);
    experimentRun = experimentRun.RemoveComponent('Eq', subType);
	experimentRunManager.AddExperimentRun(experimentRun);
end
% Set the selected variant. If it fails, set to null variant
if(variantManager.SetEq(item_selected, 1))
    variantManager.SetEq('Null', 1);
    set(hObject, 'Value', 1);
    warndlg('Eine reale Energiequelle darf nicht mehr als einmal aktiv sein','Ungueltige Varianten Auswahl','modal');
end
% Save the variant to experimentRunManager
if(is_experiment_mode(handles) && not(strcmp(item_selected, 'Null')))
    [name, subType] = variantManager.GetActiveEq(1);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % Else save the selected variant to the experimentRun
    variant = Variant(name, 'Eq', subType, 1);
    experimentRun = experimentRun.AddVariant(variant);
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for eq widgets
eq_1_component_popupmenu_CreateFcn(handles.eq_1_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

function eq_2_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetEq(2);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_2_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% Get the global managers
global variantManager;
global experimentRunManager;
% Remove respective component if 'Null' variant is selected
if(is_experiment_mode(handles) && strcmp(item_selected, 'Null'))
    [~, subType] = variantManager.GetActiveEq(2);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % If 'Null' is selected, remove the variant from the experimentRun
    experimentRun = experimentRun.RemoveVariant('Eq', 2);
    experimentRun = experimentRun.RemoveComponent('Eq', subType);
	experimentRunManager.AddExperimentRun(experimentRun);
end
% Set the selected variant. If it fails, set to null variant
if(variantManager.SetEq(item_selected, 2))
    variantManager.SetEq('Null', 2);
    set(hObject, 'Value', 2);
    warndlg('Eine reale Energiequelle darf nicht mehr als einmal aktiv sein','Ungueltige Varianten Auswahl','modal');
end
% Save the variant to experimentRunManager
if(is_experiment_mode(handles) && not(strcmp(item_selected, 'Null')))
    [name, subType] = variantManager.GetActiveEq(2);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % Else save the selected variant to the experimentRun
    variant = Variant(name, 'Eq', subType, 2);
    experimentRun = experimentRun.AddVariant(variant);
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for eq widgets
eq_2_component_popupmenu_CreateFcn(handles.eq_2_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

function eq_3_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetEq(3);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_3_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% Get the global managers
global variantManager;
global experimentRunManager;
% Remove respective component if 'Null' variant is selected
if(is_experiment_mode(handles) && strcmp(item_selected, 'Null'))
    [~, subType] = variantManager.GetActiveEq(3);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % If 'Null' is selected, remove the variant from the experimentRun
    experimentRun = experimentRun.RemoveVariant('Eq', 1);
    experimentRun = experimentRun.RemoveComponent('Eq', subType);
	experimentRunManager.AddExperimentRun(experimentRun);
end
% Set the selected variant. If it fails, set to null variant
if(variantManager.SetEq(item_selected, 3))
    variantManager.SetEq('Null', 3);
    set(hObject, 'Value', 3);
    warndlg('Eine reale Energiequelle darf nicht mehr als einmal aktiv sein','Ungueltige Varianten Auswahl','modal');
end
% Save the variant to experimentRunManager
if(is_experiment_mode(handles) && not(strcmp(item_selected, 'Null')))
    [name, subType] = variantManager.GetActiveEq(3);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % Else save the selected variant to the experimentRun
    variant = Variant(name, 'Eq', subType, 3);
    experimentRun = experimentRun.AddVariant(variant);
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for eq widgets
eq_3_component_popupmenu_CreateFcn(handles.eq_3_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

function eq_4_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetEq(4);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_4_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% Get the global managers
global variantManager;
global experimentRunManager;
% Remove respective component if 'Null' variant is selected
if(is_experiment_mode(handles) && strcmp(item_selected, 'Null'))
    [~, subType] = variantManager.GetActiveEq(4);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % If 'Null' is selected, remove the variant from the experimentRun
    experimentRun = experimentRun.RemoveVariant('Eq', 4);
    experimentRun = experimentRun.RemoveComponent('Eq', subType);
	experimentRunManager.AddExperimentRun(experimentRun);
end
% Set the selected variant. If it fails, set to null variant
if(variantManager.SetEq(item_selected, 4))
    variantManager.SetEq('Null', 4);
    set(hObject, 'Value', 4);
    warndlg('Eine reale Energiequelle darf nicht mehr als einmal aktiv sein','Ungueltige Varianten Auswahl','modal');
end
% Save the variant to experimentRunManager
if(is_experiment_mode(handles) && not(strcmp(item_selected, 'Null')))
    [name, subType] = variantManager.GetActiveEq(4);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % Else save the selected variant to the experimentRun
    variant = Variant(name, 'Eq', subType, 4);
    experimentRun = experimentRun.AddVariant(variant);
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for eq widgets
eq_4_component_popupmenu_CreateFcn(handles.eq_4_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

function eq_5_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetEq(5);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_5_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% Get the global managers
global variantManager;
global experimentRunManager;
% Remove respective component if 'Null' variant is selected
if(is_experiment_mode(handles) && strcmp(item_selected, 'Null'))
    [~, subType] = variantManager.GetActiveEq(5);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % If 'Null' is selected, remove the variant from the experimentRun
    experimentRun = experimentRun.RemoveVariant('Eq', 5);
    experimentRun = experimentRun.RemoveComponent('Eq', subType);
	experimentRunManager.AddExperimentRun(experimentRun);
end
% Set the selected variant. If it fails, set to null variant
if(variantManager.SetEq(item_selected, 5))
    variantManager.SetEq('Null', 5);
    set(hObject, 'Value', 5);
    warndlg('Eine reale Energiequelle darf nicht mehr als einmal aktiv sein','Ungueltige Varianten Auswahl','modal');
end
% Save the variant to experimentRunManager
if(is_experiment_mode(handles) && not(strcmp(item_selected, 'Null')))
    [name, subType] = variantManager.GetActiveEq(5);
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    % Else save the selected variant to the experimentRun
    variant = Variant(name, 'Eq', subType, 5);
    experimentRun = experimentRun.AddVariant(variant);
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for eq widgets
eq_5_component_popupmenu_CreateFcn(handles.eq_5_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

% Last and Gsq Varianten --------------------------------------------------

function last_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetLast;
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function last_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
global variantManager;
% If it fails, set to null variant
if(variantManager.SetLast(item_selected))
    variantManager.SetLast('Null');
    set(hObject, 'Value', 1);
end
% Save the variant to experimentRunManager
global experimentRunManager;
if(is_experiment_mode(handles))
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    [name, subType] = variantManager.GetActiveLast();
    if(strcmp(item_selected, 'Null'))
        % If 'Null' is selected, remove the variant from the experimentRun
        experimentRun = experimentRun.RemoveVariant('Last', 0);
    else
        % Else save the selected variant to the experimentRun
        variant = Variant(name, 'Last', subType, 0);
        experimentRun = experimentRun.AddVariant(variant);
    end
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for ems widgets
last_component_popupmenu_CreateFcn(handles.last_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

function gsq_variant_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
[list, mode] = variantManager.GetGsq;
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function gsq_variant_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
global variantManager;
% If it fails, set to null variant
if(variantManager.SetGsq(item_selected))
    variantManager.SetGsq('Null');
    set(hObject, 'Value', 1);
end
% Save the variant to experimentRunManager
global experimentRunManager;
if(is_experiment_mode(handles))
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    [name, subType] = variantManager.GetActiveGsq();
    if(strcmp(item_selected, 'Null'))
        % If 'Null' is selected, remove the variant from the experimentRun
        experimentRun = experimentRun.RemoveVariant('Gsq', 0);
    else
        % Else save the selected variant to the experimentRun
        variant = Variant(name, 'Gsq', subType, 0);
        experimentRun = experimentRun.AddVariant(variant);
    end
    experimentRunManager.AddExperimentRun(experimentRun);
end
% Update the preset/component for ems widgets
gsq_component_popupmenu_CreateFcn(handles.gsq_component_popupmenu, eventdata, handles);
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

% Miscelansous Functions --------------------------------------------------

function hil_list_pushbutton_Callback(hObject, eventdata, handles)
return;

%--------------------------------------------------------------------------
% Auto
%--------------------------------------------------------------------------

function auto_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, index] = get_auto_component_names();
set(hObject, 'Value', index);
set(hObject, 'String', list);

% Update the based on text field below the preset popup menu
if(is_experiment_mode(handles))
    set(handles.auto_based_on_text, 'String', get_based_on_text('Auto', 0));
end

if(not(isempty(handles)))
    auto_listbox_CreateFcn(handles.auto_listbox, eventdata, handles)
end

function auto_popupmenu_Callback(hObject, eventdata, handles)
global experimentRunManager;
% Get the name of the item selcted in the popup menu
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% If the item is not named 'Null', set the component as the active component
if(not(strcmp(item_selected, 'Null')))
    componentManager = evalin('base', 'componentManager');
	componentManager = componentManager.SetActiveComponent('Auto', 0, item_selected);
    assignin('base', 'componentManager', componentManager);
    if(is_experiment_mode(handles))
        % If experiment mode is enabled, use the selected component to
        % overwrite the component of the same type in the currently active
        % experiment run. Then, update the auto_popupmenu widget
        component = componentManager.GetActiveAutoComponent();
        experimentRunManager = experimentRunManager.SaveComponentToActiveExperimentRun(component);
        experimentRunManager.LoadComponentFromActiveExperimentRun(component.Type, component.SubType, component.Variant);
        auto_popupmenu_CreateFcn(handles.auto_popupmenu, eventdata, handles)
        return;
    end
end
% Update the popupmenus and all dependant widgets
if(not(isempty(handles)))
    auto_listbox_CreateFcn(handles.auto_listbox, eventdata, handles)
end

function auto_new_preset_pushbutton_Callback(hObject, eventdata, handles)
new_auto_preset()
auto_popupmenu_CreateFcn(handles.auto_popupmenu, eventdata, handles);

function auto_delete_preset_pushbutton_Callback(hObject, eventdata, handles)
delete_auto_preset(handles)
auto_popupmenu_CreateFcn(handles.auto_popupmenu, eventdata, handles);

function auto_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
componentManager = evalin('base', 'componentManager');
list = componentManager.GetActiveAutoComponentVariableNames();
list = sort(list);
% If list position is greater than the new list length, set to last item
lList = length(list);
if(get(hObject, 'Value') > lList)
    if(lList == 0)
        set(hObject, 'Value', 1);
    else
        set(hObject, 'Value', lList);
    end
end
set(hObject, 'String', list);
auto_listbox_Callback(hObject, eventdata, handles)

function auto_listbox_Callback(hObject, eventdata, handles)

if(not(isempty(handles)))
    items = get(hObject, 'String');
    if(isempty(items))
        variable = ModelVariable('Null', 0);
    else
        index_selected = get(hObject, 'Value');
        item_selected = items{index_selected};
        componentManager = evalin('base', 'componentManager');
        variable = componentManager.GetActiveAutoComponentVariable(item_selected);
    end

    [m, n] = size(variable.Value);
    if((m > 1 || n > 1) && not(ischar(variable.Value)))
        set(handles.auto_value_edit, 'String', [num2str(m) ', ' num2str(n)]);
        set(handles.auto_unit_edit, 'String', 'Size');
    else
        set(handles.auto_value_edit, 'String', num2str(variable.Value));
        set(handles.auto_unit_edit, 'String', variable.Unit);
    end
    
    set(handles.auto_min_edit, 'String', variable.Min);
    set(handles.auto_max_edit, 'String', variable.Max);
    set_radio_buttons(variable.MinAction, 'min', 'auto', handles)
    set_radio_buttons(variable.MaxAction, 'max', 'auto', handles)
    set(handles.auto_documentation_edit, 'String', variable.Documentation);
end

function auto_new_variable_pushbutton_Callback(hObject, eventdata, handles)
new_auto_variable(handles);
auto_listbox_CreateFcn(handles.auto_listbox, eventdata, handles);

function auto_delete_variable_pushbutton_Callback(hObject, eventdata, handles)
delete_auto_variable(handles)
auto_listbox_CreateFcn(handles.auto_listbox, eventdata, handles);

function auto_set_variable_setup_pushbutton_Callback(hObject, eventdata, handles)
set_auto_variable_setup();

function auto_info_pushbutton_Callback(hObject, eventdata, handles)
open_component_documentation('Auto', 0);

% Variable UI Controls ----------------------------------------------------

function auto_value_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function auto_value_edit_Callback(hObject, eventdata, handles)
variable = get_active_auto_variable_name(handles);
if(not(isempty(variable)))
    set_active_auto_variable_property(variable, 'value', get(hObject, 'String'), handles);
    auto_listbox_Callback(handles.auto_listbox, eventdata, handles);
end

function auto_value_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_auto_variable_path('Value', handles);

function auto_unit_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function auto_unit_edit_Callback(hObject, eventdata, handles)
variable = get_active_auto_variable_name(handles);
if(not(isempty(variable)))
    set_active_auto_variable_property(variable, 'unit', get(hObject, 'String'), handles);
    auto_listbox_Callback(handles.auto_listbox, eventdata, handles);
end

function auto_unit_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_auto_variable_path('Unit', handles);

function auto_min_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function auto_min_edit_Callback(hObject, eventdata, handles)
variable = get_active_auto_variable_name(handles);
if(not(isempty(variable)))
    set_active_auto_variable_property(variable, 'min', get(hObject, 'String'), handles);
    auto_listbox_Callback(handles.auto_listbox, eventdata, handles);
end

function auto_min_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_auto_variable_path('Min', handles);

function auto_max_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function auto_max_edit_Callback(hObject, eventdata, handles)
variable = get_active_auto_variable_name(handles);
if(not(isempty(variable)))
    set_active_auto_variable_property(variable, 'max', get(hObject, 'String'), handles);
    auto_listbox_Callback(handles.auto_listbox, eventdata, handles);
end

function auto_max_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_auto_variable_path('Max', handles);

function auto_documentation_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function auto_documentation_edit_Callback(hObject, eventdata, handles)
variable = get_active_auto_variable_name(handles);
if(not(isempty(variable)))
    set_active_auto_variable_property(variable, 'documentation', get(hObject, 'String'), handles);
    auto_listbox_Callback(handles.auto_listbox, eventdata, handles);
end

function auto_min_info_radiobutton_Callback(hObject, eventdata, handles)
auto_set_min_radiobutton(1, handles);
set_clipboard_auto_variable_path('MinAction', handles);

function auto_min_warn_radiobutton_Callback(hObject, eventdata, handles)
auto_set_min_radiobutton(2, handles);
set_clipboard_auto_variable_path('MinAction', handles);

function auto_min_error_radiobutton_Callback(hObject, eventdata, handles)
auto_set_min_radiobutton(3, handles);
set_clipboard_auto_variable_path('MinAction', handles);

function auto_max_info_radiobutton_Callback(hObject, eventdata, handles)
auto_set_max_radiobutton(1, handles);
set_clipboard_auto_variable_path('MaxAction', handles);

function auto_max_warn_radiobutton_Callback(hObject, eventdata, handles)
auto_set_max_radiobutton(2, handles);
set_clipboard_auto_variable_path('MaxAction', handles);

function auto_max_error_radiobutton_Callback(hObject, eventdata, handles)
auto_set_max_radiobutton(3, handles);
set_clipboard_auto_variable_path('MaxAction', handles);

function auto_set_min_radiobutton(entry, handles)
variable = get_active_auto_variable_name(handles);
if(not(isempty(variable)))
    set_active_auto_variable_property(variable, 'min_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'min', 'auto', handles)

function auto_set_max_radiobutton(entry, handles)
variable = get_active_auto_variable_name(handles);
if(not(isempty(variable)))
    set_active_auto_variable_property(variable, 'max_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'max', 'auto', handles)

%--------------------------------------------------------------------------
% Strecke
%--------------------------------------------------------------------------

function strecke_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, index] = get_strecke_component_names();
set(hObject, 'Value', index);
set(hObject, 'String', list);
% Update the based on text field below the preset popup menu
if(is_experiment_mode(handles))
    set(handles.strecke_based_on_text, 'String', get_based_on_text('Strecke', 0));
end
if(not(isempty(handles)))
    strecke_listbox_CreateFcn(handles.strecke_listbox, eventdata, handles)
end

function strecke_popupmenu_Callback(hObject, eventdata, handles)
global experimentRunManager;
% Get the name of the item selcted in the popup menu
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% If the item is not named 'Null', set the component as the active component
if(not(strcmp(item_selected, 'Null')))
    componentManager = evalin('base', 'componentManager');
    componentManager = componentManager.SetActiveComponent('Strecke', 0, item_selected);
    assignin('base', 'componentManager', componentManager);
    if(is_experiment_mode(handles))
        % If experiment mode is enabled, use the selected component to
        % overwrite the component of the same type in the currently active
        % experiment run. Then, update the auto_popupmenu widget
        component = componentManager.GetActiveStreckeComponent();
        experimentRunManager = experimentRunManager.SaveComponentToActiveExperimentRun(component);
        experimentRunManager.LoadComponentFromActiveExperimentRun(component.Type, component.SubType, component.Variant);
        strecke_popupmenu_CreateFcn(handles.strecke_popupmenu, eventdata, handles)
        return;
    end
end
% Update the popupmenus and all dependant widgets
if(not(isempty(handles)))
    strecke_listbox_CreateFcn(handles.strecke_listbox, eventdata, handles)
end

function strecke_new_preset_pushbutton_Callback(hObject, eventdata, handles)
new_strecke_preset()
strecke_popupmenu_CreateFcn(handles.strecke_popupmenu, eventdata, handles);

function strecke_delete_preset_pushbutton_Callback(hObject, eventdata, handles)
delete_strecke_preset(handles)
strecke_popupmenu_CreateFcn(handles.strecke_popupmenu, eventdata, handles);

function strecke_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
componentManager = evalin('base', 'componentManager');
list = componentManager.GetActiveStreckeComponentVariableNames();
list = sort(list);
% If list position is greater than the new list length, set to last item
lList = length(list);
if(get(hObject, 'Value') > lList)
    if(lList == 0)
        set(hObject, 'Value', 1);
    else
        set(hObject, 'Value', lList);
    end
end
set(hObject, 'String', list);
strecke_listbox_Callback(hObject, eventdata, handles)

function strecke_listbox_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
if(not(isempty(items)) && not(isempty(handles)))
    index_selected = get(hObject, 'Value');
    item_selected = items{index_selected};
    componentManager = evalin('base', 'componentManager');
    variable = componentManager.GetActiveStreckeComponentVariable(item_selected);
    try
        [m, n] = size(variable.Value);
    catch ME
        variable
        rethrow(ME)
    end
    if((m > 1 || n > 1) && not(ischar(variable.Value)))
        set(handles.strecke_value_edit, 'String', [num2str(m) ', ' num2str(n)]);
        set(handles.strecke_unit_edit, 'String', 'Size');
    else
        set(handles.strecke_value_edit, 'String', num2str(variable.Value));
        set(handles.strecke_unit_edit, 'String', variable.Unit);
    end
    
    set(handles.strecke_min_edit, 'String', variable.Min);
    set(handles.strecke_max_edit, 'String', variable.Max);
    set_radio_buttons(variable.MinAction, 'min', 'strecke', handles)
    set_radio_buttons(variable.MaxAction, 'max', 'strecke', handles)
    set(handles.strecke_documentation_edit, 'String', variable.Documentation);
end

function strecke_new_variable_pushbutton_Callback(hObject, eventdata, handles)
new_strecke_variable(handles);
strecke_listbox_CreateFcn(handles.strecke_listbox, eventdata, handles);

function strecke_delete_variable_pushbutton_Callback(hObject, eventdata, handles)
delete_strecke_variable(handles)
strecke_listbox_CreateFcn(handles.strecke_listbox, eventdata, handles);

function strecke_set_variable_setup_pushbutton_Callback(hObject, eventdata, handles)
set_strecke_variable_setup();

function strecke_info_pushbutton_Callback(hObject, eventdata, handles)
open_component_documentation('Strecke', 0)

% Variable UI Controls ----------------------------------------------------

function strecke_value_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function strecke_value_edit_Callback(hObject, eventdata, handles)
variable = get_active_strecke_variable_name(handles);
if(not(isempty(variable)))
    set_active_strecke_variable_property(variable, 'value', get(hObject, 'String'), handles);
    strecke_listbox_Callback(handles.strecke_listbox, eventdata, handles);
end

function strecke_value_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_strecke_variable_path('Value', handles);

function strecke_unit_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function strecke_unit_edit_Callback(hObject, eventdata, handles)
variable = get_active_strecke_variable_name(handles);
if(not(isempty(variable)))
    set_active_strecke_variable_property(variable, 'unit', get(hObject, 'String'), handles);
    strecke_listbox_Callback(handles.strecke_listbox, eventdata, handles);
end

function strecke_unit_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_strecke_variable_path('Unit', handles);

function strecke_min_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function strecke_min_edit_Callback(hObject, eventdata, handles)
variable = get_active_strecke_variable_name(handles);
if(not(isempty(variable)))
    set_active_strecke_variable_property(variable, 'min', get(hObject, 'String'), handles);
    strecke_listbox_Callback(handles.strecke_listbox, eventdata, handles);
end

function strecke_min_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_strecke_variable_path('Min', handles);

function strecke_max_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function strecke_max_edit_Callback(hObject, eventdata, handles)
variable = get_active_strecke_variable_name(handles);
if(not(isempty(variable)))
    set_active_strecke_variable_property(variable, 'max', get(hObject, 'String'), handles);
    strecke_listbox_Callback(handles.strecke_listbox, eventdata, handles);
end

function strecke_max_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_strecke_variable_path('Max', handles);

function strecke_documentation_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function strecke_documentation_edit_Callback(hObject, eventdata, handles)
variable = get_active_strecke_variable_name(handles);
if(not(isempty(variable)))
    set_active_strecke_variable_property(variable, 'documentation', get(hObject, 'String'), handles);
    strecke_listbox_Callback(handles.strecke_listbox, eventdata, handles);
end

function strecke_min_info_radiobutton_Callback(hObject, eventdata, handles)
strecke_set_min_radiobutton(1, handles);

function strecke_min_warn_radiobutton_Callback(hObject, eventdata, handles)
strecke_set_min_radiobutton(2, handles);

function strecke_min_error_radiobutton_Callback(hObject, eventdata, handles)
strecke_set_min_radiobutton(3, handles);

function strecke_max_info_radiobutton_Callback(hObject, eventdata, handles)
strecke_set_max_radiobutton(1, handles);

function strecke_max_warn_radiobutton_Callback(hObject, eventdata, handles)
strecke_set_max_radiobutton(2, handles);

function strecke_max_error_radiobutton_Callback(hObject, eventdata, handles)
strecke_set_max_radiobutton(3, handles);

function strecke_set_min_radiobutton(entry, handles)
variable = get_active_strecke_variable_name(handles);
if(not(isempty(variable)))
    set_active_strecke_variable_property(variable, 'min_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'min', 'strecke', handles)

function strecke_set_max_radiobutton(entry, handles)
variable = get_active_strecke_variable_name(handles);
if(not(isempty(variable)))
    set_active_strecke_variable_property(variable, 'max_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'max', 'strecke', handles)

%--------------------------------------------------------------------------
% Energie Management System
%--------------------------------------------------------------------------

function ems_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[liste, index] = get_ems_component_names();
set(hObject, 'String', liste);
set(hObject, 'Value', index);
% Update the based on text field below the preset popup menu
if(is_experiment_mode(handles))
    set(handles.ems_based_on_text, 'String', get_based_on_text('Ems', 0));
end
if(not(isempty(handles)))
    ems_listbox_CreateFcn(handles.ems_listbox, eventdata, handles);
end

function ems_popupmenu_Callback(hObject, eventdata, handles)
global experimentRunManager;
% Get the name of the item selcted in the popup menu
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
% If the item is not named 'Null', set the component as the active component
if(not(strcmp(item_selected, 'Null')))
    componentManager = evalin('base', 'componentManager');
    componentManager = componentManager.SetActiveComponent('Ems', 0, item_selected);
    assignin('base', 'componentManager', componentManager);
    if(is_experiment_mode(handles))
        % If experiment mode is enabled, use the selected component to
        % overwrite the component of the same type in the currently active
        % experiment run. Then, update the auto_popupmenu widget
        component = componentManager.GetActiveEmsComponent();
        experimentRunManager = experimentRunManager.SaveComponentToActiveExperimentRun(component);
        experimentRunManager.LoadComponentFromActiveExperimentRun(component.Type, component.SubType, component.Variant);
        ems_popupmenu_CreateFcn(handles.ems_popupmenu, eventdata, handles)
        return;
    end
end
% Update the popupmenus and all dependant widgets
if(not(isempty(handles)))
    ems_listbox_CreateFcn(handles.ems_listbox, eventdata, handles);
end

function ems_new_preset_pushbutton_Callback(hObject, eventdata, handles)
new_ems_preset();
ems_popupmenu_CreateFcn(handles.ems_popupmenu, eventdata, handles);

function ems_delete_preset_pushbutton_Callback(hObject, eventdata, handles)
delete_ems_preset(handles);
ems_popupmenu_CreateFcn(handles.ems_popupmenu, eventdata, handles);

function ems_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
componentManager = evalin('base', 'componentManager');
list = componentManager.GetActiveEmsComponentVariableNames();
list = sort(list);
% If list position is greater than the new list length, set to last item
lList = length(list);
if(get(hObject, 'Value') > lList)
    if(lList == 0)
        set(hObject, 'Value', 1);
    else
        set(hObject, 'Value', lList);
    end
end
set(hObject, 'String', list);
ems_listbox_Callback(hObject, eventdata, handles)

function ems_listbox_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
if(not(isempty(items)) && not(isempty(handles)))
    index_selected = get(hObject, 'Value');
    item_selected = items{index_selected};
    componentManager = evalin('base', 'componentManager');
    variable = componentManager.GetActiveEmsComponentVariable(item_selected);
    try
        [m, n] = size(variable.Value);
    catch ME
        variable
        rethrow(ME)
    end
    if((m > 1 || n > 1) && not(ischar(variable.Value)))
        set(handles.ems_value_edit, 'String', [num2str(m) ', ' num2str(n)]);
        set(handles.ems_unit_edit, 'String', 'Size');
    else
        set(handles.ems_value_edit, 'String', num2str(variable.Value));
        set(handles.ems_unit_edit, 'String', variable.Unit);
    end
    
    set(handles.ems_min_edit, 'String', variable.Min);
    set(handles.ems_max_edit, 'String', variable.Max);
    set_radio_buttons(variable.MinAction, 'min', 'ems', handles)
    set_radio_buttons(variable.MaxAction, 'max', 'ems', handles)
    set(handles.ems_documentation_edit, 'String', variable.Documentation);
end

function ems_new_variable_pushbutton_Callback(hObject, eventdata, handles)
new_ems_variable(handles);
ems_listbox_CreateFcn(handles.ems_listbox, eventdata, handles);

function ems_delete_variable_pushbutton_Callback(hObject, eventdata, handles)
delete_ems_variable(handles);
ems_listbox_CreateFcn(handles.ems_listbox, eventdata, handles);

function ems_set_variable_setup_pushbutton_Callback(hObject, eventdata, handles)
set_ems_variable_setup();

function ems_info_pushbutton_Callback(hObject, eventdata, handles)
open_component_documentation('Ems', 0);

% Variable UI Controls ----------------------------------------------------

function ems_value_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function ems_value_edit_Callback(hObject, eventdata, handles)
variable = get_active_ems_variable_name(handles);
if(not(isempty(variable)))
    set_active_ems_variable_property(variable, 'value', get(hObject, 'String'), handles);
    ems_listbox_Callback(handles.ems_listbox, eventdata, handles);
else
    'empty value handle'
end

function ems_value_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_ems_variable_path('Value', handles);

function ems_unit_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function ems_unit_edit_Callback(hObject, eventdata, handles)
variable = get_active_ems_variable_name(handles);
if(not(isempty(variable)))
    set_active_ems_variable_property(variable, 'unit', get(hObject, 'String'), handles);
    ems_listbox_Callback(handles.ems_listbox, eventdata, handles);
end

function ems_unit_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_ems_variable_path('Unit', handles);

function ems_min_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function ems_min_edit_Callback(hObject, eventdata, handles)
variable = get_active_ems_variable_name(handles);
if(not(isempty(variable)))
    set_active_ems_variable_property(variable, 'min', get(hObject, 'String'), handles);
    ems_listbox_Callback(handles.ems_listbox, eventdata, handles);
end

function ems_min_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_ems_variable_path('Min', handles);

function ems_max_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function ems_max_edit_Callback(hObject, eventdata, handles)
variable = get_active_ems_variable_name(handles);
if(not(isempty(variable)))
    set_active_ems_variable_property(variable, 'max', get(hObject, 'String'), handles);
    ems_listbox_Callback(handles.ems_listbox, eventdata, handles);
end

function ems_max_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_ems_variable_path('Max', handles);

function ems_documentation_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function ems_documentation_edit_Callback(hObject, eventdata, handles)
variable = get_active_ems_variable_name(handles);
if(not(isempty(variable)))
    set_active_ems_variable_property(variable, 'documentation', get(hObject, 'String'), handles);
    ems_listbox_Callback(handles.ems_listbox, eventdata, handles);
end

function ems_min_info_radiobutton_Callback(hObject, eventdata, handles)
ems_set_min_radiobutton(1, handles);

function ems_min_warn_radiobutton_Callback(hObject, eventdata, handles)
ems_set_min_radiobutton(2, handles);

function ems_min_error_radiobutton_Callback(hObject, eventdata, handles)
ems_set_min_radiobutton(3, handles);

function ems_max_info_radiobutton_Callback(hObject, eventdata, handles)
ems_set_max_radiobutton(1, handles);

function ems_max_warn_radiobutton_Callback(hObject, eventdata, handles)
ems_set_max_radiobutton(2, handles);

function ems_max_error_radiobutton_Callback(hObject, eventdata, handles)
ems_set_max_radiobutton(3, handles);

function ems_set_min_radiobutton(entry, handles)
variable = get_active_ems_variable_name(handles);
if(not(isempty(variable)))
    set_active_ems_variable_property(variable, 'min_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'min', 'ems', handles)

function ems_set_max_radiobutton(entry, handles)
variable = get_active_ems_variable_name(handles);
if(not(isempty(variable)))
    set_active_ems_variable_property(variable, 'max_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'max', 'ems', handles)

%--------------------------------------------------------------------------
% Hardware Components
%--------------------------------------------------------------------------

function atm_1_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_atm_component_names(1);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function atm_1_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_atm_component(1, hObject, handles);
update_atm_component_popupmenus(handles, eventdata);
hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles);

function atm_1_component_checkbox_Callback(hObject, eventdata, handles)
if(not(strcmp(handles.atm_1_component_popupmenu.String, 'Null')))
    if(get(hObject, 'Value'))
        set_active_variable_property('Atm', 1, 'GsqErsatzEnable', 'value', 1, handles);
    else
        set_active_variable_property('Atm', 1, 'GsqErsatzEnable', 'value', 0, handles);
    end
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function atm_2_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_atm_component_names(2);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function atm_2_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_atm_component(2, hObject, handles);
update_atm_component_popupmenus(handles, eventdata);
hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles);

function atm_2_component_checkbox_Callback(hObject, eventdata, handles)
if(not(strcmp(handles.atm_2_component_popupmenu.String, 'Null')))
    if(get(hObject, 'Value'))
        set_active_variable_property('Atm', 2, 'GsqErsatzEnable', 'value', 1, handles);
    else
        set_active_variable_property('Atm', 2, 'GsqErsatzEnable', 'value', 0, handles);
    end
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function eq_1_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_eq_component_names(1);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_1_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_eq_component(1, hObject, handles);
update_eq_component_popupmenus(handles, eventdata);

function eq_1_component_checkbox_Callback(hObject, eventdata, handles)
if(not(strcmp(handles.eq_1_component_popupmenu.String, 'Null')))
    if(get(hObject, 'Value'))
        set_active_variable_property('Eq', 1, 'GsqErsatzEnable', 'value', 1, handles);
    else
        set_active_variable_property('Eq', 1, 'GsqErsatzEnable', 'value', 0, handles);
    end
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function eq_2_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_eq_component_names(2);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_2_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_eq_component(2, hObject, handles);
update_eq_component_popupmenus(handles, eventdata);

function eq_2_component_checkbox_Callback(hObject, eventdata, handles)
if(not(strcmp(handles.eq_2_component_popupmenu.String, 'Null')))
    if(get(hObject, 'Value'))
        set_active_variable_property('Eq', 2, 'GsqErsatzEnable', 'value', 1, handles);
    else
        set_active_variable_property('Eq', 2, 'GsqErsatzEnable', 'value', 0, handles);
    end
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function eq_3_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_eq_component_names(3);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_3_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_eq_component(3, hObject, handles);
update_eq_component_popupmenus(handles, eventdata);

function eq_3_component_checkbox_Callback(hObject, eventdata, handles)
if(not(strcmp(handles.eq_3_component_popupmenu.String, 'Null')))
    if(get(hObject, 'Value'))
        set_active_variable_property('Eq', 3, 'GsqErsatzEnable', 'value', 1, handles);
    else
        set_active_variable_property('Eq', 3, 'GsqErsatzEnable', 'value', 0, handles);
    end
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function eq_4_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_eq_component_names(4);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_4_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_eq_component(4, hObject, handles);
update_eq_component_popupmenus(handles, eventdata);

function eq_4_component_checkbox_Callback(hObject, eventdata, handles)
if(not(strcmp(handles.eq_4_component_popupmenu.String, 'Null')))
    if(get(hObject, 'Value'))
        set_active_variable_property('Eq', 4, 'GsqErsatzEnable', 'value', 1, handles);
    else
        set_active_variable_property('Eq', 4, 'GsqErsatzEnable', 'value', 0, handles);
    end
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function eq_5_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_eq_component_names(5);
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function eq_5_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_eq_component(5, hObject, handles);
update_eq_component_popupmenus(handles, eventdata);

function eq_5_component_checkbox_Callback(hObject, eventdata, handles)
if(not(strcmp(handles.eq_5_component_popupmenu.String, 'Null')))
    if(get(hObject, 'Value'))
        set_active_variable_property('Eq', 5, 'GsqErsatzEnable', 'value', 1, handles);
    else
        set_active_variable_property('Eq', 5, 'GsqErsatzEnable', 'value', 0, handles);
    end
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function last_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_last_component_names();
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function last_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_last_component(hObject, handles);
update_last_component_popupmenus(handles, eventdata);

function gsq_component_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
[list, mode] = get_gsq_component_names();
set(hObject, 'String', list);
set(hObject, 'Value', mode);

function gsq_component_popupmenu_Callback(hObject, eventdata, handles)
set_active_gsq_component(hObject, handles)
update_gsq_component_popupmenus(handles, eventdata);

% Preset Controls ---------------------------------------------------------

function hardware_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global variantManager;
hardwareList = {};
% Find all Atm slots with non-null variants
for i = 1:variantManager.VariantsInfo.AtmLastVirtuellAnzahl
    [list, mode] = variantManager.GetAtm(i);
    activeAtm = list(mode);
    if(not(strcmp(activeAtm{:}, 'Null')))
        if(isempty(hardwareList))
            hardwareList = {['Atm ' num2str(i)]};
        else
            hardwareList = [hardwareList; ['Atm ' num2str(i)]];
        end
    end
end
% Find all Eq slots with non-null variants
for i = 1:variantManager.VariantsInfo.EqVirtuellAnzahl
   [list, mode] = variantManager.GetEq(i);
    activeEq = list(mode);
    if(not(strcmp(activeEq{:}, 'Null')))
        if(isempty(hardwareList))
            hardwareList = {['Eq ' num2str(i)]};
        else
            hardwareList = [hardwareList; ['Eq ' num2str(i)]];
        end
    end
end
% Find all Last slots with non-null variants
[list, mode] = variantManager.GetLast();
activeLast = list(mode);
if(not(strcmp(activeLast{:}, 'Null')))
    if(isempty(hardwareList))
        hardwareList = {'Last'};
    else
        hardwareList = [hardwareList; 'Last'];
    end
end
% Find all Gsq slots with non-null variants
[list, mode] = variantManager.GetGsq();
activeGsq = list(mode);
if(not(strcmp(activeGsq{:}, 'Null')))
    if(isempty(hardwareList))
        hardwareList = {'Gsq'};
    else
        hardwareList = [hardwareList; 'Gsq'];
    end
end
if(isempty(hardwareList))
    hardwareList = {'Null'};
end
set(hObject, 'String', hardwareList);
if(not(isempty(handles)))
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles);
end

function hardware_popupmenu_Callback(hObject, eventdata, handles)
if(not(isempty(handles)))
    hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)
end

function hardware_new_preset_pushbutton_Callback(hObject, eventdata, handles)
new_hardware_preset(handles);
update_hardware_component_popupmenus(handles, eventdata)
%hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles)

function hardware_delete_preset_pushbutton_Callback(hObject, eventdata, handles)
delete_hardware_preset(handles);
update_hardware_component_popupmenus(handles, eventdata)
%hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles);

function hardware_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

if(not(isempty(handles)))
    items = get(handles.hardware_popupmenu, 'String');
    index_selected = get(handles.hardware_popupmenu, 'Value');
    if(index_selected > length(items))
        if(isempty(items))
            index_selected = 1;
        else
            index_selected = length(items);
        end
        set(handles.hardware_popupmenu, 'Value', index_selected);
    end
    item_selected = items{index_selected};
    type = strtok(item_selected, ' ');
    componentManager = evalin('base', 'componentManager');
    list = {};
    slot = 0;
    switch type
        case 'Atm'
            slot = str2double(item_selected(length(item_selected)));
            list = componentManager.GetActiveAtmComponentVariableNames(slot);
        case 'Last'
            list = componentManager.GetActiveLastComponentVariableNames();
        case 'Eq'
            slot = str2double(item_selected(length(item_selected)));
            list = componentManager.GetActiveEqComponentVariableNames(slot);
        case 'Gsq'
            list = componentManager.GetActiveGsqComponentVariableNames();
    end
    list = sort(list);
    % If list position is greater than the new list length, set to last item
    lList = length(list);
    if(get(hObject, 'Value') > lList)
        if(lList == 0)
            set(hObject, 'Value', 1);
        else
            set(hObject, 'Value', lList);
        end
    end
    set(hObject, 'String', list);
    update_hardware_component_checkboxes(handles);
    % Update the based on text field below the preset popup menu
    if(is_experiment_mode(handles))
        set(handles.hardware_based_on_text, 'String', get_based_on_text(type, slot));
    end
    hardware_listbox_Callback(hObject, eventdata, handles)
end

function hardware_listbox_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
if(not(isempty(items)))
    [type, slot] = get_hardware_type_and_slot(handles);
    item_selected = items{index_selected};
    componentManager = evalin('base', 'componentManager');
    variable = 0;
    switch type
        case 'Atm'
            variable = componentManager.GetActiveAtmComponentVariable(item_selected, slot);
        case 'Last'
            variable = componentManager.GetActiveLastComponentVariable(item_selected);
        case 'Eq'
            variable = componentManager.GetActiveEqComponentVariable(item_selected, slot);
        case 'Gsq'
            variable = componentManager.GetActiveGsqComponentVariable(item_selected);
    end
else
    variable = ModelVariable('Null', 0);
end

[m, n] = size(variable.Value);
if((m > 1 || n > 1) && not(ischar(variable.Value)))
    set(handles.hardware_value_edit, 'String', [num2str(m) ', ' num2str(n)]);
    set(handles.hardware_unit_edit, 'String', 'Matrix');
else
    set(handles.hardware_value_edit, 'String', num2str(variable.Value));
    set(handles.hardware_unit_edit, 'String', variable.Unit);
end

set(handles.hardware_min_edit, 'String', variable.Min);
set(handles.hardware_max_edit, 'String', variable.Max);
set_radio_buttons(variable.MinAction, 'min', 'hardware', handles)
set_radio_buttons(variable.MaxAction, 'max', 'hardware', handles)
set(handles.hardware_documentation_edit, 'String', variable.Documentation);

function hardware_new_variable_pushbutton_Callback(hObject, eventdata, handles)
new_hardware_variable(handles);
hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)

function hardware_delete_variable_pushbutton_Callback(hObject, eventdata, handles)
delete_hardware_variable(handles);
hardware_listbox_CreateFcn(handles.hardware_listbox, eventdata, handles)

function hardware_set_variable_setup_pushbutton_Callback(hObject, eventdata, handles)
set_hardware_variable_setup(handles);

function hardware_info_pushbutton_Callback(hObject, eventdata, handles)
[type, slot] = get_hardware_type_and_slot(handles);
open_component_documentation(type, slot)

% Variable UI Controls ----------------------------------------------------

function hardware_value_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function hardware_value_edit_Callback(hObject, eventdata, handles)
variable = get_active_hardware_variable_name(handles);
if(not(isempty(variable)))
    [type, slot] = get_hardware_type_and_slot(handles);
    set_active_hardware_variable_property(type, slot, variable, 'value', get(hObject, 'String'), handles);
    hardware_listbox_Callback(handles.hardware_listbox, eventdata, handles);
    if(strcmp(variable, 'GsqErsatzEnable'))
        value = str2double(get(hObject, 'String'));
        switch type
            case 'Atm'
                handles.(['atm_' num2str(slot) '_component_checkbox']).Value = value;
            case 'Eq'
                handles.(['eq_' num2str(slot) '_component_checkbox']).Value = value;
        end
    end
end

function hardware_value_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_hardware_variable_path('Value', handles);

function hardware_unit_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function hardware_unit_edit_Callback(hObject, eventdata, handles)
variable = get_active_hardware_variable_name(handles);
if(not(isempty(variable)))
    [type, slot] = get_hardware_type_and_slot(handles);
    set_active_hardware_variable_property(type, slot, variable, 'unit', get(hObject, 'String'), handles);
    hardware_listbox_Callback(handles.hardware_listbox, eventdata, handles);
end

function hardware_unit_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_hardware_variable_path('Unit', handles);

function hardware_min_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function hardware_min_edit_Callback(hObject, eventdata, handles)
variable = get_active_hardware_variable_name(handles);
if(not(isempty(variable)))
    [type, slot] = get_hardware_type_and_slot(handles);
    set_active_hardware_variable_property(type, slot, variable, 'min', get(hObject, 'String'), handles);
    hardware_listbox_Callback(handles.hardware_listbox, eventdata, handles);
end

function hardware_min_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_hardware_variable_path('Min', handles);

function hardware_max_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function hardware_max_edit_Callback(hObject, eventdata, handles)
variable = get_active_hardware_variable_name(handles);
if(not(isempty(variable)))
    [type, slot] = get_hardware_type_and_slot(handles);
    set_active_hardware_variable_property(type, slot, variable, 'max', get(hObject, 'String'), handles);
    hardware_listbox_Callback(handles.hardware_listbox, eventdata, handles);
end

function hardware_max_pushbutton_Callback(hObject, eventdata, handles)
set_clipboard_hardware_variable_path('Max', handles);

function hardware_documentation_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');

function hardware_documentation_edit_Callback(hObject, eventdata, handles)
variable = get_active_hardware_variable_name(handles);
if(not(isempty(variable)))
    [type, slot] = get_hardware_type_and_slot(handles);
    set_active_hardware_variable_property(type, slot, variable, 'documentation', get(hObject, 'String'), handles);
    hardware_listbox_Callback(handles.hardware_listbox, eventdata, handles);
end

function hardware_min_info_radiobutton_Callback(hObject, eventdata, handles)
hardware_set_min_radiobutton(1, handles);

function hardware_min_warn_radiobutton_Callback(hObject, eventdata, handles)
hardware_set_min_radiobutton(2, handles);

function hardware_min_error_radiobutton_Callback(hObject, eventdata, handles)
hardware_set_min_radiobutton(3, handles);

function hardware_max_info_radiobutton_Callback(hObject, eventdata, handles)
hardware_set_max_radiobutton(1, handles);

function hardware_max_warn_radiobutton_Callback(hObject, eventdata, handles)
hardware_set_max_radiobutton(2, handles);

function hardware_max_error_radiobutton_Callback(hObject, eventdata, handles)
hardware_set_max_radiobutton(3, handles);

function hardware_set_min_radiobutton(entry, handles)
if(not(isempty(handles)))
    variable = get_active_hardware_variable_name(handles);
else
    variable = 0;
end
if(variable ~= 0)
    [type, slot] = get_hardware_type_and_slot(handles);
    set_active_hardware_variable_property(type, slot, variable, 'min_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'min', 'hardware', handles)

function hardware_set_max_radiobutton(entry, handles)
if(not(isempty(handles)) || not(isempty(get(handles.hardware_listbox, 'String'))))
    variable = get_active_hardware_variable_name(handles);
else
    variable = 0;
end
if(not(isempty(variable)))
    [type, slot] = get_hardware_type_and_slot(handles);
    set_active_hardware_variable_property(type, slot, variable, 'max_action', entry, handles);
else
    entry = 0;
end

set_radio_buttons(entry, 'max', 'hardware', handles)

% Local GUI Internal Utility Methods --------------------------------------

function update_hardware_component_popupmenus(handles, eventdata)
update_atm_component_popupmenus(handles, eventdata)
update_eq_component_popupmenus(handles, eventdata)
update_last_component_popupmenus(handles, eventdata)
update_gsq_component_popupmenus(handles, eventdata)
update_hardware_component_checkboxes(handles)
hardware_popupmenu_CreateFcn(handles.hardware_popupmenu, eventdata, handles)

function update_atm_component_popupmenus(handles, eventdata)
atm_1_component_popupmenu_CreateFcn(handles.atm_1_component_popupmenu, eventdata, handles)
atm_2_component_popupmenu_CreateFcn(handles.atm_2_component_popupmenu, eventdata, handles)

function update_eq_component_popupmenus(handles, eventdata)
eq_1_component_popupmenu_CreateFcn(handles.eq_1_component_popupmenu, eventdata, handles)
eq_2_component_popupmenu_CreateFcn(handles.eq_2_component_popupmenu, eventdata, handles)
eq_3_component_popupmenu_CreateFcn(handles.eq_3_component_popupmenu, eventdata, handles)
eq_4_component_popupmenu_CreateFcn(handles.eq_4_component_popupmenu, eventdata, handles)
eq_5_component_popupmenu_CreateFcn(handles.eq_5_component_popupmenu, eventdata, handles)

function update_last_component_popupmenus(handles, eventdata)
last_component_popupmenu_CreateFcn(handles.last_component_popupmenu, eventdata, handles)

function update_gsq_component_popupmenus(handles, eventdata)
gsq_component_popupmenu_CreateFcn(handles.gsq_component_popupmenu, eventdata, handles)

function update_hardware_component_checkboxes(handles)
global variantManager;
componentManager = evalin('base', 'componentManager');
for i = 1:variantManager.VariantsInfo.AtmLastVirtuellAnzahl
    [list, ~] = get_atm_component_names(i);
    if(not(strcmp(list, 'Null')))
        component = componentManager.GetActiveAtmComponent(i);
        if(isfield(component.Variables, 'GsqErsatzEnable'))
            value = component.Variables.GsqErsatzEnable.Value;
            set(handles.(['atm_' num2str(i) '_component_checkbox']), 'Value', value);
        end
    else
        set(handles.(['atm_' num2str(i) '_component_checkbox']), 'Value', 0);
    end
end
for i = 1:variantManager.VariantsInfo.EqVirtuellAnzahl
    [list, ~] = get_eq_component_names(i);
    if(not(strcmp(list, 'Null')))
        component = componentManager.GetActiveEqComponent(i);
        if(isfield(component.Variables, 'GsqErsatzEnable'))
            value = component.Variables.GsqErsatzEnable.Value;
            set(handles.(['eq_' num2str(i) '_component_checkbox']), 'Value', value);
        end
    else
        set(handles.(['eq_' num2str(i) '_component_checkbox']), 'Value', 0);
    end
end

function [type, slot] = get_hardware_type_and_slot(handles)
items = get(handles.hardware_popupmenu, 'String');
index_selected = get(handles.hardware_popupmenu, 'Value');
item_selected = items{index_selected};
type = strtok(item_selected, ' ');
slot = 0;
switch type
    case 'Atm'
        slot = str2double(item_selected(length(item_selected)));
    case 'Eq'
        slot = str2double(item_selected(length(item_selected)));
end

function set_hardware_type_and_slot(handles, type, slot)
% Sets the hardware_popupmenu to the requested type and slot

% Create the entry string that is to be searched for
items = get(handles.hardware_popupmenu, 'String');
switch type
    case 'Atm'
        entry = ['Atm ' num2str(slot)];
    case 'Last'
        entry = 'Last';
    case 'Eq'
        entry = ['Eq ' num2str(slot)];
    case 'Gsq'
        entry = 'Gsq';
    otherwise
        return;
end

% Find the index of the entry string
index = 0;
for i = 1:length(items)
    if(strcmp(entry, items(i)))
        index = i;
        break;
    end
end

% If the entry has been found, update the popup menu index
if(index ~= 0)
    set(handles.hardware_popupmenu, 'Value', index);
end

% Set Active Component ----------------------------------------------------

function set_active_atm_component(slot, hObject, handles)
global experimentRunManager;
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
if(not(strcmp(item_selected, 'Null')))
    componentManager = evalin('base', 'componentManager');
    componentManager = componentManager.SetActiveComponent('Atm', slot, item_selected);
    assignin('base', 'componentManager', componentManager);
    if(is_experiment_mode(handles))
        % If experiment mode is enabled, use the selected component to
        % overwrite the component of the same type in the currently active
        % experiment run. Then, update the auto_popupmenu widget
        component = componentManager.GetActiveAtmComponent(slot);
        experimentRunManager = experimentRunManager.SaveComponentToActiveExperimentRun(component);
        experimentRunManager.LoadComponentFromActiveExperimentRun(component.Type, component.SubType, component.Variant);
    end
end
set_hardware_type_and_slot(handles, 'Atm', slot);

function set_active_eq_component(slot, hObject, handles)
global experimentRunManager;
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
if(not(strcmp(item_selected, 'Null')))
    componentManager = evalin('base', 'componentManager');
    componentManager = componentManager.SetActiveComponent('Eq', slot, item_selected);
    assignin('base', 'componentManager', componentManager);
    if(is_experiment_mode(handles))
        % If experiment mode is enabled, use the selected component to
        % overwrite the component of the same type in the currently active
        % experiment run. Then, update the auto_popupmenu widget
        component = componentManager.GetActiveEqComponent(slot);
        experimentRunManager = experimentRunManager.SaveComponentToActiveExperimentRun(component);
        experimentRunManager.LoadComponentFromActiveExperimentRun(component.Type, component.SubType, component.Variant);
    end
end
set_hardware_type_and_slot(handles, 'Eq', slot);
    
function set_active_last_component(hObject, handles)
global experimentRunManager;
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
if(not(strcmp(item_selected, 'Null')))
    componentManager = evalin('base', 'componentManager');
    componentManager = componentManager.SetActiveComponent('Last', 0, item_selected);
    assignin('base', 'componentManager', componentManager);
    if(is_experiment_mode(handles))
        % If experiment mode is enabled, use the selected component to
        % overwrite the component of the same type in the currently active
        % experiment run. Then, update the auto_popupmenu widget
        component = componentManager.GetActiveLastComponent();
        experimentRunManager = experimentRunManager.SaveComponentToActiveExperimentRun(component);
        experimentRunManager.LoadComponentFromActiveExperimentRun(component.Type, component.SubType, component.Variant);
    end
end
set_hardware_type_and_slot(handles, 'Last', 0);

function set_active_gsq_component(hObject, handles)
global experimentRunManager;
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
item_selected = items{index_selected};
if(not(strcmp(item_selected, 'Null')))
    componentManager = evalin('base', 'componentManager');
    componentManager = componentManager.SetActiveComponent('Gsq', 0, item_selected);
    assignin('base', 'componentManager', componentManager);
    if(is_experiment_mode(handles))
        % If experiment mode is enabled, use the selected component to
        % overwrite the component of the same type in the currently active
        % experiment run. Then, update the auto_popupmenu widget
        component = componentManager.GetActiveGsqComponent();
        experimentRunManager = experimentRunManager.SaveComponentToActiveExperimentRun(component);
        experimentRunManager.LoadComponentFromActiveExperimentRun(component.Type, component.SubType, component.Variant);
    end
end
set_hardware_type_and_slot(handles, 'Gsq', 0);

%--------------------------------------------------------------------------
% Utility Methods
%--------------------------------------------------------------------------

function update_component_popupmenus(handles, eventdata)
auto_popupmenu_CreateFcn(handles.auto_popupmenu, eventdata, handles)
strecke_popupmenu_CreateFcn(handles.strecke_popupmenu, eventdata, handles)
ems_popupmenu_CreateFcn(handles.ems_popupmenu, eventdata, handles)
update_hardware_component_popupmenus(handles, eventdata)

function update_variant_popupmenus(handles, eventdata)
hardware_i_o_variant_popupmenu_CreateFcn(handles.hardware_i_o_variant_popupmenu, eventdata, handles)
virtuell_hardware_variant_popupmenu_CreateFcn(handles.virtuell_hardware_variant_popupmenu, eventdata, handles)
drive_sim_variant_popupmenu_CreateFcn(handles.drive_sim_variant_popupmenu, eventdata, handles)
ems_variant_popupmenu_CreateFcn(handles.ems_variant_popupmenu, eventdata, handles)
atm_1_variant_popupmenu_CreateFcn(handles.atm_1_variant_popupmenu, eventdata, handles)
atm_2_variant_popupmenu_CreateFcn(handles.atm_2_variant_popupmenu, eventdata, handles)
eq_1_variant_popupmenu_CreateFcn(handles.eq_1_variant_popupmenu, eventdata, handles)
eq_2_variant_popupmenu_CreateFcn(handles.eq_2_variant_popupmenu, eventdata, handles)
eq_3_variant_popupmenu_CreateFcn(handles.eq_3_variant_popupmenu, eventdata, handles)
eq_4_variant_popupmenu_CreateFcn(handles.eq_4_variant_popupmenu, eventdata, handles)
eq_5_variant_popupmenu_CreateFcn(handles.eq_5_variant_popupmenu, eventdata, handles)
last_variant_popupmenu_CreateFcn(handles.last_variant_popupmenu, eventdata, handles)
gsq_variant_popupmenu_CreateFcn(handles.gsq_variant_popupmenu, eventdata, handles)

% Get Component List and Mode ---------------------------------------------

function [list, index] = get_component_names(type, slot)
componentManager = evalin('base', 'componentManager');
% Set the correct index. Increment the index until the name in the list at 
% the index matches the active component
index = 1;
name = '';
switch type
    case 'Auto'
        list = componentManager.GetAutoComponentNames();
        name = componentManager.GetActiveAutoComponentName();
    case 'Strecke'
        list = componentManager.GetStreckeComponentNames();
        name = componentManager.GetActiveStreckeComponentName();
    case 'Ems'
        list = componentManager.GetEmsComponentNames();
        name = componentManager.GetActiveEmsComponentName();
    case 'Atm'
        list = componentManager.GetAtmComponentNames(slot);
        name = componentManager.GetActiveAtmComponentName(slot);
    case 'Last'
        list = componentManager.GetLastComponentNames();
        name = componentManager.GetActiveLastComponentName();
    case 'Eq'
        list = componentManager.GetEqComponentNames(slot);
        name = componentManager.GetActiveEqComponentName(slot);
    case 'Gsq'
        list = componentManager.GetGsqComponentNames();
        name = componentManager.GetActiveGsqComponentName();
end
list = sort(list);
if(not(isempty(name)))
    while (not(strcmp(list(index), name)) && index <= length(list))
        index = index + 1;
    end
end

function [list, index] = get_auto_component_names()
[list, index] = get_component_names('Auto', 0);

function [list, index] = get_strecke_component_names()
[list, index] = get_component_names('Strecke', 0);

function [list, index] = get_ems_component_names()
[list, index] = get_component_names('Ems', 0);

function [list, index] = get_atm_component_names(slot)
[list, index] = get_component_names('Atm', slot);

function [list, index] = get_eq_component_names(slot)
[list, index] = get_component_names('Eq', slot);

function [list, index] = get_gsq_component_names()
[list, index] = get_component_names('Gsq', 0);

function [list, index] = get_last_component_names()
[list, index] = get_component_names('Last', 0);

% Get Active Variable Name ------------------------------------------------

function item_selected = get_active_variable_name(listboxType, handles)
items = get(handles.([listboxType '_listbox']), 'String');
if(not(isempty(handles)) && not(isempty(items)))
    index_selected = get(handles.([listboxType '_listbox']), 'Value');
    item_selected = items{index_selected};
else
    item_selected = [];
end

function item_selected = get_active_auto_variable_name(handles)
item_selected = get_active_variable_name('auto', handles);

function item_selected = get_active_strecke_variable_name(handles)
item_selected = get_active_variable_name('strecke', handles);

function item_selected = get_active_ems_variable_name(handles)
item_selected = get_active_variable_name('ems', handles);

function item_selected = get_active_hardware_variable_name(handles)
item_selected = get_active_variable_name('hardware', handles);

% Set Active Variable Entry ------------------------------------------------

function set_active_variable_property(type, slot, variable, property, entry, handles)
componentManager = evalin('base', 'componentManager');
switch type
    case 'Auto'
        component = componentManager.GetActiveAutoComponent();
    case 'Strecke'
        component = componentManager.GetActiveStreckeComponent();
    case 'Ems'
        component = componentManager.GetActiveEmsComponent();
    case 'Atm'
        component = componentManager.GetActiveAtmComponent(slot);
    case 'Last'
        component = componentManager.GetActiveLastComponent();
    case 'Eq'
        component = componentManager.GetActiveEqComponent(slot);
    case 'Gsq'
        component = componentManager.GetActiveGsqComponent();
    otherwise
        component = [];
end
% Convert numbers from strings to double
if(not(isnan(str2double(entry))))
    entry = str2double(entry);
end
% Get the respective component
switch property
    case 'value'
        component = component.SetVariableValue(variable, entry);
    case 'unit'
        component = component.SetVariableUnit(variable, entry);
    case 'min'
        component = component.SetVariableMin(variable, entry);
    case 'max'
        component = component.SetVariableMax(variable, entry);
    case 'min_action'
        component = component.SetVariableMinAction(variable, entry);
    case 'max_action'
        component = component.SetVariableMaxAction(variable, entry);
    case 'documentation'
        component = component.SetVariableDocumentation(variable, entry);
    otherwise
        warning('set_active_variable_property can not handle the selected property');
end
% Save component to componentManager
if(not(isempty(component)))
    componentManager = componentManager.AddComponent(component);
    componentManager = componentManager.SetActiveComponent(type, slot, component.Name);
    assignin('base', 'componentManager', componentManager);
else
    warning(['Type: ' type ' Variable: ' variable ' Property: ' property ' Entry: ' entry]);
end
% Save to experimentRun if in Experiment Mode
global experimentRunManager;
if(is_experiment_mode(handles))
    experimentRun = experimentRunManager.GetActiveExperimentRun();
    experimentRun = experimentRun.AddComponent(component);
    experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);
end

function set_active_auto_variable_property(variable, property, entry, handles)
set_active_variable_property('Auto', 0, variable, property, entry, handles)

function set_active_strecke_variable_property(variable, property, entry, handles)
set_active_variable_property('Strecke', 0, variable, property, entry, handles)

function set_active_ems_variable_property(variable, property, entry, handles)
set_active_variable_property('Ems', 0, variable, property, entry, handles)

function set_active_hardware_variable_property(type, slot, variable, property, entry, handles)
set_active_variable_property(type, slot, variable, property, entry, handles)

% Set Radio Buttons -------------------------------------------------------

function set_radio_buttons(entry, minmax, type, handles)
% SET_RADIO_BUTTONS(entry, minmax, type, handles) Set the radiobuttons for
% the specified radiobutton set. Entry is the value of the min/max action.
% Type is for the section type {auto, strecke, ems, hardware}.

switch entry
    case 1
        handles.([type '_' minmax '_info_radiobutton']).Value = 1;
        handles.([type '_' minmax '_warn_radiobutton']).Value = 0;
        handles.([type '_' minmax '_error_radiobutton']).Value = 0;
    case 2
        handles.([type '_' minmax '_info_radiobutton']).Value = 0;
        handles.([type '_' minmax '_warn_radiobutton']).Value = 1;
        handles.([type '_' minmax '_error_radiobutton']).Value = 0;
    case 3
        handles.([type '_' minmax '_info_radiobutton']).Value = 0;
        handles.([type '_' minmax '_warn_radiobutton']).Value = 0;
        handles.([type '_' minmax '_error_radiobutton']).Value = 1;
    otherwise
        handles.([type '_' minmax '_info_radiobutton']).Value = 0;
        handles.([type '_' minmax '_warn_radiobutton']).Value = 0;
        handles.([type '_' minmax '_error_radiobutton']).Value = 0;
end

% Set Clipboard Variable Path ---------------------------------------------

function set_clipboard_variable_path(listboxType, type, slot, property, handles)
global variantManager;
[variant, subType] = variantManager.GetActiveVariant(type, slot);
variable = get_active_variable_name(listboxType, handles);
if(isempty(subType))
    data = ['componentManager.' type '.' variant '.Variables.' variable '.' property];
else
    data = ['componentManager.' type '.' subType '.' variant '.Variables.' variable '.' property];
end
clipboard('copy', data);

function set_clipboard_auto_variable_path(property, handles)
set_clipboard_variable_path('auto', 'Auto', 0, property, handles);

function set_clipboard_strecke_variable_path(property, handles)
set_clipboard_variable_path('strecke', 'Strecke', 0, property, handles);

function set_clipboard_ems_variable_path(property, handles)
set_clipboard_variable_path('ems', 'Ems', 0, property, handles);

function set_clipboard_hardware_variable_path(property, handles)
[type, slot] = get_hardware_type_and_slot(handles);
set_clipboard_variable_path('hardware', type, slot, property, handles);

% New Preset --------------------------------------------------------------

function new_preset(type, slot)
% Create a new preset for the selected type and slot
[name, parent_name] = get_new_name('Component', type, slot);
if(not(isempty(name)))
    if(isstrprop(name(1), 'alpha'))
        if(isstrprop(name, 'alphanum') & not(any(name >= 128)))
            name(1) = upper(name(1));
        else
            msgbox('Only alphanumeric characters are allowed to be present in the name', 'Invalid Name', 'warn');
            return;
        end
    else
        msgbox('The first character has to be a letter', 'Invalid Name', 'warn')
        return;
    end
else
    % Abort if name is empty
    return;
end
% Get the active variant and subtype
componentManager = evalin('base', 'componentManager');
global variantManager;
switch type
    case 'Auto'
        variant = variantManager.GetActiveDriveSim();
        subType = '';
    case 'Strecke'
        variant = variantManager.GetActiveDriveSim();
        subType = '';
    case 'Ems'
        variant = variantManager.GetActiveEms();
        subType = '';
    case 'Atm'
        [variant, subType] = variantManager.GetActiveAtm(slot);
    case 'Last'
        [variant, subType] = variantManager.GetActiveLast();
    case 'Eq'
        [variant, subType] = variantManager.GetActiveEq(slot);
    case 'Gsq'
        [variant, subType] = variantManager.GetActiveGsq();
end
% Either copy or create a new component
if(isempty(parent_name))
    component = Component(type, subType, variant, name);
else
    component = componentManager.GetComponent(type, subType, variant, parent_name);
    component.Name = name;
end
% Save and set as active the new component
componentManager = componentManager.AddComponent(component);
componentManager = componentManager.SetActiveComponent(type, slot, name);
        
assignin('base', 'componentManager', componentManager);

function new_auto_preset()
new_preset('Auto', 0);

function new_strecke_preset()
new_preset('Strecke', 0);

function new_ems_preset()
new_preset('Ems', 0);

function new_hardware_preset(handles)
[type, slot] = get_hardware_type_and_slot(handles);
new_preset(type, slot);

% Delete Preset -----------------------------------------------------------

function delete_preset(type, slot, popupmenu)
componentManager = evalin('base', 'componentManager');
items = get(popupmenu, 'String');
index_selected = get(popupmenu, 'Value');
item_selected = items{index_selected};

active_item = '';
if(length(items) <= 1)
    msgbox('Es muss mindestens ein preset fuer jeden Typ geben', 'Minimum Preset Anzahl', 'warn')
    return;
elseif(index_selected > 1)
    active_item = items{index_selected - 1};
else
    active_item = items{2};
end

switch type
    case 'Auto'
        componentManager = componentManager.DeleteActiveAutoComponent(item_selected);
        componentManager = componentManager.SetActiveComponent('Auto', 0, active_item);
    case 'Strecke'
        componentManager = componentManager.DeleteActiveStreckeComponent(item_selected);
        componentManager = componentManager.SetActiveComponent('Strecke', 0, active_item);
    case 'Ems'
        componentManager = componentManager.DeleteActiveEmsComponent(item_selected);
        componentManager = componentManager.SetActiveComponent('Ems', 0, active_item);
    case 'Atm'
        componentManager = componentManager.DeleteActiveAtmComponent(item_selected, slot);
        componentManager = componentManager.SetActiveComponent('Atm', slot, active_item);
    case 'Last'
        componentManager = componentManager.DeleteActiveLastComponent(item_selected);
        componentManager = componentManager.SetActiveComponent('Last', 0, active_item);
    case 'Eq'
        componentManager = componentManager.DeleteActiveEqComponent(item_selected, slot);
        componentManager = componentManager.SetActiveComponent('Eq', slot, active_item);
    case 'Gsq'
        componentManager = componentManager.DeleteActiveGsqComponent(item_selected);
        componentManager = componentManager.SetActiveComponent('Gsq', 0, active_item);
end
assignin('base', 'componentManager', componentManager);

function delete_auto_preset(handles)
delete_preset('Auto', 0, handles.auto_popupmenu)

function delete_strecke_preset(handles)
delete_preset('Strecke', 0, handles.strecke_popupmenu)

function delete_ems_preset(handles)
delete_preset('Ems', 0, handles.ems_popupmenu)

function delete_hardware_preset(handles)
[type, slot] = get_hardware_type_and_slot(handles);
switch type
    case 'Atm'
        delete_preset(type, slot, handles.(['atm_' num2str(slot) '_component_popupmenu']));
    case 'Last'
        delete_preset(type, slot, handles.last_component_popupmenu);
    case 'Eq'
        delete_preset(type, slot, handles.(['eq_' num2str(slot) '_component_popupmenu']));
    case 'Gsq'
        delete_preset(type, slot, handles.gsq_component_popupmenu);
end

% New Variable ------------------------------------------------------------

function new_variable(type, slot, listbox)
[name, parent_name] = get_new_name('ModelVariable', type, slot);
component = 0;
if(not(isempty(name)))
% Check the variable name and then add a new variable to the component
if(isstrprop(name(1), 'alpha'))
    if(isstrprop(name, 'alphanum') & not(any(name >= 128))) % Single & required
        name(1) = upper(name(1));
        % Get the active component for the selected type
        componentManager = evalin('base', 'componentManager');
        switch type
            case 'Auto'
                component = componentManager.GetActiveAutoComponent();
            case 'Strecke'
                component = componentManager.GetActiveStreckeComponent();
            case 'Ems'
                component = componentManager.GetActiveEmsComponent();
            case 'Atm'
                component = componentManager.GetActiveAtmComponent(slot);
            case 'Last'
                component = componentManager.GetActiveLastComponent();
            case 'Eq'
                component = componentManager.GetActiveEqComponent(slot);
            case 'Gsq'
                component = componentManager.GetActiveGsqComponent();
        end
        % Either create a new variable or copy one and change its name
        if(isempty(parent_name))
            component = component.NewVariable(name, 0);
        else
            variable = component.GetVariable(parent_name);
            variable.Name = name;
            component = component.AddVariable(variable);
        end
        % Save and set as active the changed component
        componentManager = componentManager.AddComponent(component);
        componentManager = componentManager.SetActiveComponent(type, slot, component.Name);
        assignin('base', 'componentManager', componentManager);
        % Sort and update the variable listbox with the new variables
        index = 1;
        list = get(listbox, 'String');
        list = sort([list; name]);
        % Find the index position of the new variable
        while(not(strcmp(list(index), name)) && index <= length(list))
            index = index + 1;
        end
        set(listbox, 'Value', index);
    else
        msgbox('Only alphanumeric characters are allowed to be present in the name', 'Invalid Name', 'warn')
        return;
    end
else
    msgbox('The first character has to be a letter', 'Invalid Name', 'warn')
    return;
end
end

function new_auto_variable(handles)
new_variable('Auto', 0, handles.auto_listbox);

function new_strecke_variable(handles)
new_variable('Strecke', 0, handles.strecke_listbox);

function new_ems_variable(handles)
new_variable('Ems', 0, handles.ems_listbox);

function new_hardware_variable(handles)
[type, slot] = get_hardware_type_and_slot(handles);
new_variable(type, slot, handles.hardware_listbox)

% Delete Variable ---------------------------------------------------------

function delete_variable(type, slot, listbox)
items = get(listbox, 'String');
if(isempty(items))
    return;
end
index_selected = get(listbox, 'Value');
item_selected = items{index_selected};
componentManager = evalin('base', 'componentManager');
component = 0;
switch type
    case 'Auto'
        component = componentManager.GetActiveAutoComponent();
    case 'Strecke'
        component = componentManager.GetActiveStreckeComponent();
    case 'Ems'
        component = componentManager.GetActiveEmsComponent();
    case 'Atm'
        component = componentManager.GetActiveAtmComponent(slot);
    case 'Last'
        component = componentManager.GetActiveLastComponent();
    case 'Eq'
        component = componentManager.GetActiveEqComponent(slot);
    case 'Gsq'
        component = componentManager.GetActiveGsqComponent();
end
if(not(isempty(component)))
    component = component.DeleteVariable(item_selected);
    componentManager = componentManager.AddComponent(component);
    componentManager = componentManager.SetActiveComponent(type, slot, component.Name);
    assignin('base', 'componentManager', componentManager);
else
    msgbox('Empty Component', 'Error', 'error')
end
% Update auto_listbox
if(index_selected > 1)
    set(listbox, 'Value', index_selected - 1);
else
    set(listbox, 'Value', 1);
end

function delete_auto_variable(handles)
delete_variable('Auto', 0, handles.auto_listbox)

function delete_strecke_variable(handles)
delete_variable('Strecke', 0, handles.strecke_listbox)

function delete_ems_variable(handles)
delete_variable('Ems', 0, handles.ems_listbox)

function delete_hardware_variable(handles)
[type, slot] = get_hardware_type_and_slot(handles);
delete_variable(type, slot, handles.hardware_listbox)

% Edit Variable Setup -----------------------------------------------------

function set_variable_setup(type, slot)

% Get all required variables
componentManager = evalin('base', 'componentManager');

% Get the variant and if needed subType name
switch type
    case 'Auto'
        component = componentManager.GetActiveAutoComponent();
    case 'Strecke'
        component = componentManager.GetActiveStreckeComponent();
    case 'Ems'
        component = componentManager.GetActiveEmsComponent();
    case 'Atm'
        component = componentManager.GetActiveAtmComponent(slot);
    case 'Last'
        component = componentManager.GetActiveLastComponent();
    case 'Eq'
        component = componentManager.GetActiveEqComponent(slot);
    case 'Gsq'
        component = componentManager.GetActiveGsqComponent();
end

% Edit the variable setup function in a GUI. First input is a workaround
setupFunction = edit_variable_setup('a', component.SetupFunction);
% -1 means that there is no change to the variable setup function
if(setupFunction == -1)
    return;
end

% Save the edited value
component.SetupFunction = setupFunction;
componentManager.AddComponent(component);
componentManager = componentManager.SetComponentAsActive(component);

assignin('base', 'componentManager', componentManager);

function set_auto_variable_setup()
set_variable_setup('Auto', 0);

function set_strecke_variable_setup()
set_variable_setup('Strecke', 0);

function set_ems_variable_setup()
set_variable_setup('Ems', 0);

function set_hardware_variable_setup(handles)
[type, slot] = get_hardware_type_and_slot(handles);
set_variable_setup(type, slot);

% Get Based on Text -------------------------------------------------------

function text = get_based_on_text(type, slot)
global componentManager;
switch type
    case 'Auto'
        component = componentManager.GetActiveAutoComponent();
    case 'Strecke'
        component = componentManager.GetActiveStreckeComponent();
    case 'Ems'
        component = componentManager.GetActiveEmsComponent();
    case 'Atm'
        component = componentManager.GetActiveAtmComponent(slot);
    case 'Last'
        component = componentManager.GetActiveLastComponent();
    case 'Eq'
        component = componentManager.GetActiveEqComponent(slot);
    case 'Gsq'
        component = componentManager.GetActiveGsqComponent();
    otherwise
        component = [];
end
if(not(isempty(component)))
    text = component.GetBasedOnText();
else
    component = Component('Null', 'Null', 'Null', 'Null');
    text = component.GetBasedOnText();
end

% Open Component / Variant Documentation ----------------------------------

function open_component_documentation(type, slot)
global variantManager;
componentManager = evalin('base', 'componentManager');
[variant, subType] = variantManager.GetActiveVariant(type, slot);
component = componentManager.GetActiveComponent(type, subType, variant);
componentName = component.Name;
component_documentation(type, subType, variant, componentName)

%--------------------------------------------------------------------------
% TODO Methoden
%--------------------------------------------------------------------------

% Filter text boxes -------------------------------------------------------
function auto_filter_edit_Callback(hObject, eventdata, handles)


function auto_filter_edit_CreateFcn(hObject, eventdata, handles)


function strecke_filter_edit_Callback(hObject, eventdata, handles)


function strecke_filter_edit_CreateFcn(hObject, eventdata, handles)


function ems_filter_edit_Callback(hObject, eventdata, handles)


function ems_filter_edit_CreateFcn(hObject, eventdata, handles)


function hardware_filter_edit_Callback(hObject, eventdata, handles)


function hardware_filter_edit_CreateFcn(hObject, eventdata, handles)


function experiment_filter_edit_CreateFcn(hObject, eventdata, handles)


function experiment_filter_edit_Callback(hObject, eventdata, handles)

% Miscellaneous Callbacks -------------------------------------------------
