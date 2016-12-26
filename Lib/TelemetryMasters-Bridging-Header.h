//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <sys/socket.h>
#import <Foundation/Foundation.h>

struct F1UDPPacket {
    float m_time;
    float m_lapTime;
    float m_lapDistance;
    float m_totalDistance;
    float m_x;      // World space position
    float m_y;      // World space position
    float m_z;      // World space position
    float m_speed;
    float m_xv;      // Velocity in world space
    float m_yv;      // Velocity in world space
    float m_zv;      // Velocity in world space
    float m_xr;      // World space right direction
    float m_yr;      // World space right direction
    float m_zr;      // World space right direction
    float m_xd;      // World space forward direction
    float m_yd;      // World space forward direction
    float m_zd;      // World space forward direction
    float m_susp_pos_bl;
    float m_susp_pos_br;
    float m_susp_pos_fl;
    float m_susp_pos_fr;
    float m_susp_vel_bl;
    float m_susp_vel_br;
    float m_susp_vel_fl;
    float m_susp_vel_fr;
    float m_wheel_speed_bl;
    float m_wheel_speed_br;
    float m_wheel_speed_fl;
    float m_wheel_speed_fr;
    float m_throttle;
    float m_steer;
    float m_brake;
    float m_clutch;
    float m_gear;
    float m_gforce_lat;
    float m_gforce_lon;
    float m_lap;
    float m_engineRate;
    float m_sli_pro_native_support; // SLI Pro support
    float m_car_position;   // car race position
    float m_kers_level;    // kers energy left
    float m_kers_max_level;   // kers maximum energy
    float m_drs;     // 0 = off, 1 = on
    float m_traction_control;  // 0 (off) - 2 (high)
    float m_anti_lock_brakes;  // 0 (off) - 1 (on)
    float m_fuel_in_tank;   // current fuel mass
    float m_fuel_capacity;   // fuel capacity
    float m_in_pits;    // 0 = none, 1 = pitting, 2 = in pit area
    float m_sector;     // 0 = sector1, 1 = sector2; 2 = sector3
    float m_sector1_time;   // time of sector1 (or 0)
    float m_sector2_time;   // time of sector2 (or 0)
    float m_brakes_temp[4];   // brakes temperature (centigrade)
    float m_wheels_pressure[4];  // wheels pressure PSI
    float m_team_info;    // team ID
    float m_total_laps;    // total number of laps in this race
    float m_track_size;    // track size meters
    float m_last_lap_time;   // last lap time
    float m_max_rpm;    // cars max RPM, at which point the rev limiter will kick in
    float m_idle_rpm;    // cars idle RPM
    float m_max_gears;    // maximum number of gears
    float m_sessionType;   // 0 = unknown, 1 = practice, 2 = qualifying, 3 = race
    float m_drsAllowed;    // 0 = not allowed, 1 = allowed, -1 = invalid / unknown
    float m_track_number;   // -1 for unknown, 0-21 for tracks
    float m_vehicleFIAFlags;  // -1 = invalid/unknown, 0 = none, 1 = green, 2 = blue, 3 = yellow, 4 = red
};

