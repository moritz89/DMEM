function load_bus_backup()
%LOAD_BUS_BACKUP Loads the backed up bus backup file
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>

[variables, ~] = bus_variables();
fileName = fullfile('backup', 'buses_bak');
load_parameters(variables, fileName);

end

