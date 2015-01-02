//////////////////////////////////////////////////////////////////
/* "SpawnVeh1.sqf"
   Spawn ground vehicle units, randomly chosen from array of possibles
   Scale this based on the number of players in the mission.

        Syntax:
                handle = [
                                        this,
                                        "spawnVeh1",
                                        HostileFaction,
                                        ["waypoint1a","waypoint1b",etc]
                                ]  execVM "scripts\spawnVeh1.sqf";

                Example: handle = [this, "spawnVeh1", "CSAT",["WP1a","WP1b","WP1c","WP1d","WP1e","WP1f","WP1z"]]  execVM "scripts\spawnVeh1.sqf";

        This script assumes that players are on the West/BluFor side and hostiles are East/OpFor side.
        Also assumes the script will be in a folder called: scripts
*/
// Created by: TAW_Lucky
//////////////////////////////////////////////////////////////////////////

// shouldn't need this since it's called from a !isServer script, but to be clean about it...
if (!isServer) exitwith {}; // make sure only the server runs the script

private ["_units","_squadGroup","_spawnPt","_squadGroup","_size"];

//Set the Spawn Point:
		_spawnPt = getMarkerPos (_this select 1);

//Set Unit Factions
        _faction = (_this select 2); //Options included: AAF, CSAT
        hint format ["faction=%1",_faction]; //DEBUGGING ONLY!!!!!!!!!!!!!!!
        sleep 3; //DEBUGGING ONLY!!!!!!!!!!!!!!!

//Choose/Set Waypoints from the ones considered
        _WPmarkers = (_this select 3);

//////////////////////////////////////////////////////////////////////////
/*
if (_faction == "CSAT") then {
 	_unitsVeh = ["O_UGV_01_rcws_F",
				"O_MRAP_02_hmg_F","O_MRAP_02_hmg_F","O_MRAP_02_gmg_F",
				"O_Veh_Wheeled_02_rcws_F","O_Veh_Wheeled_02_rcws_F",
				"O_Veh_Tracked_02_cannon_F","O_Veh_Tracked_02_cannon_F",
				"O_MBT_02_cannon_F"];
			};
*/
//if (_faction == "AAF") then {
	_unitsVeh = ["I_UGV_01_rcws_F",
				"I_MRAP_03_hmg_F","I_MRAP_03_hmg_F",
				"I_MRAP_03_gmg_F",
				"I_Veh_Wheeled_03_cannon_F","I_Veh_Wheeled_03_cannon_F",
				"I_Veh_Tracked_03_cannon_F","I_Veh_Tracked_03_cannon_F",
				"I_MBT_03_cannon_F"];
//			};


_numVeh = ceil((count PlayableUnits)/12) + floor(random 2.5)  ;// sets min Veh num at the Camp = to player count divided by 12, rounded up
	hint format ["_numVeh=%1",_numVeh]; //DEBUGGING ONLY!!!!!!!!!!!!!!!
	sleep 3;//DEBUGGING ONLY!!!!!!!!!!!!!!!!!!!!!
if (_numVeh <=0) then {_numVeh = 1};//always have at least one

hint format ["_unitsVeh=%1",_unitsVeh]; //DEBUGGING ONLY!!!!!!!!!!!!!!!
sleep 5;//DEBUGGING ONLY!!!!!!!!!!!!!!!!!!!!!

//Spawn Vehicle(s)
for "_i" from 1 to _numVeh do {

	_VehGrp = createGroup east; // create new group for each vehicle
	_VehChoice = _unitsVeh call BIS_fnc_selectRandom;
	_Veh1 = [_spawnPt, 0, _VehChoice, _VehGrp] call bis_fnc_spawnvehicle; // this spawns the vehicle and includes crew
	//_Veh1 is the VEHICLE array, with the actual vehicle being the first element of the array!!


	//Give Veh set of WPs to follow^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

	_markerCount = (count _WPmarkers) - 1;
	{
	         _markerName = "";

	         if ((typeName _x) == "ARRAY") then {
	                 // randomize to pick 1 waypoint from array
	                 _markerName = _x call BIS_fnc_selectRandom;
	         } else {
	                 _markerName = _x;
	         };

			 _rndSpd = random 1; //randomize waypoint Speed
			 _rndBhv = random 1; //randomize waypoint Behaviour
			 _rndType = random 1; //randomize waypoint Type
			 _rndTO = ceil(random 30); //randomize Time Out

			 // create and assign the waypoint
			 if (_forEachIndex != _markerCount) then {
			     _wp = _vehGrp addWaypoint [getMarkerPos _markerName, 0]; //the number (default is 0) is the radius w/in which the WP will be, randomly
			     if (_rndSpd < 0.6) then {_wp setWaypointSpeed "LIMITED"}; // default is NORMAL
			     if (_rndBhv < 0.4) then {_wp setWaypointBehaviour "COMBAT"}; // default is AWARE ---I think
			     if (_rndType < 0.4) then {_wp setWaypointType "SAD"};  //default is MOVE
			     _wp setWaypointTimeout [0,_rndTO,(_rndTO + 9)];
			 } else {
			     _wp = _vehGrp addWaypoint [getMarkerPos _markerName, 0];  //assumes final WP is CYCLE; ignored if blank?
			     _wp setWaypointType "CYCLE"; // set WP type here
			 };

	 } forEach _WPmarkers;

	 sleep 20+(random 5); //put a pause between each squad spawning}

};//end of loop to spawn vehicles