struct DirtRallyPacket {
    float m_time;
    float m_lapTime;
    float m_lapDistance;
    float m_totalDistance;
    float m_x;
    float m_y;
    float m_z;
    float m_speed;
    float m_xv;
    float m_yv;
    float m_zv;
    float m_xr;
    float m_yr;
    float m_zr;
    float m_xd;
    float m_yd;
    float m_zd;
    float m_susp_pos_bl;
    float m_susp_pos_br;
    float m_susp_pos_fl;
    float m_susp_pos_fr;
    float m_susp_vel_bl;
    float m_susp_vel_br;
    float m_susp_vel_fl;
    float m_susp_vel_fr;
    float m_wheel_speed_bl;
    float m_wheel_speed_br;
    float m_wheel_speed_fl;
    float m_wheel_speed_fr;
    float m_throttle;
    float m_steer;
    float m_brake;
    float m_clutch;
    float m_gear;
    float m_gforce_lat;
    float m_gforce_lon;
    float m_lap;
    float m_engineRate; // 37
    float m_unknown1;
    float m_unknown2;
    float m_unknown3;
    float m_unknown4;
    float m_unknown5;
    float m_traction_control;  // 0 (off) - 2 (high)
    float m_unknown6;
    float m_unknown7;   // current fuel mass
    float m_unknown8;   // fuel capacity
    float m_unknown9;    // car status?
    float m_sector;     // 0 = sector1, 1 = sector2; 2 = sector3
    float m_sector1_time;   // time of sector1 (or 0)
    float m_sector2_time;   // time of sector2 (or 0)
    float m_brakes_temp[4];   // brakes temperature (centigrade)
    float m_wheels_pressure[4];  // wheels pressure PSI ?
    float m_unknown10;
    float m_unknown11;    // number of laps
    float m_trackSize;
    float m_unknown13;   // last lap time
    float m_max_rpm;    // cars max RPM, at which point the rev limiter will kick in
    float m_idle_rpm;    // cars idle RPM
    float m_max_gears;    // maximum number of gears
    float m_sessionType;
    float m_unknown14;
    float m_unknown15;
    float m_unknown16;
};

 
// Re-map type-defs to standard C type definitions
typedef    float f32;
typedef  int32_t s32;
typedef uint32_t u32;
typedef  int16_t s16;
typedef uint16_t u16;
typedef   int8_t  s8;
typedef  uint8_t  u8;

// Data enumeration definitions
// =============================================================================
// Header version number to test against
#define UDP_API_VERSION 'a' //5

// Maximum allowed length of string
#define STRING_LENGTH_MAX 64

// Maximum number of general participant information allowed
#define STORED_PARTICIPANTS_MAX 64

// To be used to identify packet type
typedef enum { 
  PACKET_TYPE_TELEMETRY                           = 0,
  PACKET_TYPE_PARTICIPANT_INFO_STRINGS            = 1,
  PACKET_TYPE_PARTICIPANT_INFO_STRINGS_ADDITIONAL = 2
} ePacketType;

// Tyres
typedef enum {
  TYRE_FRONT_LEFT = 0,
  TYRE_FRONT_RIGHT,
  TYRE_REAR_LEFT,
  TYRE_REAR_RIGHT,
  //--------------
  TYRE_MAX
} eTyre;

// Vector
typedef enum {
  VEC_X = 0,
  VEC_Y,
  VEC_Z,
  //-------------
  VEC_MAX
} eVecIndex;

// (Type#1) GameState (to be used with 'mGameState')
typedef enum {
  GAME_EXITED = 0,
  GAME_FRONT_END,
  GAME_INGAME_PLAYING,
  GAME_INGAME_PAUSED,
  //-------------
  GAME_MAX
} eGameState;

// (Type#2) Session state (to be used with 'mSessionState')
typedef enum {
  SESSION_INVALID = 0,
  SESSION_PRACTICE,
  SESSION_TEST,
  SESSION_QUALIFY,
  SESSION_FORMATION_LAP,
  SESSION_RACE,
  SESSION_TIME_ATTACK,
  //-------------
  SESSION_MAX
} eSessionState;

// (Type#3) RaceState (to be used with 'mRaceState')
typedef enum {
  RACESTATE_INVALID,
  RACESTATE_NOT_STARTED,
  RACESTATE_RACING,
  RACESTATE_FINISHED,
  RACESTATE_DISQUALIFIED,
  RACESTATE_RETIRED,
  RACESTATE_DNF,
  //-------------
  RACESTATE_MAX
} eRaceState;

// (Type#4) Current Sector (to be used with 'mCurrentSector')
typedef enum {
  SECTOR_INVALID = 0, 
  SECTOR_START,
  SECTOR_SECTOR1,
  SECTOR_SECTOR2,
  SECTOR_FINISH,
  SECTOR_STOP,
  //-------------
  SECTOR_MAX
} eCurrentSector;

