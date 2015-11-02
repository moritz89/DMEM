function varargout = select_results(varargin)
% SELECT_RESULTS MATLAB code for select_results.fig
%      SELECT_RESULTS, by itself, creates a new SELECT_RESULTS or raises the existing
%      singleton*.
%
%      H = SELECT_RESULTS returns the handle to a new SELECT_RESULTS or the handle to
%      the existing singleton*.
%
%      SELECT_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_RESULTS.M with the given input arguments.
%
%      SELECT_RESULTS('Property','Value',...) creates a new SELECT_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 4.2.2015
%   @updated 9.7.2015

% Edit the above text to modify the response to help select_results

% Last Modified by GUIDE v2.5 12-Aug-2015 10:49:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_results_OpeningFcn, ...
                   'gui_OutputFcn',  @select_results_OutputFcn, ...
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

% --- Executes just before component_documentation is made visible.
function select_results_OpeningFcn(hObject, eventdata, handles, varargin)

global experimentRunManager;
run_scripts_pushbutton_Callback(handles.run_scripts_pushbutton, eventdata, handles);
lh = addlistener(experimentRunManager, 'ActiveExperimentRunChanged', @update_experiment_run);

% Choose default command line output for select_results
handles.ExperimentRunChangedlistener = lh;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = select_results_OutputFcn(hObject, eventdata, handles)

function select_results_CloseRequestFcn(hObject, eventdata, handles)
% Disable experiment mode and remove experimentRun injections from
% componentManager if not required

% Only disable if select_variables GUI is closed
global experimentRunManager;
if(isempty(findobj('type', 'figure', 'tag', 'select_variables')))
    experimentRunManager.DeactivateExperimentRunMode();
end
% Remove notifyExperimentRunChanged listener from experimentRunManager
delete(handles.ExperimentRunChangedlistener)

% Hint: delete(hObject) closes the figure
delete(hObject);

%--------------------------------------------------------------------------
% ExperimentRun Selection
%--------------------------------------------------------------------------

function experiment_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
if(not(experimentRunManager.IsExperimentRunMode))
    experimentRunManager.ActivateExperimentRunMode();
end
[list, index] = experimentRunManager.GetExperimentNames();
set(hObject, 'String', list);
set(hObject, 'Value', index)

function experiment_popupmenu_Callback(hObject, eventdata, handles)
global experimentRunManager;
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
experimentName = items{index_selected};
experimentRunManager = experimentRunManager.SetActiveExperimentName(experimentName);

function run_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
if(not(experimentRunManager.IsExperimentRunMode))
    experimentRunManager.ActivateExperimentRunMode();
end
[list, index] = experimentRunManager.GetActiveRunIds();
set(hObject, 'String', list);
set(hObject, 'Value', index);

function run_popupmenu_Callback(hObject, eventdata, handles)
global experimentRunManager;
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
runId = items{index_selected};
experimentRunManager = experimentRunManager.SetActiveRunId(runId);

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

% Data Inspector ----------------------------------------------------------

function open_sdi_pushbutton_Callback(hObject, eventdata, handles)
evalin('base', 'Simulink.sdi.view');

function sdi_load_run_pushbutton_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRunManager = experimentRunManager.LoadRunFromActive();

function sdi_remove_run_pushbutton_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRunManager = experimentRunManager.RemoveRunFromActive();

% Utility Functions -------------------------------------------------------

function update_content_widgets(handles, eventdata)
author_edit_CreateFcn(handles.author_edit, eventdata, handles)
supervisor_edit_CreateFcn(handles.supervisor_edit, eventdata, handles)
date_created_edit_CreateFcn(handles.date_created_edit, eventdata, handles)
dspace_model_edit_CreateFcn(handles.dspace_model_edit, eventdata, handles)
documentation_edit_CreateFcn(handles.documentation_edit, eventdata, handles)
preview_script_edit_CreateFcn(handles.preview_script_edit, eventdata, handles)
evaluation_script_edit_CreateFcn(handles.evaluation_script_edit, eventdata, handles)
sdi_preparation_script_edit_CreateFcn(handles.sdi_preparation_script_edit, eventdata, handles)
run_scripts_pushbutton_Callback(handles.run_scripts_pushbutton, eventdata, handles)

