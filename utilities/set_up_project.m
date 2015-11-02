%%  set_up_project  Configure the environment for this project
%   Set up the environment for the current project. This function is set to
%   Run at Startup.
%
% @author Andi Dittrich<dit@bimaq.de>, Moritz Ulmer<moritz.ulmer@posteo.de>
% @created 09.08.2012
% @updated 20.03.2015

% print init message on console
fprintf('\n===========================================================\n');
fprintf('Initializing Workspace Environment\n');
fprintf('> Target Version MATLAB.2015a\n\n');

%% Workarounds
% Fix for Unix when using the system() command, i.e., openning PDF files
if(isunix)
    setenv('LD_LIBRARY_PATH', '');
end

%% Setup files and folders
[projectRoot, includePathes] = project_paths();

% Set the location of slprj to be the "work" folder of the current project:
cacheFolder = fullfile(projectRoot, 'work');
if ~exist(cacheFolder, 'dir')
    mkdir(cacheFolder)
end
Simulink.fileGenControl('set', 'CacheFolder', cacheFolder, ...
'CodeGenFolder', cacheFolder);

% add local include pathes
fprintf('Setting include pathes...\n');
for i=1:numel(includePathes)
    addpath(genpath(fullfile(projectRoot, includePathes{:,i})));
end

%% Load workspace variables
DriveSimMode = 1;           % V1
HardwareIoMode = 1;         % Sample
EmsMode = 1;                % M2Eq5
VirtuellHardwareMode = 1;   % M2Eq5
AtmLastVirtuell1Mode = 1;   % AtmLastSimple

% Load buses
fprintf('Loading buses...\n');
[variables, fileName] = bus_variables;
load_parameters(variables, fileName);

% Load model configurations
fprintf('Loading model configurations...\n');
[variables, fileName] = model_configuration_variables;
load_parameters(variables, fileName);

% Load variants
fprintf('Loading variant controls...\n');
global variantManager;
variantManager = VariantManager;
variantManager.Initialize();

% Setup Component Manager
fprintf('Loading components and presets...\n');
global componentManager;
componentManager = ComponentManager();

% Setup ExperimentRun Manager
fprintf('Loading experiments and runs...\n');
global experimentRunManager;
experimentRunManager = ExperimentRunManager();

%% Cleanup script variables
clear ans fileName i includePathes variables cacheFolder projectRoot