// (Type#5) Flag Colours (to be used with 'mHighestFlagColour')
typedef enum {
  FLAG_COLOUR_NONE = 0,       // Not used for actual flags, only for some query functions
  FLAG_COLOUR_GREEN,          // End of danger zone, or race started
  FLAG_COLOUR_BLUE,           // Faster car wants to overtake the participant
  FLAG_COLOUR_WHITE,          // Approaching a slow car
  FLAG_COLOUR_YELLOW,         // Danger on the racing surface itself
  FLAG_COLOUR_DOUBLE_YELLOW,  // Danger that wholly or partly blocks the racing surface
  FLAG_COLOUR_BLACK,          // Participant disqualified
  FLAG_COLOUR_CHEQUERED,      // Chequered flag
  //-------------
  FLAG_COLOUR_MAX
} eFlagColour;

// (Type#6) Flag Reason (to be used with 'mHighestFlagReason')
typedef enum {
  FLAG_REASON_NONE = 0,
  FLAG_REASON_SOLO_CRASH,
  FLAG_REASON_VEHICLE_CRASH,
  FLAG_REASON_VEHICLE_OBSTRUCTION,
  //-------------
  FLAG_REASON_MAX
} eFlagReason;

// (Type#7) Pit Mode (to be used with 'mPitMode')
typedef enum {
  PIT_MODE_NONE = 0,
  PIT_MODE_DRIVING_INTO_PITS,
  PIT_MODE_IN_PIT,
  PIT_MODE_DRIVING_OUT_OF_PITS,
  PIT_MODE_IN_GARAGE,
  //-------------
  PIT_MODE_MAX
} ePitMode;

// (Type#8) Pit Stop Schedule (to be used with 'mPitSchedule')
typedef enum {
  PIT_SCHEDULE_NONE = 0,        // Nothing scheduled
  PIT_SCHEDULE_STANDARD,        // Used for standard pit sequence
  PIT_SCHEDULE_DRIVE_THROUGH,   // Used for drive-through penalty
  PIT_SCHEDULE_STOP_GO,         // Used for stop-go penalty
  //-------------
  PIT_SCHEDULE_MAX
} ePitSchedule;

// (Type#9) Car Flags (to be used with 'mCarFlags')
typedef enum {
  CAR_HEADLIGHT         = (1 << 0),
  CAR_ENGINE_ACTIVE     = (1 << 1),
  CAR_ENGINE_WARNING    = (1 << 2),
  CAR_SPEED_LIMITER     = (1 << 3),
  CAR_ABS               = (1 << 4),
  CAR_HANDBRAKE         = (1 << 5),
  CAR_STABILITY	        = (1 << 6),
  CAR_TRACTION_CONTROL	= (1 << 7),
} eCarFlags;

// (Type#10) Tyre Flags (to be used with 'mTyreFlags')
typedef enum {
  TYRE_ATTACHED         = (1 << 0),
  TYRE_INFLATED         = (1 << 1),
  TYRE_IS_ON_GROUND     = (1 << 2),
} eTypeFlags;

// (Type#11) Terrain Materials (to be used with 'mTerrain')
typedef enum {
  TERRAIN_ROAD = 0,
  TERRAIN_LOW_GRIP_ROAD,
  TERRAIN_BUMPY_ROAD1,
  TERRAIN_BUMPY_ROAD2,
  TERRAIN_BUMPY_ROAD3,
  TERRAIN_MARBLES,
  TERRAIN_GRASSY_BERMS,
  TERRAIN_GRASS,
  TERRAIN_GRAVEL,
  TERRAIN_BUMPY_GRAVEL,
  TERRAIN_RUMBLE_STRIPS,
  TERRAIN_DRAINS,
  TERRAIN_TYREWALLS,
  TERRAIN_CEMENTWALLS,
  TERRAIN_GUARDRAILS,
  TERRAIN_SAND,
  TERRAIN_BUMPY_SAND,
  TERRAIN_DIRT,
  TERRAIN_BUMPY_DIRT,
  TERRAIN_DIRT_ROAD,
  TERRAIN_BUMPY_DIRT_ROAD,
  TERRAIN_PAVEMENT,
  TERRAIN_DIRT_BANK,
  TERRAIN_WOOD,
  TERRAIN_DRY_VERGE,
  TERRAIN_EXIT_RUMBLE_STRIPS,
  TERRAIN_GRASSCRETE,
  TERRAIN_LONG_GRASS,
  TERRAIN_SLOPE_GRASS,
  TERRAIN_COBBLES,
  TERRAIN_SAND_ROAD,
  TERRAIN_BAKED_CLAY,
  TERRAIN_ASTROTURF,
  TERRAIN_SNOWHALF,
  TERRAIN_SNOWFULL,
  //-------------
  TERRAIN_MAX
} eTerrainType;

