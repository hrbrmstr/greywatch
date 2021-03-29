//
//  inet.c
//  greywatch
//
//  Created by boB Rudis on 3/29/21.
//

#include "inet.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <sys/socketvar.h>
#include <net/route.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/in_pcb.h>
#include <netinet/tcp.h>
#include <netinet/tcp_fsm.h>
#include <netinet/tcp_timer.h>
#include <netinet/tcp_var.h>
#include <arpa/inet.h>

#define SYSCTL_TCP_CONNS "net.inet.tcp.pcblist64"

#import <Foundation/Foundation.h>

NSArray *read_tcp_stat(void) {
  
  char *sysctl_buf;
  size_t len = 0;
  struct xinpgen *xip;
  struct xtcpcb64 *tcpcb;
  struct xinpcb64 *inpcb;
  struct xsocket64 *sock;
  struct sockaddr_storage local;
  struct sockaddr_storage remote;
  struct sockaddr_in *sin;
  int ret;
  bool found_connection;

  NSMutableArray *addresses = [ [NSMutableArray alloc] initWithCapacity: 32 ]; // should be sufficient for regular desktops
  
  ret = sysctlbyname(SYSCTL_TCP_CONNS, NULL, &len, NULL, 0);
  if (ret < 0) return addresses; // -1;
  
  sysctl_buf = malloc( len * sizeof(char));
  
  ret = sysctlbyname(SYSCTL_TCP_CONNS, sysctl_buf, &len, NULL, 0);
  
  if (ret < 0) {
    free(sysctl_buf);
    goto theend; //    return addresses; // -1;
  }
  
  if (len < sizeof(struct xinpgen)) {
    free(sysctl_buf);
    goto theend; // return addresses; // -1;
  }
  
  xip = (struct xinpgen *)sysctl_buf;
  for (xip = (struct xinpgen *)((char *)xip + xip->xig_len);
       xip->xig_len > sizeof(struct xinpgen);
       xip = (struct xinpgen *)((char *)xip + xip->xig_len)) {
    
    found_connection = false;
    tcpcb = (struct xtcpcb64 *)xip;
    inpcb = &tcpcb->xt_inpcb;
    sock = &inpcb->xi_socket;
    
    if (sock->xso_protocol != 6 ) continue;
    
    if (inpcb->inp_vflag & INP_IPV4 ) {
      
      sin = (struct sockaddr_in *)&local;
      sin->sin_family = AF_INET;
      memcpy(&sin->sin_addr, &inpcb->inp_laddr, sizeof(struct in_addr));
      sin->sin_port = inpcb->inp_lport;
      
      sin = (struct sockaddr_in *)&remote;
      sin->sin_family = AF_INET;
      memcpy(&sin->sin_addr, &inpcb->inp_faddr, sizeof(struct in_addr));
      sin->sin_port = inpcb->inp_fport;
      found_connection = true;
      
    } else {
      continue;
    }
    
    if (found_connection) {
//      printf("Got connection ");
      struct sockaddr_in *sin = (struct sockaddr_in *)&remote;
      unsigned char *ip = (unsigned char *)&sin->sin_addr.s_addr;
      char buf[32]; // overkill
      snprintf(buf, sizeof(buf), "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
//      printf("%s\n", buf);
      [ addresses addObject: [ NSString stringWithUTF8String: buf ] ];
    }
    
  }
  
  free(sysctl_buf);
  
theend:
  return addresses;
}
