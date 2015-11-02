function save_experiment_runs(varargin)
%SAVE_EXPERIMENT_RUN Calls the save to file function of componentManager
%   varargin = {saveType, filePath}
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 14.4.2015
%   @updated 12.8.2015

fprintf('Saving experiment runs...\n');

global experimentRunManager;
switch nargin
    case 0
        experimentRunManager.SaveSeperatedExperimentRuns();
    case 2
        saveType = varargin(1);
        filePath = varargin(2);
        if(strcmp(saveType{:}, 'separate'))
            experimentRunManager.SaveSeperatedExperimentRuns();
        elseif(strcmp(saveType{:}, 'single'))
            experimentRunManager.SaveExperimentRuns(filePath{:});
        else
            warning('Unknown save type')
        end
end

end