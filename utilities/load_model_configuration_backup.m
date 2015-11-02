function load_model_configuration_backup()
%LOAD_MODEL_CONFIGURATION_BACKUP Loads the backed up model configuration backup file
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>

[variables, ~] = model_configuration_variables();
fileName = fullfile('backup', 'model_configurations_bak');
load_parameters(variables, fileName);

end

