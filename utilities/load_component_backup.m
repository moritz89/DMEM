function load_component_backup()
%LOAD_COMPONENT_BACKUP Loads the backed up component manager file
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>

componentManager = ComponentManager('load backup');
assignin('base', 'componentManager', componentManager);

end

