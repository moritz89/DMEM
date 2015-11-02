function clean_up_project
% clean_up_project  Reset the environment to its original state
%   Set up the environment for the current project. This function is set to
%   Run at Startup.
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 09.08.2012

% print init message on console
fprintf('\n========================================================================================\n');
fprintf('Cleanup Workspace Environment\n');
fprintf('> Target Version MATLAB.2015a\n');

%% Close the GUI's if open
select_variables = findobj('type', 'figure', 'tag', 'select_variables');
select_results = findobj('type', 'figure', 'tag', 'select_results');
if(not(isempty(select_variables)))
    close(select_variables);
end
if(not(isempty(select_results)))
    close(select_results);
end

%% Create Backups
% Get project root path and relative include paths
[projectRoot, includePathes] = project_paths();

% Save components and variables in the componentManager
componentsFileName = fullfile('backup', 'components_bak');
save_components('single', componentsFileName);

% Save a backup of the experiment run manager
experimentRunFileName = fullfile('backup', 'experiment_runs_bak');
save_experiment_runs('single', experimentRunFileName);

% Save a backup of the bus variables
busFileName = fullfile('backup', 'buses_bak');
save_buses(busFileName);

% Save a backup of the model configurations
modelConfigurationFileName = fullfile('backup', 'model_configurations_bak');
save_model_configurations(modelConfigurationFileName);

%% Cleanup files and folders
% Remove local include pathes
fprintf('\nReseting include pathes...\n');
for i=1:numel(includePathes)
    rmpath(genpath(fullfile(projectRoot, includePathes{:,i})));
end

% Reset the location where generated code and other temporary files are
% created (slprj) to the default:
Simulink.fileGenControl('reset');

% Clear the work directory of known temporary files
fprintf('Cleaning work directory...\n');
[cleanUpFiles, cleanUpFolders]= clean_up_paths();
for i=1:numel(cleanUpFiles)
    for j=1:numel(includePathes)
       delete( fullfile(projectRoot, includePathes{:,j}, cleanUpFiles{:,i})); 
    end
    fprintf('\t Removing work files  <%s>\n', cleanUpFiles{:,i});
end
for i=1:numel(cleanUpFolders)
    if(rmdir( fullfile(projectRoot, cleanUpFolders{:,i}), 's' ))
        fprintf('\t Removing work folder <%s>\n', cleanUpFolders{:,i});
    end
end

% If the work folder is empty, delete it
if(rmdir( fullfile(projectRoot, 'work')))
    fprintf('\t Removing work directory\n');
else
    fprintf('\t Could not remove work directory\n');
end
end
