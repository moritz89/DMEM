function save_buses(varargin)
%SAVE_BUSES Save the bus variables defined in bus_variables() from the
%   workspace. The varargin variable is the relative path to the file to 
%   save the buses in. If empty, the default location is used.
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 24.12.2015
%   @updated 9.7.2015

fprintf('Saving buses...\n');

[buses, busFileName] = bus_variables();
if(nargin ~= 0)
    if(not(isempty(varargin{:})))
        busFileName = varargin{:};
    end
end
save_parameters(buses, busFileName);

end

