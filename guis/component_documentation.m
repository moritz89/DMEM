function varargout = component_documentation(varargin)
% COMPONENT_DOCUMENTATION MATLAB code for component_documentation.fig
%      COMPONENT_DOCUMENTATION, by itself, creates a new COMPONENT_DOCUMENTATION or raises the existing
%      singleton*.
%
%      H = COMPONENT_DOCUMENTATION returns the handle to a new COMPONENT_DOCUMENTATION or the handle to
%      the existing singleton*.
%
%      COMPONENT_DOCUMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPONENT_DOCUMENTATION.M with the given input arguments.
%
%      COMPONENT_DOCUMENTATION('Property','Value',...) creates a new COMPONENT_DOCUMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before component_documentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to component_documentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help component_documentation

% Last Modified by GUIDE v2.5 25-Jul-2015 16:22:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @component_documentation_OpeningFcn, ...
                   'gui_OutputFcn',  @component_documentation_OutputFcn, ...
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
function component_documentation_OpeningFcn(hObject, eventdata, handles, varargin)
% Check the inputs
if(length(varargin) ~= 4)
    msgbox(['Please specify the component with its type(1), subType(2), variant(3) '...
    'and name(4)'],  'Input Arguments', 'Warn');
    return;
end

handles.component_type = varargin{1};
handles.component_subType = varargin{2};
handles.component_variant = varargin{3};
handles.component_name = varargin{4};

guidata(hObject, handles);

% Setup the widgets
setup_widgets(varargin, handles)

% UIWAIT makes get_new_name wait for user response (see UIRESUME)
%uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = component_documentation_OutputFcn(hObject, eventdata, handles)

% Main Widgets ------------------------------------------------------------

function component_documentation_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function component_documentation_edit_Callback(hObject, eventdata, handles)

function variant_documentation_pushbutton_Callback(hObject, eventdata, handles)
doc_path = get(handles.variant_doc_file_text, 'String');
% If the file does not exist, inform the user and 
if(not(exist(doc_path, 'file')))
    msgbox(['The file can not be found. Please rename it to the following style:' ...
        '(Type)(SubType)(Variant)Doc.pdf'], 'File not found', 'warn');
    return;
end

if(ispc)
    winopen(doc_path)
elseif(isunix)
    % open() doesn't work on Linux. Open the Evince or libreoffice directly
	system(['xdg-open ' doc_path ' &']);
else
    msgbox(['Unknown operating system. The PDF file name is: '...
        doc_path], 'Unknown OS')
end

function cancel_pushbutton_Callback(hObject, eventdata, handles)
% Close the GUI
uiresume(handles.figure1)
if(not(isempty(handles)))
    delete(handles.figure1);
end

function accept_pushbutton_Callback(hObject, eventdata, handles)
% Save the component documentation text
if(not(isempty(get(handles.variant_doc_file_text, 'String'))))
    componentManager = evalin('base', 'componentManager');
    component = componentManager.GetComponent(handles.component_type, ...
        handles.component_subType, handles.component_variant, handles.component_name);
    documentation = get(handles.component_documentation_edit, 'String');
    component = component.SetDocumentation(documentation);
    componentManager = componentManager.AddComponent(component);
    assignin('base', 'componentManager', componentManager)
end
% Close the GUI
uiresume(handles.figure1)
if(not(isempty(handles)))
    delete(handles.figure1);
end

% Helper Functions --------------------------------------------------------

function setup_widgets(varargin, handles)
% Get and set the component documentation
componentManager = evalin('base', 'componentManager');
component = componentManager.GetComponent(handles.component_type, ...
    handles.component_subType, handles.component_variant, handles.component_name);
set(handles.component_documentation_edit, 'String', component.GetDocumentation());
% Get the variant documentation file path
global variantManager;
doc_path = variantManager.GetDocumentationFilePath(handles.component_type, ...
    handles.component_subType, handles.component_variant);
set(handles.variant_doc_file_text, 'String', doc_path);