// (Type#12) Crash Damage State  (to be used with 'mCrashState')
typedef enum {
  CRASH_DAMAGE_NONE = 0,
  CRASH_DAMAGE_OFFTRACK,
  CRASH_DAMAGE_LARGE_PROP,
  CRASH_DAMAGE_SPINNING,
  CRASH_DAMAGE_ROLLING,
  //-------------
  CRASH_MAX
} eCrashState;

typedef enum {
  JOYPAD_PC_UNUSED1   = (1 <<  0),
  JOYPAD_PC_UNUSED2   = (1 <<  1),
  JOYPAD_PC_UNUSED3   = (1 <<  2),
  JOYPAD_PC_UNUSED4   = (1 <<  3),
  JOYPAD_PC_START     = (1 <<  4),
  JOYPAD_PC_BACK      = (1 <<  5),
  JOYPAD_PC_L3        = (1 <<  6),
  JOYPAD_PC_R3        = (1 <<  7),
  JOYPAD_PC_LB        = (1 <<  8),
  JOYPAD_PC_RB        = (1 <<  9),
  JOYPAD_PC_UNUSED5   = (1 << 10),
  JOYPAD_PC_UNUSED6   = (1 << 11),
  JOYPAD_PC_A         = (1 << 12),
  JOYPAD_PC_B         = (1 << 13),
  JOYPAD_PC_X         = (1 << 14),
  JOYPAD_PC_Y         = (1 << 15)
} eJoyPadPCButtons;

typedef enum {
  JOYPAD_XBOX_UNUSED1  = (1 <<  0),
  JOYPAD_XBOX_UNUSED2  = (1 <<  1),
  JOYPAD_XBOX_UNUSED3  = (1 <<  2),
  JOYPAD_XBOX_UNUSED4  = (1 <<  3),
  JOYPAD_XBOX_START    = (1 <<  4),
  JOYPAD_XBOX_BACK     = (1 <<  5),
  JOYPAD_XBOX_L3       = (1 <<  6),
  JOYPAD_XBOX_R3       = (1 <<  7),
  JOYPAD_XBOX_LB       = (1 <<  8),
  JOYPAD_XBOX_RB       = (1 <<  9),
  JOYPAD_XBOX_UNUSED5  = (1 << 10),
  JOYPAD_XBOX_UNUSED6  = (1 << 11),
  JOYPAD_XBOX_A        = (1 << 12),
  JOYPAD_XBOX_B        = (1 << 13),
  JOYPAD_XBOX_X        = (1 << 14),
  JOYPAD_XBOX_Y        = (1 << 15)
} eJoyPadXBOXButtons;

