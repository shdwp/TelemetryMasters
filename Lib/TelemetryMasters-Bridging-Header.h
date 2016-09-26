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

long UDPRead(int sd, void *packet);
long UDPPeek(int sd);
int UDPSock(in_port_t port);

NSString *getHostAddress();
