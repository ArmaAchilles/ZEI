// Spawns some markers indicating building positions within the object.
// This is intended to highlight positions to avoid when decorating houses.
params [["_mode","",[""]],["_input",[],[[]]]];

switch _mode do {
	case "init": {
		_input params [["_logic",objNull,[objNull]],["_isActivated",TRUE,[TRUE]], ["_isCuratorPlaced",FALSE,[TRUE]]];
		
		// In MP only run for local client.
		if (!local _logic) exitWith {};
								
		private _bldArr = nearestObjects [_logic, ["building"], 50, TRUE]; 
		
		_bldArr = _bldArr select { str (_x buildingPos 0) != "[0,0,0]" };
		
		if (count _bldArr > 1) then { _bldArr resize 1 };
	
		// Delete the module to prevent any dependencies.
		if (_logic isKindOf "Logic") then {
			if (is3DEN) then { delete3DENEntities [_logic] } else { deleteVehicle _logic };
		};
				
		collect3DENHistory {
			{ 
				private _bld = _x;
				private _bPos = _bld buildingPos -1;
				if (count _bPos > 0) then {
					{		
						private _obj = create3DENEntity ["Object", "Sign_Arrow_Large_Green_F", [0, 0, 0]];
						_obj set3DENAttribute ["rotation", [ 0, 0, 0]];
						if (surfaceIsWater _x) then {
							_obj set3DENAttribute ["position", AGLToASL _x]							
						} else {
							_obj set3DENAttribute ["position", _x]
						};
					} forEach _bPos;
				};
			} forEach _bldArr;
		};
	};
};

TRUE