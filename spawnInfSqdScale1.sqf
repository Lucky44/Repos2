/*  Spawn units at randomized, predetermined locations and then send them moving on WPs
    This version scales to the number of players, so the RATIO of squads spawned to players is configured in the init box code used
        by TAW_Lucky

        Comments explain more info about the configurable elements.

        Syntax:
                handle = [
                                        this,
                                        ["spawn marker1","spawn marker2",etc],
                                        SquadMinSize,
                                        SquadMaxSize,
                                        SquadScalingRatio,
                                        HostileFaction,
                                        ["waypoint1a","waypoint1b",etc]
                                ]  execVM "scripts\spawnInfSqdScale.sqf";

                Example: handle = [this, ["spawnMarker1","spawnMarker2"], 6, 12, 1, "CSAT",["WP1a","WP1b","WP1c","WP1d","WP1e","WP1f","WP1z"]]  execVM "scripts\spawnInfSqdScale.sqf";

        This script assumes that players are on the West/BluFor side and hostiles are East/OpFor side.
        Also assumes the script will be in a folder called: scripts
*/

//--SECTION 1 --------------------------------------------------------------------------------------------------
if (!isServer) exitwith {};

private ["_rndSpd","_rndBhv","_rndTO","_rndForm","_rndType","_rnd","_units","_unitsInf","_squadInf","_HostileSquadMinBase","_HostileSqdMaxBase","_DifficultyFactor","_HostileSquadRange","_spawnPt","_size","_spawnee","_faction","_sqdRatio","_numSqds"];


        //Set the squad minimum size; this is a hard bottom limit; total size will be randomized.
                _HostileSquadMinBASE = (_this select 2); //minimum squad size; this can be modified by players' DifficultyFactor parameter choice in Role Choice Menu

        //Set the squad maximum size;
                _HostileSquadMaxBASE = (_this select 3); //this can be modified by players' DifficultyFactor parameter choice in Role Choice Menu

        //1 is default; 2 spawns 2 squads per 8 players; 3 spawns 3 squads per 8 players, etc.
                _SqdRatio = (_this select 4);//this scales the spawned squads' sizes based on the number of players;

        //Set Unit Factions
                _faction = (_this select 5); //Options included: CAFeu (CAF European), CAFaf (CAF African), CAFme (CAF Middle Eastern), CSAT

        //Choose/Set Waypoints from the ones considered
                _waypointMarkers = (_this select 6);


        //You can change the odds of which type of unit will be picked based on the number of listings for each one.
        //For example, if you put more medics in the list (e.g., "O_medic_F","O_medic_F","O_medic_F",), that will make it more likely medics will spawn
                //using CSAT units:
                if (_faction == "CSAT") then {
                        _unitsInf = ["O_soldier_LAT_F",
                                "O_soldier_F","O_soldier_F","O_soldier_F",
                                "O_medic_F",
                                "O_soldier_Lite_F","O_soldier_lite_F",
                                "O_soldier_GL_F",
                                "O_soldier_AR_F","O_soldier_AR_F"]; //note that there is no comma after the final unit listing
                        };

                //use CAF Euro units:
                if (_faction == "CAFeu") then {
                        _unitsInf = [
                                "CAF_AG_EUR_PK","CAF_AG_EUR_PK",
                                "CAF_AG_EUR_RPK","CAF_AG_EUR_RPK",
                                "CAF_AG_EUR_AK74GL",
                                "CAF_AG_EUR_RPG","CAF_AG_EUR_RPG","CAF_AG_EUR_RPG",
                                "CAF_AG_EUR_AK47","CAF_AG_EUR_AK47","CAF_AG_EUR_AK74","CAF_AG_EUR_AK74"]; //note that there is no comma after the final unit listing
                };

                //use CAF African PIRATE units:
                if (_faction == "CAFafP") then {
                        _unitsInf = [
                                "CAF_AG_AFR_P_PKM","CAF_AG_AFR_P_PKM",
                                "CAF_AG_AFR_P_RPK74",
                                "CAF_AG_AFR_P_SVD",
                                "CAF_AG_AFR_P_GL",
                                "CAF_AG_AFR_P_RPG","CAF_AG_AFR_P_RPG",
                                "CAF_AG_AFR_P_AK47","CAF_AG_AFR_P_AK47","CAF_AG_AFR_P_AK74","CAF_AG_AFR_P_AK74","CAF_AG_AFR_P_AK74"]; //note that there is no comma after the final unit listing
                };

                //use CAF African units:
                if (_faction == "CAFaf") then {
                        _unitsInf = [
                                "CAF_AG_AFR_PK","CAF_AG_AFR_PK",
                                "CAF_AG_AFR_RPK","CAF_AG_AFR_RPK",
                                "CAF_AG_AFR_GL",
                                "CAF_AG_AFR_RPG","CAF_AG_AFR_RPG","CAF_AG_AFR_RPG",
                                "CAF_AG_AFR_AK47","CAF_AG_AFR_AK47","CAF_AG_AFR_AK74","CAF_AG_AFR_AK74"]; //note that there is no comma after the final unit listing
                };

                //use CAF Middle East units:
                if (_faction == "CAFme") then {
                        _unitsInf = [
                                "CAF_AG_ME_PK","CAF_AG_ME_PK",
                                "CAF_AG_ME_RPK","CAF_AG_ME_RPK",
                                "CAF_AG_ME_GL","CAF_AG_ME_GL",
                                "CAF_AG_ME_RPG","CAF_AG_ME_RPG","CAF_AG_ME_RPG",
                                "CAF_AG_ME_AK47","CAF_AG_ME_AK47","CAF_AG_ME_AK74","CAF_AG_ME_AK74"]; //note that there is no comma after the final unit listing
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

_numSqds = round( ((west countside allunits)/8) * _sqdRatio);
if (_numSqds <= 0) then {_numSqds = 1};

for "_n" from 1 to _numSqds do {
    _spawnPt = getMarkerPos ((_this select 1) call BIS_fnc_selectRandom); //turns marker name into [x,y,z] position array

    _size = _HostileSquadMin + (floor(random _HostileSquadRange)); // random group size, based on configuration at top

        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        //spawn infantry units^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        _squadInf = createGroup East;
        for "_x" from 1 to _size do {
                _spawnee = _unitsInf call BIS_fnc_selectRandom;
                _spawnee createUnit [_spawnPt, _squadInf];
                //sleep 1;
        };/////////////////////////////////////////////////////////////////////////////////////////////////////



        //Add randomized waypoints for INF group to move and patrol^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
        _rndTO = random 30; //randomize Time Out

                // create and assign the waypoint
        if (_forEachIndex != _markerCount) then {

            _wp = _squadInf addWaypoint [getMarkerPos _markerName, 0]; //the number (default is 0) is the radius w/in which the WP will be, randomly
            if (_rndSpd < 0.6) then {_wp setWaypointSpeed "LIMITED"}; // default is NORMAL
            if (_rndBhv < 0.4) then {_wp setWaypointBehaviour "SAFE"}; // default is AWARE ---I think
            if (_rndType < 0.4) then {_wp setWaypointType "SAD"};  //default is MOVE
            if (_rndForm < 0.33) then {_wp setWaypointFormation "COLUMN"}; //default = WEDGE
            _wp setWaypointTimeout [0,_rndTO,(_rndTO + 9)];

        } else {

            _wp = _squadInf addWaypoint [getMarkerPos _markerName, 30];  //assumes final WP is CYCLE; ignored if blank?
            _wp setWaypointType "CYCLE"; // set WP type here

        };

        } forEach _waypointMarkers;

        sleep 30+(random 15); //put a pause between each squad spawning
}; // end of For loop which is called once per squad to spawn

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
