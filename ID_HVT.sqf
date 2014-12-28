//Script for addAction to body of HVT to check/confirm identity

private ["_body","_actor"];
 
_body = [_this, 0, objNull] call BIS_fnc_param;
_actor = [_this, 1, objNull] call BIS_fnc_param;
 
// Broadcast action removal
[_body, "removeAllActions", true, false] call BIS_fnc_MP;
 
hint "You compare the body to intel photos you have...";
 
sleep 9; // spend time checking the intel
 
if (alive _actor && !(_actor getVariable ["AGM_Unconscious", false])) then {
 
    hint "Positive ID on one of the Lieutenants!";
    deleteVehicle _body;
    HVTcount = HVTcount +1;
    publicVariable "HVTcount";
 
} else { // if actor is killed while checking, reAdd the action
 
	// Broadcast addAction on body
	[[[_body], { (_this select 0) addAction ["Verify LT identity", "scripts\ID_LT.sqf"]; }], "BIS_fnc_spawn", true, false] call BIS_fnc_MP;
 
};
