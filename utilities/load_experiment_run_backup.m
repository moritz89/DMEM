function load_experiment_run_backup()
%LOAD_EXPERIMENT_RUN_BACKUP Loads the backed up experiment run manager file
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>

global experimentRunManager;
experimentRunManager = ExperimentRunManager('load backup');

end

