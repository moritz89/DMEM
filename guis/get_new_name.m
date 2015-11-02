function varargout = get_new_name(varargin)
% GET_NEW_NAME MATLAB code for get_new_name.fig
%      GET_NEW_NAME by itself, creates a new GET_NEW_NAME or raises the
%      existing singleton*.
%
%      H = GET_NEW_NAME returns the handle to a new GET_NEW_NAME or the handle to
%      the existing singleton*.
%
%      GET_NEW_NAME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GET_NEW_NAME.M with the given input arguments.
%
%      GET_NEW_NAME('Property','Value',...) creates a new GET_NEW_NAME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before get_new_name_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to get_new_name_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 5.4.2015
%   @updated 9.7.2015

% Edit the above text to modify the response to help get_new_name

% Last Modified by GUIDE v2.5 07-Jul-2015 15:51:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @get_new_name_OpeningFcn, ...
                   'gui_OutputFcn',  @get_new_name_OutputFcn, ...
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

function get_new_name_OpeningFcn(hObject, eventdata, handles, varargin)
% Check the inputs
if(length(varargin) < 1)
    msgbox('Please select either ''Component'' or ''ModelVariable''', 'Missing Input', 'Warn');
    return;
end

% Setup the widgets
guidata(hObject, handles);
setup_parent_widgets(varargin, handles);
enable_parent_widgets(0, handles);
set(handles.parent_filter_edit, 'Enable', 'off');

% UIWAIT makes get_new_name wait for user response (see UIRESUME)
uiwait(handles.figure1);

function varargout = get_new_name_OutputFcn(hObject, eventdata, handles)
try
    varargout{1} = handles.name;
    varargout{2} = handles.parent_name;
catch ME
    varargout{1} = '';
    varargout{2} = '';
end

% The figure can be deleted now
if(not(isempty(handles)))
    delete(handles.figure1);
end

% Main Widgets ------------------------------------------------------------

function name_edit_Callback(hObject, eventdata, handles)
handles.output = get(hObject, 'String');
% Update handles structure
guidata(hObject, handles);

function name_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function accept_pushbutton_Callback(hObject, eventdata, handles)
% Save the new variable name
handles.name = get(handles.name_edit,'String');
% If copy parent is enabled, get the parent name. Else leave blank
if(get(handles.parent_checkbox, 'Value'))
    items = get(handles.parent_popupmenu, 'String');
    index_selected = get(handles.parent_popupmenu, 'Value');
    handles.parent_name = items{index_selected};
else
    handles.parent_name = '';
end

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

function cancel_pushbutton_Callback(hObject, eventdata, handles)

handles.name = '';
handles.parent_name = '';

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

function parent_checkbox_Callback(hObject, eventdata, handles)
enabled = get(hObject, 'Value');
if(enabled)
    enable_parent_widgets(1, handles)
else
    enable_parent_widgets(0, handles)
end

% Parent Widgets ----------------------------------------------------------

function parent_popupmenu_Callback(hObject, eventdata, handles)

function parent_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
list = {'Leer'};
set(hObject, 'String', list);

function parent_filter_edit_Callback(hObject, eventdata, handles)

function parent_filter_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Helper Functions --------------------------------------------------------

function setup_parent_widgets(input, handles)
if(strcmp(input{1}, 'Component'))
	set(handles.figure1, 'Name', 'Create New Preset');
    setup_parent_widgets_component(input, handles);
elseif(strcmp(input{1}, 'ModelVariable'))
    set(handles.figure1, 'Name', 'Create New Model Variable');
    setup_parent_widgets_model_variable(input, handles);
else
	msgbox('Please select either ''Component'' or ''ModelVariable''', 'Missing Input', 'Warn');
    return;
end

function setup_parent_widgets_component(input, handles)
% Setup the parent widgets for use with components. Get the components
% belonging to the active variant of the selected type in input{2}

global variantManager;
componentManager = evalin('base', 'componentManager');
if(length(input) >= 2)
    type = input{2};
else
    type = '';
end
if(length(input) >= 3)
    slot = input{3};
else
    slot = 0;
end

% Get the variant and subType if necessary
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
    otherwise
        % Wrong input. Abort setup. Inform the user
        msgbox(['Please select either Auto, Strecke, Ems, Atm, Last, Eq, Gsq' ...
            'as the second input'], 'Wrong Input', 'Warn');
        return;
end

components = componentManager.GetComponentNames(type, subType, variant);
if(isempty(components))
    set(handles.parent_popupmenu, 'Enable', 'off')
    set(handles.parent_checkbox, 'Enable', 'off')
else
	set(handles.parent_popupmenu, 'Enable', 'on')
    set(handles.parent_checkbox, 'Enable', 'on')
    set(handles.parent_popupmenu, 'String', sort(components));
end

function setup_parent_widgets_model_variable(input, handles)
% Setup the parent widgets for use with model variables. Get the model
% variables belonging to the active component of the selected type in input{2}

componentManager = evalin('base', 'componentManager');
if(length(input) >= 2)
    type = input{2};
else
    type = '';
end
if(length(input) >= 3)
    slot = input{3};
else
    slot = 0;
end

switch type
    case 'Auto'
        variables = componentManager.GetActiveAutoComponentVariableNames();
    case 'Strecke'
        variables = componentManager.GetActiveStreckeComponentVariableNames();
    case 'Ems'
        variables = componentManager.GetActiveEmsComponentVariableNames();
    case 'Atm'
        variables = componentManager.GetActiveAtmComponentVariableNames(slot);
    case 'Last'
        variables = componentManager.GetActiveLastComponentVariableNames();
    case 'Eq'
        variables = componentManager.GetActiveEqComponentVariableNames(slot);
    case 'Gsq'
        variables = componentManager.GetActiveGsqComponentVariableNames();
    otherwise
        % Wrong input. Abort setup. Inform the user
        msgbox(['Please select either Auto, Strecke, Ems, Atm, Last, Eq, Gsq' ...
            ' as the second input'], 'Wrong Input', 'Warn');
        return;
end

if(isempty(variables))
    set(handles.parent_popupmenu, 'Enable', 'off')
    set(handles.parent_checkbox, 'Enable', 'off')
else
	set(handles.parent_popupmenu, 'Enable', 'on')
    set(handles.parent_checkbox, 'Enable', 'on')
    set(handles.parent_popupmenu, 'String', sort(variables));
end

function enable_parent_widgets(enabled, handles)
% If enabled == 1, enable all widgets related to the parent copy
% functionality. Else disable them.
if(enabled)
    state = 'on';
else
    state = 'off';
end
set(handles.parent_popupmenu, 'Enable', state);
%set(handles.parent_filter_edit, 'Enable', state);
