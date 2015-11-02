function [buses, busFileName] = bus_variables()
% The model configurations are saved as [file name, variable name] tuples
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 24.12.2015

% The local path in which the model configurations are saved
busFileName = fullfile('data', 'buses');

buses = { ...
    ... % External Interface
    'SYSTEM_CONTROL_BUS', ...
        'HARDWARE_CLEARANCES', ...
        'CAN_CONTROL_BUS', ...
    'SYSTEM_STATUS_BUS', ...
    'CAN_STATUS_BUS', ...
    ... % Hardware
    'HARDWARE_INPUT_BUS', ...
    'HARDWARE_OUTPUT_BUS', ...
    'REAL_HARDWARE_INPUT_BUS', ...
    'REAL_HARDWARE_OUTPUT_BUS', ...
    ... % Drive Motor (AntriebsMAschine)
    'ATM_INPUT_BUS', ...
        'ATM_INPUT_PFLICHT', ...
        'ATM_INPUT_EMPFOHLEN', ...
        'ATM_INPUT_OPTIONAL', ...
    'ATM_OUTPUT_BUS', ...
        'ATM_OUTPUT_PFLICHT', ...
        'ATM_OUTPUT_EMPFOHLEN', ...
        'ATM_OUTPUT_OPTIONAL', ...
    ... % Load Motor (LastMAschine)
    'LAST_INPUT_BUS', ...
    'LAST_OUTPUT_BUS', ...
    ... % Energy Source/Battery (EnergieQuelle)
    'EQ_INPUT_BUS', ...
        'EQ_INPUT_PFLICHT', ...
        'EQ_INPUT_EMPFOHLEN', ...
        'EQ_INPUT_OPTIONAL', ...
    'EQ_OUTPUT_BUS', ...
        'EQ_OUTPUT_PFLICHT', ...
        'EQ_OUTPUT_EMPFOHLEN', ...
        'EQ_OUTPUT_OPTIONAL', ...
    ... % DC Source (Gleichstromquelle)
    'GSQ_INPUT_BUS', ...
    'GSQ_OUTPUT_BUS', ...
    };

end