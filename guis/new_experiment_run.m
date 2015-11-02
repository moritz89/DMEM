function varargout = new_experiment_run(varargin)
% NEW_EXPERIMENT_RUN MATLAB code for new_experiment_run.fig
%      NEW_EXPERIMENT_RUN, by itself, creates a new NEW_EXPERIMENT_RUN or raises the existing
%      singleton*.
%
%      H = NEW_EXPERIMENT_RUN returns the handle to a new NEW_EXPERIMENT_RUN or the handle to
%      the existing singleton*.
%
%      NEW_EXPERIMENT_RUN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEW_EXPERIMENT_RUN.M with the given input arguments.
%
%      NEW_EXPERIMENT_RUN('Property','Value',...) creates a new NEW_EXPERIMENT_RUN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before new_experiment_run_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to new_experiment_run_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 5.6.2015
%   @updated 9.7.2015

% Edit the above text to modify the response to help new_experiment_run

% Last Modified by GUIDE v2.5 18-Aug-2015 10:53:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @new_experiment_run_OpeningFcn, ...
                   'gui_OutputFcn',  @new_experiment_run_OutputFcn, ...
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

function new_experiment_run_OpeningFcn(hObject, eventdata, handles, varargin)
if(length(varargin) >= 1)
    set(handles.experiment_name_edit, 'String', varargin{1});
end
if(length(varargin) >= 2)
    set(handles.run_id_edit, 'String', num2str(varargin{2}));
end
handles.experiment_name = '';
handles.run_id = 0;
handles.parent_experiment_name = '';
handles.parent_run_id = 0;

set(hObject, 'Name', 'Create New Experiment Run');
guidata(hObject, handles);
set(handles.experiment_filter_edit, 'Enable', 'off');
enable_parent_widgets(0, handles);

uiwait(handles.new_experiment_run);

function varargout = new_experiment_run_OutputFcn(hObject, eventdata, handles) 
try
    varargout{1} = handles.experiment_name;
    varargout{2} = handles.run_id;
    varargout{3} = handles.parent_experiment_name;
    varargout{4} = handles.parent_run_id;
catch ME
    varargout{1} = '';
    varargout{2} = 0;
    varargout{3} = '';
    varargout{4} = 0;
end

% The figure can be deleted now
if(not(isempty(handles)))
    delete(handles.new_experiment_run);
end

% Upper Widgets -----------------------------------------------------------

function experiment_name_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function experiment_name_edit_Callback(hObject, eventdata, handles)
handles.experiment_name = get(hObject, 'String');
guidata(hObject, handles);

function run_id_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function run_id_edit_Callback(hObject, eventdata, handles)
run_id_num = str2double(get(hObject, 'String'));
handles.run_id = run_id_num;
if(isnan(run_id_num) || run_id_num < 1)
    str2double(set(hObject, 'String', '1'));
    warndlg('The run ID entered is not valid. Please enter a positive integer', 'Invalid Run ID')
    return;
end

guidata(hObject, handles);

function accept_pushbutton_Callback(hObject, eventdata, handles)
global experimentRunManager;

experiment_name = get(handles.experiment_name_edit, 'String');
handles.experiment_name = experiment_name;
run_id_num = str2double(get(handles.run_id_edit, 'String'));
handles.run_id = run_id_num;

if(experimentRunManager.IsExperimentRun(experiment_name, run_id_num))
    choise = questdlg('The experiment run already exists. Are you sure you want to overwrite it?', ...
                      'Confirm Save', 'Yes', 'No', 'No');
    if(strcmp(choise, 'No'))
        return;
    end
end

if(get(handles.parent_checkbox, 'Value'))
    items = get(handles.experiment_name_popupmenu, 'String');
    index_selected = get(handles.experiment_name_popupmenu, 'Value');
    handles.parent_experiment_name = items{index_selected};
    items = get(handles.run_id_popupmenu, 'String');
    index_selected = get(handles.run_id_popupmenu, 'Value');
    handles.parent_run_id = items{index_selected};
else
    handles.parent_experiment_name = '';
    handles.parent_run_id = 0;
end

guidata(hObject, handles);
uiresume(handles.new_experiment_run);

function cancel_pushbutton_Callback(hObject, eventdata, handles)
handles.experiment_name = '';
handles.run_id = 0;
handles.parent_experiment_name = '';
handles.parent_run_id = 0;
guidata(hObject, handles);
uiresume(handles.new_experiment_run);

function parent_checkbox_Callback(hObject, eventdata, handles)
enabled = get(hObject, 'Value');
if(enabled)
    enable_parent_widgets(1, handles)
else
    enable_parent_widgets(0, handles)
end

% Parent Selection Widgets ------------------------------------------------

function experiment_name_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
[list, index] = experimentRunManager.GetExperimentNames();
set(hObject, 'String', list);
set(hObject, 'Value', index);

function experiment_name_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
handles.parent_experiment_name = items{index_selected};
guidata(hObject, handles);
run_id_popupmenu_CreateFcn(handles.run_id_popupmenu, eventdata, handles)

function run_id_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global experimentRunManager;
if(isempty(handles))
    % When initializing get the run ids of the active experiment name
    [list, index] = experimentRunManager.GetActiveRunIds();
else
    % Get the run ids of the selected experiment name in the experiment
    % name popupmenu for the parent ExperimentName selection
    items = get(handles.experiment_name_popupmenu, 'String');
    index_selected = get(handles.experiment_name_popupmenu, 'Value');
    [list, index] = experimentRunManager.GetRunIds(items{index_selected});
end
set(hObject, 'String', list);
set(hObject, 'Value', index);

function run_id_popupmenu_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
handles.parent_run_id = ExperimentRun.ParseRunId(items{index_selected});
guidata(hObject, handles);

function experiment_filter_edit_CreateFcn(hObject, eventdata, handles)

function experiment_filter_edit_Callback(hObject, eventdata, handles)

function enable_parent_widgets(enabled, handles)
% If enabled == 1, enable all widgets related to the parent ExperimentRun
% functionality. Else disable them.
if(enabled)
    state = 'on';
else
    state = 'off';
end
set(handles.experiment_name_popupmenu, 'Enable', state);
set(handles.run_id_popupmenu, 'Enable', state);
%set(handles.experiment_filter_edit, 'Enable', state);
