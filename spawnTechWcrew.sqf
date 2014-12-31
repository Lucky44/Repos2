/*  Spawn units at randomized, predetermined locations and then send them moving on WPs
    This version does not scale to the number of players, so the number of squads spawned is configured in the init box code used
        by TAW_Lucky

        Comments explain more info about the configurable elements.

        Syntax:
                handle = [
                                        this,
                                        ["spawn marker1","spawn marker2",etc],
                                        SquadMinSize,
                                        SquadMaxSize,
                                        NumberOfSquadsToSpawn,
                                        HostileFaction,
                                        ["waypoint1a","waypoint1b",etc]
                                ]  execVM "scripts\spawnTechWcrew.sqf";

                Example: handle = [this, ["spawnMarker1","spawnMarker2"], 6, 12, 3, "CSAT",["WP1a","WP1b","WP1c","WP1d","WP1e","WP1f","WP1z"]]  execVM "scripts\spawnTechWcrew.sqf";

        This script assumes that players are on the West/BluFor side and hostiles are East/OpFor side.
        Also assumes the script will be in a folder called: scripts
*/

//--SECTION 1 --------------------------------------------------------------------------------------------------
if (!isServer) exitwith {};

private ["_rndSpd","_rndBhv","_rndTO","_rndForm","_rndType","_rnd","_units","_TechSqd","_HostileSquadMinBase","_HostileSqdMaxBase","_DifficultyFactor","_HostileSquadRange","_spawnPt","_size","_spawnee","_faction","_sqdFactor","_numSqds","_technical","_unitsTech"];


        //Set the squad minimum size; this is a hard bottom limit; total size will be randomized.
                _HostileSquadMinBASE = (_this select 2); //minimum squad size; this can be modified by players' DifficultyFactor parameter choice in Role Choice Menu

        //Set the squad maximum size;
                _HostileSquadMaxBASE = (_this select 3); //this can be modified by players' DifficultyFactor parameter choice in Role Choice Menu

        //Set the number of squads to spawn when this script is called
                _numSqds = (_this select 4);

        //Set Unit Factions
                _faction = (_this select 5); //Options included: CAFeu (CAF European), CAFaf (CAF African), CAFme (CAF Middle Eastern), CSAT

        //Choose/Set Waypoints from the ones considered
                _waypointMarkers = (_this select 6);


        //Spawn this type of Technical HMG:
                //use CAF Euro units:
                if (_faction == "CAFeu") then {
                        _unitsTech = [
                                "caf_ag_eur_Offroad_armed_01"]; //note that there is no comma after the final unit listing
                };

                //use CAF African units:
                if (_faction == "CAFaf") then {
                        _unitsTech = [
                                "CAF_AG_AFR_Offroad_armed_01"]; //note that there is no comma after the final unit listing
                };

                //use CAF Middle East units:
                if (_faction == "CAFme") then {
                        _unitsTech = [
                                "CAF_AG_ME_Offroad_armed_01"]; //note that there is no comma after the final unit listing
                };


//--SECTION 2: DO NOT ALTER ANYTHING BELOW THIS LINE --------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------


//(_HostileSquadMinBASE + (west countside allunits)/_sqdFactor); // sets max group size (base) to consider totaly players. Next: modified by DifficultyFactor

_DifficultyFactor = 1; //DEFAULT for this mission, set in Description.ext
//_DifficultyFactor = paramsArray select 0; // See Description.ext for values. Allows players to set this in Role Choice menu by clicking PARAMETERS
_HostileSquadMin = ceil(_HostileSquadMinBASE * _DifficultyFactor); //default for DifficultyFactor is 1
_HostileSquadMax = ceil(_HostileSquadMaxBASE * _DifficultyFactor);
_HostileSquadRange = (_HostileSquadMax - _HostileSquadMin)+1; //this sets the range for group size
if (_HostileSquadRange <=0) then {_HostileSquadRange = 1};


for "_n" from 1 to _numSqds do {
    hint format ["Spawning technical %1",_n];//won't show up on dedi server

    _spawnPt = getMarkerPos ((_this select 1) call BIS_fnc_selectRandom); //turns marker name into [x,y,z] position array

    //spawn a technical ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    _technical = createVehicle ["CAF_AG_ME_Offroad_armed_01", _spawnPt,[],0,"NONE"];
    createVehicleCrew _technical;

    //Add waypoints for technical group to move and patrol^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    _markerCount = (count _waypointMarkers) - 1;
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
    _rndForm = random 1; //randomize Formation
    _rndTO = (random 10)+2; //randomize Time Out

            // create and assign the waypoint
    if (_forEachIndex != _markerCount) then {

        _wp = (group _Technical) addWaypoint [getMarkerPos _markerName, 0]; //the number (default is 0) is the radius w/in which the WP will be, randomly
        if (_rndSpd < 0.8) then {_wp setWaypointSpeed "LIMITED"}; // default is NORMAL
        if (_rndBhv < 0.4) then {_wp setWaypointBehaviour "COMBAT"}; // default is AWARE ---I think
        if (_rndType < 0.2) then {_wp setWaypointType "SAD"};  //default is MOVE
        if (_rndForm < 0.33) then {_wp setWaypointFormation "COLUMN"}; //default = WEDGE
        _wp setWaypointTimeout [0,_rndTO,(_rndTO + 9)];

    } else {

        _wp = (group _Technical) addWaypoint [getMarkerPos _markerName, 30];  //assumes final WP is CYCLE; ignored if blank?
        _wp setWaypointType "CYCLE"; // set WP type here

    };

    } forEach _waypointMarkers;

    sleep 20+(random 25); //put a pause between each squad spawning
}; // end of For loop which is called once per squad to spawn

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