typedef enum {
  JOYPAD_PS4_UNUSED1   = (1 <<  0),
  JOYPAD_PS4_UNUSED2   = (1 <<  1),
  JOYPAD_PS4_UNUSED3   = (1 <<  2),
  JOYPAD_PS4_UNUSED4   = (1 <<  3),
  JOYPAD_PS4_OPTION    = (1 <<  4),
  JOYPAD_PS4_BACK      = (1 <<  5),
  JOYPAD_PS4_L3        = (1 <<  6),
  JOYPAD_PS4_R3        = (1 <<  7),
  JOYPAD_PS4_LB        = (1 <<  8),
  JOYPAD_PS4_RB        = (1 <<  9),
  JOYPAD_PS4_UNUSED5   = (1 << 10),
  JOYPAD_PS4_UNUSED6   = (1 << 11),
  JOYPAD_PS4_CROSS     = (1 << 12),
  JOYPAD_PS4_CIRCLE    = (1 << 13),
  JOYPAD_PS4_SQUARE    = (1 << 14),
  JOYPAD_PS4_TRIANGLE  = (1 << 15)
} eJoyPadPS4Buttons;

typedef enum {
  DPAD_UP    = (1 << 0),
  DPAD_DOWN  = (1 << 1),
  DPAD_LEFT  = (1 << 2),
  DPAD_RIGHT = (1 << 3),
} eDPadButtons;

// Packet data structure definitions
// ============================================================================
typedef struct {
  u16   sBuildVersionNumber;         // 0
  u8    sPacketType;                 // 2
} sGenericPacket;

typedef struct {
  s16   sWorldPosition[3];           // 0
  u16   sCurrentLapDistance;         // 6
  u8    sRacePosition;               // 8
  u8    sLapsCompleted;              // 9
  u8    sCurrentLap;                 // 10
  u8    sSector;                     // 11
  f32   sLastSectorTime;             // 12
} sParticipantInfo;
#define PARTICIPANT_INFO_SIZE sizeof(sParticipantInfo)

typedef struct {
  u16   sBuildVersionNumber;         // 0
  u8    sPacketType;                 // 2
  char  sCarName[64];                // 3
  char  sCarClassName[64];           // 131
  char  sTrackLocation[64];          // 195
  char  sTrackVariation[64];         // 259
  char  sName[16][64];               // 323
} sParticipantInfoStrings;
#define PARTICIPANT_INFO_STRINGS_SIZE sizeof(sParticipantInfoStrings)

typedef struct {
  u16   sBuildVersionNumber;         // 0
  u8    sPacketType;                 // 2
  u8    sOffset;                     // 3
  char  sName[16][64];               // 4
} sParticipantInfoStringsAdditional;
#define PARTICIPANT_INFO_STRINGS_ADDITIONAL_SIZE sizeof(sParticipantInfoStringsAdditional)

