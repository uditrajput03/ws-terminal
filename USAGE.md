# ws-terminal

It is used to connect to remote terminal using websocket. it is a better alternative method to ssh and do not require any additional software to be installed on the client side.
it do not require port forwarding and can be used in any environment where websocket is supported.
it do not require inbount port to be opened on the server side.
it is outbound based terminal connection.
used when firewall is blocking inbound connections.

improved security, no need to open inbound ports on the server side.

Provider - the machine where the terminal is running.
Consumer - the machine where the terminal is accessed.
Relay Server - an intermediary server that forward messages between provider and consumer.

it support 3 way to connect to remote terminal:
1. create ws server at the provider side and connect to it using ws client at consumer side.
2. reverse shell, where ws client is running on the provider side and connect to ws server at the consumer side.
3. Connection via relay server, where provider and consumer both connect to the relay server and exchange messages through it. 

Requirements:
1. websocat https://github.com/vi/websocat
    Install the latest binary from the releases page.
2. socat
    Install socat using your package manager, e.g., `apt install socat` on Debian/Ubuntu.

3. Relay server (optional) - you can use any websocket relay server, or you can use the one provided in this repository.
    Note:- use only trusted relay server, as it will have access to your terminal commands and output. better to self host relay server.
    Create your own relay server using the following command:
    Or self deploy my Relay server refer to
    https://github.com/uditrajput03/ws-relay


## Usage

Method 1: Create ws server at the provider side and connect to it using ws client at consumer side.

Provider side:
```bash
./websocat -b ws-l\:0.0.0.0\:8000 exec:socat --exec-args - exec:"bash -li",pty,stderr,setsid,sigint,sane
```
Consumer side:
```bash
socat file:`tty`,raw,echo=0 exec:'./websocat --binary "wss://myserver.test:443/" "-"'
```

Method 2: Reverse shell, where ws client is running on the provider side and connect to ws server at the consumer side.

Provider side:
```bash
./websocat_amd64-linux-static -b ws://myserver.test:443 exec:socat --exec-args - exec:"bash -li",pty,stderr,setsid,sigint,sane
```
Consumer side:
```bash
socat file:`tty`,raw,echo=0  exec:'./websocat_amd64-linux-static --binary --exit-on-eof ws-l\:0.0.0.0\:443 -'
```

Method 3: Connection via relay server, where provider and consumer both connect to the relay server and exchange messages through it.

Provider side:
```bash
./websocat -b wss://ws-relay-anlb.onrender.com/terminal1 exec:socat --exec-args - exec:"bash -li",pty,stderr,setsid,sigint,sane
```

Consumer side:
```bash
socat file:`tty`,raw,echo=0 exec:'./websocat --binary "wss://ws-relay-anlb.onrender.com/terminal1" "-"'
```

Create diagram mermaid here 

IF yorr relay serve supports channel like mine does then you can use it to connect to specific channel.

use different socket urls like this:
 https://ws-relay-anlb.onrender.com/terminal1 at provider side for 1st terminal
 https://ws-relay-anlb.onrender.com/terminal2 at provider side for 2nd terminal

 any params can be used to create a channel for different terminal.
 any consumer can connect to the same channel using the same url.
 every consumer will see the same terminal output.