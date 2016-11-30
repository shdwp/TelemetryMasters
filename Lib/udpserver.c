//
//  udpserver.c
//  TelemetryMasters
//
//  Created by shdwprince on 9/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#include "udpserver.h"

#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

/* this routine echos any messages (UDP datagrams) received */

#define MAXBUF 512

long UDPRead(int sd, void *packet) {
    struct sockaddr_in remote;
    unsigned int len = sizeof(remote);
    long n = 0;

    n = recvfrom(sd, packet, MAXBUF, 0, (struct sockaddr *) &remote, &len);
    return n;
}

long UDPPeek(int sd) {
    char buf[MAXBUF];
    return UDPRead(sd, &buf);
}

/* server main routine */

int UDPSock(in_port_t port) {
    int ld;
    struct sockaddr_in skaddr;
    unsigned int length;

    if ((ld = socket( PF_INET, SOCK_DGRAM, 0 )) < 0) {
        printf("Problem creating socket\n");
        return -1;
    }

    skaddr.sin_family = AF_INET;
    skaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    skaddr.sin_port = htons(port);

    if (bind(ld, (struct sockaddr *) &skaddr, sizeof(skaddr))<0) {
        printf("Problem binding\n");
        return -1;
    }

    /* find out what port we were assigned and print it out */

    length = sizeof( skaddr );
    if (getsockname(ld, (struct sockaddr *) &skaddr, &length)<0) {
        printf("Error getsockname\n");
        return -1;
    }

    /* port number's are network byte order, we have to convert to
     host byte order before printing !
     */
    printf("The server UDP port number is %d\n",ntohs(skaddr.sin_port));
    
    /* Go echo every datagram we get */
    return ld;
}