typedef struct {
  u16   sBuildVersionNumber;	        // 0
  u8    sPacketType;                  // 2
  
  // Game states
  u8    sGameSessionState;            // 3

  // Participant info
  s8    sViewedParticipantIndex;      // 4
  s8    sNumParticipants;             // 5

  // Unfiltered input
  u8    sUnfilteredThrottle;          // 6
  u8    sUnfilteredBrake;             // 7
  s8    sUnfilteredSteering;          // 8
  u8    sUnfilteredClutch;            // 9
  u8    sRaceStateFlags;              // 10

  // Event information
  u8    sLapsInEvent;                 // 11

  // Timings
  f32   sBestLapTime;                 // 12
  f32   sLastLapTime;                 // 16
  f32   sCurrentTime;                 // 20
  f32   sSplitTimeAhead;              // 24
  f32   sSplitTimeBehind;             // 28
  f32   sSplitTime;                   // 32
  f32   sEventTimeRemaining;          // 36
  f32   sPersonalFastestLapTime;      // 40
  f32   sWorldFastestLapTime;         // 44
  f32   sCurrentSector1Time;          // 48
  f32   sCurrentSector2Time;          // 52
  f32   sCurrentSector3Time;          // 56
  f32   sFastestSector1Time;          // 60
  f32   sFastestSector2Time;          // 64
  f32   sFastestSector3Time;          // 68
  f32   sPersonalFastestSector1Time;  // 72
  f32   sPersonalFastestSector2Time;  // 76
  f32   sPersonalFastestSector3Time;  // 80
  f32   sWorldFastestSector1Time;     // 84
  f32   sWorldFastestSector2Time;     // 88
  f32   sWorldFastestSector3Time;     // 92

  u16   sJoyPad;                      // 96

  // Flags
  u8    sHighestFlag;                 // 98

  // Pit info
  u8    sPitModeSchedule;             // 99

  // Car state
  s16   sOilTempCelsius;              // 100
  u16   sOilPressureKPa;              // 102
  s16   sWaterTempCelsius;            // 104
  u16   sWaterPressureKpa;            // 106
  u16   sFuelPressureKpa;             // 108
  u8    sCarFlags;                    // 110
  u8    sFuelCapacity;                // 111
  u8    sBrake;                       // 112
  u8    sThrottle;                    // 113
  u8    sClutch;                      // 114
  s8    sSteering;                    // 115
  f32   sFuelLevel;                   // 116
  f32   sSpeed;                       // 120
  u16   sRpm;                         // 124
  u16   sMaxRpm;                      // 126
  u8    sGearNumGears;                // 128
  u8    sBoostAmount;                 // 129
  s8    sEnforcedPitStopLap;          // 130
  u8    sCrashState;                  // 131

  f32   sOdometerKM;                  // 132
  f32   sOrientation[3];              // 136
  f32   sLocalVelocity[3];            // 148
  f32   sWorldVelocity[3];            // 160
  f32   sAngularVelocity[3];          // 172
  f32   sLocalAcceleration[3];        // 184
  f32   sWorldAcceleration[3];        // 196
  f32   sExtentsCentre[3];            // 208

  // Wheels / Tyres
  u8    sTyreFlags[4];                // 220
  u8    sTerrain[4];                  // 224
  f32   sTyreY[4];                    // 228
  f32   sTyreRPS[4];                  // 244
  f32   sTyreSlipSpeed[4];            // 260
  u8    sTyreTemp[4];                 // 276
  u8    sTyreGrip[4];                 // 280
  f32   sTyreHeightAboveGround[4];    // 284
  f32   sTyreLateralStiffness[4];     // 300
  u8    sTyreWear[4];                 // 316
  u8    sBrakeDamage[4];              // 320
  u8    sSuspensionDamage[4];         // 324
  s16   sBrakeTempCelsius[4];         // 328
  u16   sTyreTreadTemp[4];            // 336
  u16   sTyreLayerTemp[4];            // 344
  u16   sTyreCarcassTemp[4];          // 352
  u16   sTyreRimTemp[4];              // 360
  u16   sTyreInternalAirTemp[4];      // 368
  f32   sWheelLocalPositionY[4];      // 376
  f32   sRideHeight[4];               // 392
  f32   sSuspensionTravel[4];         // 408
  f32   sSuspensionVelocity[4];       // 424
  u16   sAirPressure[4];              // 440

  // Extras
  f32   sEngineSpeed;                 // 448
  f32   sEngineTorque;                // 452

  // Car damage
  u8    sAeroDamage;                  // 456
  u8    sEngineDamage;                // 457

  // Weather
  s8    sAmbientTemperature;          // 458
  s8    sTrackTemperature;            // 459
  u8    sRainDensity;                 // 460
  s8    sWindSpeed;                   // 461
  s8    sWindDirectionX;              // 462
  s8    sWindDirectionY;              // 463

  sParticipantInfo sParticipantInfo[56];  // 464
                                      // 56*16=896
  f32   sTrackLength;                 // 1360
  u8    sWings[2];                    // 1364
  u8    sDPad;                        // 1366
  u16   sPadding;                     // 1368	struct is padded to word alignment
} sTelemetryData;
#define TELEMETRY_DATA_SIZE sizeof(sTelemetryData)

struct ACHandshaker{
    int identifier;
    int version;
    int operationId;
};

long UDPRead(int sd, void *packet);
long UDPPeek(int sd);
long UDPWrite(int sd, void *packet, long len, const char *server, int port);

int UDPClient(const char *server, int port);
int UDPSock(in_port_t port);

NSString *getHostAddress();
