function load_parameters(variables, fileName)
% Load parameters
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 24.12.2015
%   @updated 9.7.2015

[projectRoot, ] = project_paths();
variableList = ' ';

% Concatenate a string of variables matching a preconfigured list of
% variables
for i=1:numel(variables)-1
    variableList = strcat(variableList, '''', variables{:,i}, ''',');    
end
variableList = strcat(variableList, '''', variables{:,numel(variables)}, '''');

variablePath = fullfile(projectRoot, fileName);
loadExpression = strcat('load(''', variablePath, ''',', variableList, ')');
evalin('base', loadExpression);

% Check if all variables have been loaded
for i=1:numel(variables)-1
    if(not(evalin('base', strcat('exist(''', variables{:,i}, ''')'))))
        fprintf('\t Not found <%s>\n', variables{:,i});
    end
end