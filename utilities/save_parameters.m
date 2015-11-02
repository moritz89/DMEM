function save_parameters(variables, fileName)
% Save parameters
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 24.12.2015
%   @updated 9.7.2015

[projectRoot, ] = project_paths();
variableList = ' ';

% Concatenate a string of variables matching a preconfigured list of
% variables
for i=1:numel(variables)-1
    if(evalin('base', strcat('exist(''', variables{:,i}, ''')')))
        variableList = strcat(variableList, '''', variables{:,i}, ''',');
    else
        fprintf('\t Not found <%s>\n', variables{:,i});
    end
end
variableList = strcat(variableList, '''', variables{:,numel(variables)}, '''');

variablePath = fullfile(projectRoot, fileName);
saveExpression = strcat('save(''', variablePath, ''',', variableList, ')');
evalin('base', saveExpression);