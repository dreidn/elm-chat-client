const WebSocket = require('ws');
const _ = require('lodash');

const wss = new WebSocket.Server({
    port: 3000,
});

const connections = [];

let chat = {
    logDelta: [],
    log: [],
    users: []
}

const doAction = payload => {
    switch(payload.action){
        case 'NewUser':
            return {...chat, users: chat.users.push(payload.user)}
        case 'NewMessage':
            return {
                ...chat,
                log: chat.log.push(payload.message),
                logDelta:[payload.message]
            }
    }
}

const propagate = data => {
    connections.forEach(ws => {
        ws.send({update:data})
    });
}

wss.on('connection', (ws) => {
    console.log("connection");
    ws.on('message', (message) => {
        console.log('receieved: %s', message);
        let payload;
        try{
            payload = JSON.stringify(message);
        }catch(e){
            payload = {};
        }
        chat = doAction(payload);
        propagate(chat.logDelta);
    });
    setInterval(() => {
        ws.send('hello');
    }, 1000);
});