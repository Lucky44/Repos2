/* Spawn a squad of infantry and send them on a few waypoints

	Requirements/Assumptions:
		-uses a marker on map named "spawn1" as the point where units will be spawned
		-uses CSAT units (change _unitsInf to other factions if desired)
		-creates a 10-man squad (can change the 10 to anything)
		-uses markers on map named WP1a, WP1b and WP1c for the waypoints for the squad
*/

if (!isServer) exitwith {}; //This script should only run on the server


//Initial definitions and setup======================================================================
private ["_unitsInf","_spawnPt", "_squadInf", "_spawnee", "_wp"];

_unitsInf = ["O_soldier_LAT_F",
        "O_soldier_F","O_soldier_F","O_soldier_F",
        "O_medic_F",
        "O_soldier_Lite_F","O_soldier_lite_F",
        "O_soldier_GL_F",
        "O_soldier_AR_F","O_soldier_AR_F"];//assumes we're using CSAT units

_spawnPt = getMarkerPos "spawn1";



//spawn infantry units^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_squadInf = createGroup East;//create a new group to put the units in
for "_x" from 1 to 10 do {
        _spawnee = _unitsInf call BIS_fnc_selectRandom;
        _spawnee createUnit [_spawnPt, _squadInf];
};



//Now assign waypoints to the squad:--------------------------------------------------------------------
_wp = _squadInf addWaypoint [getMarkerPos "WP1a",0]; //assumes a marker named "WP1a" is on map
_wp setWaypointType "MOVE";
_wp setWaypointFormation "DIAMOND";

_wp = _squadInf addWaypoint [getMarkerPos "WP1b",20];//assumes a marker named "WP1b" is on map
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "COMBAT";

_wp = _squadInf addWaypoint [getMarkerPos "WP1c",50];//assumes a marker named "WP1c" is on map
_wp setWaypointType "SAD";
_wp setWaypointTimeout [180,240,300];
