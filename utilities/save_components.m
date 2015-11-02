function save_components(varargin)
%SAVE_COMPONENT_MANAGER Calls the save to file function of componentManager
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 14.4.2015
%   @updated 12.8.2015

fprintf('Saving components...\n');

global componentManager;
switch nargin
    case 0
        componentManager.SaveSeperatedComponents();
    case 2
        saveType = varargin(1);
        filePath = varargin(2);
        if(strcmp(saveType{:}, 'separate'))
            componentManager.SaveSeperatedComponents();
        elseif(strcmp(saveType{:}, 'single'))
            componentManager.SaveComponents(filePath{:});
        else
            warning('Unknown save type')
        end
end

end

