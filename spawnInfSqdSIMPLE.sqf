// Spawn a squad of infantry and send them on a few waypoints

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
        _spawnee = unitsInf call BIS_fnc_selectRandom;
        _spawnee createUnit [_spawnPt, _squadInf];
};



//Now assign waypoints to the squad:--------------------------------------------------------------------
_wp = _squadInf addWaypoint [getMarkerPos "WP1a",40]; //assumes a marker named "WP1a" is on map
_wp setWaypointType "MOVE";
_wp setWaypointFormation "DIAMOND";

_wp = _squadInf addWaypoint [getMarkerPos "WP1b",40];//assumes a marker named "WP1b" is on map
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "COMBAT";
_wp setWaypointTimeout [20,40,60];

_wp = _squadInf addWaypoint [getMarkerPos "WP1c",40];//assumes a marker named "WP1c" is on map
_wp setWaypointType "MOVE";
