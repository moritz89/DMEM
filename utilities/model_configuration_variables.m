function [configurations, configurationFileName] = model_configuration_variables()
% The model configurations are saved as [file name, variable name] tuples
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 24.12.2015
%   @updated 9.7.2015

configurations = { ...
    'RTI_1103_CONFIGURATION', ...
    'SIMULATION_CONFIGURATION' ...
    ... % Configuration variables
    'Simulationsdauer', ...
    'StepSize' ...
    };

% The local path in which the model configurations are saved
configurationFileName = fullfile('data', 'model_configurations');

end