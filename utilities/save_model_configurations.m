function save_model_configurations(varargin)
%SAVE_MODEL_CONFIGURATIONS Save the model configuration variables defined 
%  in model_configuration_variables() from the workspace. The fileName
%  variable is the relative path to the file to save the model
%  configurations in. If empty, the default location is used
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 18.12.2015
%   @updated 9.7.2015

fprintf('Saving model configurations...\n');

[modelConfigurations, modelConfigurationFileName] = model_configuration_variables();
if(nargin ~= 0)
    modelConfigurationFileName = varargin{:};
end
save_parameters(modelConfigurations, modelConfigurationFileName);

end

