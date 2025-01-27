#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>

#define PORT "7777" 

#define BACKLOG 10 

void vulnerable(char *net_buffer)
{
char local_buffer[200];
strcpy(local_buffer, net_buffer);
return;
}

void sigchld_handler(int s)
{
while(waitpid(-1, NULL, WNOHANG) > 0);
}

void *get_in_addr(struct sockaddr *sa)
{
if (sa->sa_family == AF_INET) {
return &(((struct sockaddr_in*)sa)->sin_addr);
}

return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int main(void)
{
int sockfd, new_fd; 
struct addrinfo hints, *servinfo, *p;
struct sockaddr_storage their_addr; 
socklen_t sin_size;
struct sigaction sa;
int yes=1;
char in_buffer[20], out_buffer[20], net_buffer[2048];
char s[INET6_ADDRSTRLEN];
int rv;

memset(&hints, 0, sizeof hints);
hints.ai_family = AF_UNSPEC;
hints.ai_socktype = SOCK_STREAM;
hints.ai_flags = AI_PASSIVE; 

if ((rv = getaddrinfo(NULL, PORT, &hints, &servinfo)) != 0) {
fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
return 1;
}

for(p = servinfo; p != NULL; p = p->ai_next) {
if ((sockfd = socket(p->ai_family, p->ai_socktype,
p->ai_protocol)) == -1) {
perror("server: socket");
continue;
}

if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
sizeof(int)) == -1) {
perror("setsockopt");
exit(1);
}

if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
close(sockfd);
perror("server: bind");
continue;
}

break;
}

if (p == NULL) {
fprintf(stderr, "server: failed to bind\n");
return 2;
}

freeaddrinfo(servinfo); 

if (listen(sockfd, BACKLOG) == -1) {
perror("listen");
exit(1);
}

sa.sa_handler = sigchld_handler; 
sigemptyset(&sa.sa_mask);
sa.sa_flags = SA_RESTART;
if (sigaction(SIGCHLD, &sa, NULL) == -1) {
perror("sigaction");
exit(1);
}

printf("server: Á espera de conexões...\n");

while(1) { 
sin_size = sizeof their_addr;
new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);
if (new_fd == -1) {
perror("accept");
continue;
}

inet_ntop(their_addr.ss_family,
get_in_addr((struct sockaddr *)&their_addr),
s, sizeof s);
printf("server: COnectado a %s\n", s);

if (!fork()) { 
close(sockfd); 
memset(net_buffer, 0, 1024);
strcpy(out_buffer, "Ola\nComando:");
if (send(new_fd, out_buffer, strlen(out_buffer), 0) == -1)
perror("send");
if (recv(new_fd, net_buffer, 1024, 0))
{
vulnerable(net_buffer);
strcpy(out_buffer, "RECEBIDO: ");
strcat(out_buffer, net_buffer);
send(new_fd, out_buffer, strlen(out_buffer), 0);
}
close(new_fd);
exit(0);
}
close(new_fd); 
}

return 0;
}
