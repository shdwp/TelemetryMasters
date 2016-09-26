//
//  udpserver.h
//  TelemetryMasters
//
//  Created by shdwprince on 9/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#ifndef udpserver_h
#define udpserver_h

#include <stdio.h>
#include <sys/socket.h>

long UDPRead(int sd, void *packet);
long UDPPeek(int sd);
int UDPSock(in_port_t port);

#endif /* udpserver_h */
