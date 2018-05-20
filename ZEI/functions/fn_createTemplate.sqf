params [
		["_bld", objNull],
		["_fillArea", FALSE],
		["_isCuratorPlaced", FALSE],
		["_civilian", TRUE],
		["_infoOnly", FALSE]
	];

// Skip previously processed houses
if (isNull _bld || !isNull (_bld getVariable ["zei_furnished", objNull])) exitWith {};

private _templates = [];

if (_civilian) then {
	_templates = [_bld] call ZEI_fnc_civTemplates;
} else {
	_templates = [_bld] call ZEI_fnc_milTemplates;
};

// Return the number of templates only.
if (_infoOnly) exitWith { count _templates };

// Furnish house if list is assigned and no people inside
if !(_templates isEqualTo []) then {

	// Non-random template selection
	if (isNil "zei_counter") then {zei_counter = 0};
	if (zei_counter >= count _templates) then {zei_counter = 0};
	private _items = _templates select zei_counter;  
	zei_counter = zei_counter + 1;
	
	// Random template selection
	//_items = selectRandom _templates;
	
	// Get building rotation
	([_bld] call ZEI_fnc_misc_XYRot) params ["_xRot", "_yRot"];
	
	// TODO: Rotate objects by _rotation;
	
	// Spawn items depending on Zeus/Eden
	private _lastItem = objNull; // to track if it was undo in eden
	if (_isCuratorPlaced) then {
		[_bld, false] remoteExecCall ["allowDamage", _bld]; // Stop floating items when it's destroyed.
		
		// TODO: Sort x & y ROT of _bld to object.
		{ 
			_x params ["_item", "_offset", ["_angle", 0], ["_rotation", [0, 0]]];		
			_item = [_item] call ZEI_fnc_randomiseObject;
			
			//supersimple test
			//_item = getText (configfile >> "CfgVehicles" >> _item >> "model");
			
			private _obj = createSimpleObject [_item, AGLtoASL (_bld modelToWorld _offset)];
			_obj setVectorDirAndUp [_direction, _up];
			_obj setDir ((getDir _bld) - _angle);
			_lastItem = _obj;
		} forEach _items;
	} else {
		_bld set3DENAttribute ["allowDamage", false]; // Stop floating items when it's destroyed.
		
		{ 
			_x params ["_item", "_offset", ["_angle", 0], ["_rotation", [0, 0]]];
			_item = [_item] call ZEI_fnc_randomiseObject;
			private _obj = create3DENEntity ["Object", _item, [0,0,0], true];
			_obj set3DENAttribute ["position", _bld modelToWorld _offset];
			_obj set3DENAttribute ["rotation", [ _xRot, _yRot, ((getDir _bld) + _angle)]];
			_obj set3DENAttribute ["objectIsSimple", true];
			_lastItem = _obj;
		} forEach _items;
	};
	
	_bld setVariable ["zei_furnished", _lastItem];
};