function update_experiment_run(src, event)
% Update the GUI through an external caller. This is useful when there has 
% been an update to the data that the GUI represents. The function is
% registered to a listener which is notified when the experimentrun changes

% Find the handle for the select_variables GUI
select_results = findobj('type', 'figure', 'tag', 'select_results');

% This createFunction causes an update of all experimentRun data widgets
if(not(isempty(select_results)))
    % The 'handles' variable used in all Create and Callback functions
    handles = guidata(select_results);
    experiment_popupmenu_CreateFcn(handles.experiment_popupmenu, 0, handles)
    run_popupmenu_CreateFcn(handles.run_popupmenu, 0, handles)
    update_content_widgets(handles, 0)
end

%--------------------------------------------------------------------------
% ExperimentRun Content
%--------------------------------------------------------------------------

function author_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', experimentRun.Author)

function author_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.Author = get(hObject, 'String');
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);

function supervisor_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', experimentRun.Supervisor)

function supervisor_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.Supervisor = get(hObject, 'String');
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);

function date_created_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', datestr(experimentRun.DateCreated, 'dd.mm.yy'))

function date_created_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
try
    experimentRun.DateCreated = datenum(get(hObject, 'String'), 'dd.mm.yy');
catch
    experimentRun = experimentRunManager.GetActiveExperimentRun();
end
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);
set(hObject, 'String', datestr(experimentRun.DateCreated, 'dd.mm.yy'))

function set_date_today_pushbutton_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.DateCreated = now();
experimentRunManager.AddExperimentRun(experimentRun);
date_created_edit_CreateFcn(handles.date_created_edit, eventdata, handles)

function dspace_model_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', experimentRun.DspaceModel)

function dspace_model_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.DspaceModel = get(hObject, 'String');
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);

function documentation_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', experimentRun.ExperimentDocumentation)

function documentation_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.ExperimentDocumentation = get(hObject, 'String');
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);

%--------------------------------------------------------------------------
% Scripts
%--------------------------------------------------------------------------

function preview_script_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', experimentRun.PreviewScript)

function preview_script_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.PreviewScript = get(hObject, 'String');
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);

function evaluation_script_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', experimentRun.EvaluationScript)

function evaluation_script_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.EvaluationScript = get(hObject, 'String');
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);

function sdi_preparation_script_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
set(hObject, 'String', experimentRun.SdiPreparationScript)

function sdi_preparation_script_edit_Callback(hObject, eventdata, handles)
global experimentRunManager;
experimentRun = experimentRunManager.GetActiveExperimentRun();
experimentRun.SdiPreparationScript = get(hObject, 'String');
experimentRunManager = experimentRunManager.AddExperimentRun(experimentRun);

function run_scripts_pushbutton_Callback(hObject, eventdata, handles)
global experimentRunManager;
% Get scripts and clear preview axes
experimentRun = experimentRunManager.GetActiveExperimentRun();
previewScript = experimentRun.PreviewScript;
evaluationScript = experimentRun.EvaluationScript;
cla(handles.preview_axes)
% Run preview script
if(not(isempty(previewScript)))
    try
        handles = eval(previewScript);
    catch
        experimentName = experimentRun.ExperimentName;
        runId = experimentRun.RunId;
        warning(['Could not run Preview Script for Experiment ' experimentName ...
            ' Run ' num2str(runId)]);
    end
end
% Run evaluation script
if(not(isempty(evaluationScript)))
    try
        handles = eval(evaluationScript);
    catch
        experimentName = experimentRun.ExperimentName;
        runId = experimentRun.RunId;
        warning(['Could not run Preview Script for Experiment ' experimentName ...
            ' Run' num2str(runId)]);
    end
end
% Save the changes
guidata(hObject, handles);

%--------------------------------------------------------------------------
% TODO Methoden
%--------------------------------------------------------------------------

function experiment_filter_edit_Callback(hObject, eventdata, handles)

function experiment_filter_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
