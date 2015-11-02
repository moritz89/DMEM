function varargout = edit_variable_setup(varargin)
% EDIT_VARIABLE_SETUP MATLAB code for edit_variable_setup.fig
%      EDIT_VARIABLE_SETUP, by itself, creates a new EDIT_VARIABLE_SETUP or raises the existing
%      singleton*.
%
%      H = EDIT_VARIABLE_SETUP returns the handle to a new EDIT_VARIABLE_SETUP or the handle to
%      the existing singleton*.
%
%      EDIT_VARIABLE_SETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDIT_VARIABLE_SETUP.M with the given input arguments.
%
%      EDIT_VARIABLE_SETUP('Property','Value',...) creates a new EDIT_VARIABLE_SETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before edit_set_function_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to edit_set_function_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 9.7.2015
%   @updated 9.7.2015

% Edit the above text to modify the response to help edit_variable_setup

% Last Modified by GUIDE v2.5 08-Jul-2015 14:11:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @edit_variable_setup_OpeningFcn, ...
                   'gui_OutputFcn',  @edit_variable_setup_OutputFcn, ...
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

% --- Executes just before edit_variable_setup is made visible.
function edit_variable_setup_OpeningFcn(hObject, eventdata, handles, varargin)

% Inputs: 2: type

% Check that the correct number of inputs where delivered
if(length(varargin) < 2)
    warning('Wrong input number. Expected two inputs (2: variable_setup function)');
    return;
end

input2 = varargin(2);
setupFunction = input2{:};

set(handles.variable_setup_edit, 'String', setupFunction);
set(handles.original_input_text, 'String', setupFunction);

% Set the GUI as a modal window and prevent it from auto-closing
%set(handles.edit_variable_setup, 'WindowStyle', 'modal')
uiwait(handles.edit_variable_setup);

% --- Outputs from this function are returned to the command line.
function varargout = edit_variable_setup_OutputFcn(hObject, eventdata, handles) 

if(isfield(handles, 'output'))
    varargout{1} = handles.output;
else
    % -1 means that there is no change to the variable setup function
    varargout{1} = -1;
end

if(not(isempty(handles)))
    delete(handles.edit_variable_setup);
end

function edit_variable_setup_CloseRequestFcn(hObject, eventdata, handles)
% Delete the GUI

delete(hObject);

% -------------------------------------------------------------------------

function variable_setup_edit_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', '');

function variable_setup_edit_Callback(hObject, eventdata, handles)
handles.output = get(handles.variable_setup_edit, 'String');
guidata(hObject, handles);

function accept_pushbutton_Callback(hObject, eventdata, handles)
handles.output = get(handles.variable_setup_edit,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.edit_variable_setup);

function cancel_pushbutton_Callback(hObject, eventdata, handles)
handles.output = get(handles.original_input_text, 'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.edit_variable_setup);


function edit_set_function_CloseRequestFcn(hObject, eventdata, handles)

% Hint: delete(hObject) closes the figure
delete(hObject);
