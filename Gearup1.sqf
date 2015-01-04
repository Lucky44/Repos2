//////////////////////////////////////////////////////////////////
// Give Specific Gear to Players: SEALs get SOF weapons (SD)
// Created by: TAW_Lucky
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private ["_counter","_players","_unit","_boatArray","_boat"];

_counter = 0;// for counting 1 loop per playable unit
_players = units (group P1);
_boatArray = [boat1,boat2,boat3,boat4];

{
	_unit = (_players select _counter);
	_counter = (_counter + 1);
	//hint format ["Counter = %1, unit = %2",_counter,_unit]; // DEBUGGING ONLY!!!!!!!!
	//sleep 2; // DEBUGGING ONLY!!!!!!!!

	//RemoveAllWeapons _unit;
	removeBackpack _unit;
	for "_x" from 1 to 6 do {_unit removeMagazine "20Rnd_556x45_UW_mag"};//remove the mags for SDAR
	for "_x" from 1 to 3 do {_unit removeMagazine "30Rnd_556x45_Stanag"};//same

	_unit addBackpackGlobal "B_FieldPack_blk";

	_unit addItem "NVGoggles";
	_unit assignItem "NVGoggles";
	{_unit addItem "FirstAidKit"} forEach [1,2,3,4];
	//_unit addItem "FirstAidKit";
	{_unit addItem "AGM_morphine"} forEach [1,2,3,4];
	//_unit addItem "AGM_morphine";
	_unit addMagazineGlobal "smokeshell";
	_unit addMagazineGlobal "Chemlight_green";
	_unit addMagazineGlobal "Chemlight_green";
	_unit addMagazineGlobal "Chemlight_red";
	_unit addItem "AGM_cableTie";
	_unit addItem "AGM_cableTie";
	_unit addItem "AGM_EarBuds";

	// If the unit uses MXSW, give MG and ammo, etc.
	if (_unit isKindOf "B_diver_exp_F") then {
		(unitBackPack _unit) addMagazineCargoGlobal ["smokeshell",1];
		_unit addMagazineGlobal "100Rnd_65x39_caseless_mag";//need to add one to unit??
		_unit addWeaponGlobal "arifle_MX_SW_Hamr_pointer_F";
		(unitBackpack _unit) addMagazineCargoGlobal ["100Rnd_65x39_caseless_mag",4];
		_unit addItem "muzzle_snds_H";
	}
	else {
		_unit addMagazineGlobal "30Rnd_65x39_caseless_mag";
		_unit addWeaponGlobal "arifle_MXC_ACO_pointer_snds_F";
		(unitBackpack _unit) addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag",9];
		(unitBackpack _unit) addMagazineCargoGlobal ["smokeshell",1];
	};

	if (_unit isKindOf "B_recon_medic_F") then {
		{_unit addItem "FirstAidKit"} forEach [1,2,3,4,5,6,7,8,9,10];
		{_unit addItem "AGM_morphine"} forEach [1,2,3,4,5,6,7,8];
		{_unit addItem "AGM_epipen"} forEach [1,2,3,4,5,6,7,8];
		{_unit addItem "AGM_bloodbag"} forEach [1,2];
	};

	sleep 1;
} forEach _players; // run it once per player in the player group


for "_i" from 0 to 3 do {
	_boat = _boatArray select _i;
	_boat addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag",20];
	_boat addWeaponCargoGlobal ["arifle_MX_SW_Hamr_pointer_F",4];
	_boat addMagazineCargoGlobal ["100Rnd_65x39_caseless_mag",4];
	_boat addMagazineCargoGlobal ["SmokeShell",8];
	sleep 1;
};
