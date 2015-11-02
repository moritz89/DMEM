classdef Variant
%VARIANT(name, type, subType, slot) Used to create Simulink Variant objects
%   The variant is identified by its name (Simulink model variant), the 
%   type (Auto, Strecke, Atm, ...), the subType (real, virtuell) if
%   applicable, and slot (positive integer) if applicable.

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 26.5.2015
%   @updated 9.7.2015
    
properties
    Name
    Type
    SubType
    Slot
end

methods
    function obj = Variant(name, type, subType, slot)
        obj.Name = name;
        obj.Type = type;
        obj.SubType = subType;
        obj.Slot = slot;
    end
    
    function equal = IsTypeSubTypeSlotVariantEqual(obj, variant)
        % Wrapper for IsTypeSubTypeSlotEqual()
        
        equal = obj.IsTypeEqual(variant.Type, variant.SubType, variant.Slot);
    end
    
    function equal = IsTypeSubTypeSlotEqual(obj, type, subType, slot)
        % Checks if everything before the name is equal / Checks that both
        % components belong to the same variant. Returns 1 if it is equal,
        % 0 if not.
        
        % Check if the type is the same
        typeEqual = strcmp(obj.Type, type);
        % Check if subType is the same if either are valid subTypes
        if(isempty(subType) && isempty(obj.SubType))
            subTypeEqual = 1;
        else
            subTypeEqual = strcmp(obj.SubType, subType);
        end
        % Check if slot is the same if either are valid
        if(slot < 1 && obj.Slot < 1)
            slotEqual = 1;
        else
            slotEqual = (slot == obj.Slot);
        end
	    if(typeEqual && subTypeEqual && slotEqual)
            equal = 1;
        else
            equal = 0;
        end
    end
    
    function equal = IsNameVariantEqual(obj, variant)
        % Wrapper for IsNameEqual
        
        equal = obj.IsNameEqual(variant.Type, variant.SubType, variant.Slot);
    end
        
    function equal = IsNameEqual(obj, type, subType, slot, name)
        % Checks if everything including the name is equal/Checks that both
        % components belong to the same variant and have the same name.
        % Returns 1 if it is equal, 0 if not.
        
        % Check if the type is the same
        typeEqual = strcmp(obj.Type, type);
        % Check if subType is the same if either are valid subTypes
        if(isempty(subType) && isempty(obj.SubType))
            subTypeEqual = 1;
        else
            subTypeEqual = strcmp(obj.SubType, subType);
        end
        % Check if slot is the same if either are valid
        if(slot < 1 && obj.Slot < 1)
            slotEqual = 1;
        else
            slotEqual = (slot == obj.Slot);
        end
        nameEqual = strcmp(obj.Name, name);
	    if(typeEqual && subTypeEqual && slotEqual && nameEqual)
            equal = 1;
        else
            equal = 0;
        end
    end
    
    function equal = IsTypeSlotVariantEqual(obj, variant)
        equal = obj.IsTypeSlotEqual(variant.Type, variant.Slot);
    end
    
    function equal = IsTypeSlotEqual(obj, type, slot)
        % Checks if the type and slot are equal / Returns 1 if it is equal,
        % 0 if not.
        
        % Check if the type is the same
        typeEqual = strcmp(obj.Type, type);
        % Check if the slot is the same if either are valid
        if(slot < 1 && obj.Slot < 1)
            slotEqual = 1;
        else
            slotEqual = (slot == obj.Slot);
        end
	    if(typeEqual && slotEqual)
            equal = 1;
        else
            equal = 0;
        end
    end
end
    
end

