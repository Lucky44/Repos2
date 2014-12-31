/*  Spawn units at randomized, predetermined locations and then PUTS THEM IN BUILDINGS!
    This version does not scale to the number of players, so the number of squads spawned is configured in the init box code used
        by TAW_Lucky

        Comments explain more info about the configurable elements.

        Syntax:
                handle = [
                                        this,
                                        ["spawn marker1","spawn marker2"],
                                        SquadMinSize,
                                        SquadMaxSize,
                                        NumberOfSquadsToSpawn,
                                        HostileFaction,
                                ]  execVM "scripts\spawnInfSqdBldg2.sqf";

                Example: handle = [this, ["spawnMarker1","spawnMarker2"], 4, 12, 3, "CAFafP"]  execVM "scripts\spawnInfSqdBldg2.sqf";

        This script assumes that players are on the West/BluFor side and hostiles are East/OpFor side.
        Also assumes the script will be in a folder called: scripts
*/


//--SECTION 1 --------------------------------------------------------------------------------------------------
if (!isServer) exitwith {};

private ["_rndSpd","_rndBhv","_rndTO","_rndForm","_rndType","_rnd","_units","_squadInf","_HostileSquadMinBase","_HostileSqdMaxBase","_DifficultyFactor","_HostileSquadRange","_spawnPt","_size","_spawnee","_faction","_numSqds","_SL"];


        //Set the squad minimum size; this is a hard bottom limit; total size will be randomized.
                _HostileSquadMinBASE = (_this select 2); //minimum squad size; this can be modified by players' DifficultyFactor parameter choice in Role Choice Menu

        //Set the squad maximum size;
                _HostileSquadMaxBASE = (_this select 3); //this can be modified by players' DifficultyFactor parameter choice in Role Choice Menu

        //Set the number of squads to spawn when this script is called
                _numSqds = (_this select 4);

        //Set Unit Factions
                _faction = (_this select 5); //Options included: CAFeu (CAF European), CAFaf (CAF African), CAFme (CAF Middle Eastern), CSAT


        //You can change the odds of which type of unit will be picked based on the number of listings for each one.
        //For example, if you put more medics in the list (e.g., "O_medic_F","O_medic_F","O_medic_F",), that will make it more likely medics will spawn
                if (_faction == "CSAT") then {
                        unitsInf = ["O_soldier_LAT_F",
                                "O_soldier_F","O_soldier_F","O_soldier_F",
                                "O_medic_F",
                                "O_soldier_Lite_F","O_soldier_lite_F",
                                "O_soldier_GL_F",
                                "O_soldier_AR_F","O_soldier_AR_F"]; //note that there is no comma after the final unit listing
                        };

                //use CAF Euro units:
                if (_faction == "CAFeu") then {
                        unitsInf = [
                                "CAF_AG_EUR_PK","CAF_AG_EUR_PK",
                                "CAF_AG_EUR_RPK","CAF_AG_EUR_RPK",
                                "CAF_AG_EUR_AK74GL",
                                "CAF_AG_EUR_RPG","CAF_AG_EUR_RPG","CAF_AG_EUR_RPG",
                                "CAF_AG_EUR_AK47","CAF_AG_EUR_AK47","CAF_AG_EUR_AK74","CAF_AG_EUR_AK74"]; //note that there is no comma after the final unit listing
                };

                //use CAF African PIRATE units:
                if (_faction == "CAFafP") then {
                        unitsInf = [
                                "CAF_AG_AFR_P_PKM","CAF_AG_AFR_P_PKM",
                                "CAF_AG_AFR_P_RPK74",
                                "CAF_AG_AFR_P_SVD",
                                "CAF_AG_AFR_P_GL",
                                "CAF_AG_AFR_P_RPG","CAF_AG_AFR_P_RPG",
                                "CAF_AG_AFR_P_AK47","CAF_AG_AFR_P_AK47","CAF_AG_AFR_P_AK74","CAF_AG_AFR_P_AK74","CAF_AG_AFR_P_AK74"]; //note that there is no comma after the final unit listing
                };

                //use CAF African units:
                if (_faction == "CAFaf") then {
                        unitsInf = [
                                "CAF_AG_AFR_PK","CAF_AG_AFR_PK",
                                "CAF_AG_AFR_RPK","CAF_AG_AFR_RPK",
                                "CAF_AG_AFR_AK74GL",
                                "CAF_AG_AFR_RPG","CAF_AG_AFR_RPG","CAF_AG_AFR_RPG",
                                "CAF_AG_AFR_AK47","CAF_AG_AFR_AK47","CAF_AG_AFR_AK74","CAF_AG_AFR_AK74"]; //note that there is no comma after the final unit listing
                };

                //use CAF Middle East units:
                if (_faction == "CAFme") then {
                        unitsInf = [
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
//_DifficultyFactor = paramsArray select 0; // See Description.ext for values. Allows players to set this in Role Choice Menu by clicking PARAMETERS
_HostileSquadMin = ceil(_HostileSquadMinBASE * _DifficultyFactor); //default for DifficultyFactor is 1
_HostileSquadMax = ceil(_HostileSquadMaxBASE * _DifficultyFactor);
_HostileSquadRange = (_HostileSquadMax - _HostileSquadMin)+1; //this sets the range for group size
if (_HostileSquadRange <=0) then {_HostileSquadRange = 1};


for "_n" from 1 to _numSqds do {
    _spawnPt = getMarkerPos ((_this select 1) call BIS_fnc_selectRandom); //turns marker name into [x,y,z] position array

    _size = _HostileSquadMin + (floor(random _HostileSquadRange)); // random group size, based on configuration at top

        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        //spawn infantry units^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        _squadInf = createGroup East;
        for "_x" from 1 to _size do {
                _spawnee = unitsInf call BIS_fnc_selectRandom;
                _spawnee createUnit [_spawnPt, _squadInf];
                //sleep 1;
        };/////////////////////////////////////////////////////////////////////////////////////////////////////
        _squadInf setBehaviour "aware";

    //Move units into building(s) nearby using ZenOccupyHouse script
    _SL = leader _squadInf ;
    [getPosATL _SL, units group _SL, 30, true, false] execVM "scripts\Zen_OccupyHouse.sqf";
    (group _SL) setBehaviour "AWARE";


        sleep 10+(random 5); //put a pause between each squad spawning
}; // end of For loop which is called once per squad to spawn

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
