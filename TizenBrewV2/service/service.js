"use strict";
// TizenBrew Standalone Service
// I wish I've seen running Node.JS on Tizen way before...

module.exports.onStart = function () {
    console.log('Service started.');
    const adbhost = require('adbhost');
    const WebSocket = require('ws');
    const startDebugging = require('./debugger.js');
    const loadModules = require('./moduleLoader.js');
    const server = new WebSocket.Server({ port: 8081 });

    let adb;
    global.inDebug = false;

    function createAdbConnection(isTizen3, ip) {
        if (adb) {
            if (adb._stream !== null || adb._stream !== undefined) {
                adb._stream.removeAllListeners('connect');
                adb._stream.removeAllListeners('error');
                adb._stream.removeAllListeners('close');
            }
        }

        adb = adbhost.createConnection({ host: '127.0.0.1', port: 26101 });

        adb._stream.on('connect', () => {
            console.log('ADB connection established');
            //Launch app
            const shellCmd = adb.createStream(`shell:0 debug xvvl3S1bvH.TizenBrewStandalone${isTizen3 ? ' 0' : ''}`);
            shellCmd.on('data', function dataIncoming(data) {
                const dataString = data.toString();
                if (dataString.includes('debug')) {
                    const port = dataString.substr(dataString.indexOf(':') + 1, 6).replace(' ', '');
                    startDebugging(port, adb, ip);
                }
            });
        });

        adb._stream.on('error', () => {
            console.log('ADB connection error.');
        });
        adb._stream.on('close', () => {
            console.log('ADB connection closed.');
        });

    }

    server.on('connection', (ws) => {
        ws.on('message', (msg) => {
            let message;
            try {
                message = JSON.parse(msg);
            } catch (e) {
                return ws.send(JSON.stringify({ type: 'error', message: 'Invalid JSON.' }));
            }

            switch (message.type) {
                case 'getDebugStatus': {
                    ws.send(JSON.stringify({ type: 'debugStatus', inDebug: global.inDebug }));
                    break;
                }
                case 'relaunchInDebug': {
                    createAdbConnection(message.isTizen3, message.tvIp);
                    break;
                }
                case 'loadModules': {
                    loadModules(message.modules).then(modules => {
                        ws.send(JSON.stringify({ type: 'modules', modules }));
                    });
                    break;
                }
                case 'launch': {
                    loadModules([message.packageName]).then(modules => {
                        const module =  modules.find(m => m.name === message.packageName);
                        if (!module) {
                            ws.send(JSON.stringify({ type: 'error', message: 'Module not found.' }));
                            return;
                        }
                        if (module.packageType === 'mods') {
                            global.currentModule = {
                                type: 'mods',
                                path: `https://cdn.jsdelivr.net/npm/${module.name}/${module.mainFile}`
                            }
                        } else {
                            global.currentModule = {
                                type: 'app',
                                path: `https://cdn.jsdelivr.net/npm/${module.name}/${module.appPath}`
                            }
                        }
                    });
                    break;
                }
                default: {
                    ws.send(JSON.stringify({ type: 'error', message: 'Invalid message type.' }));
                    break;
                }
            }
        });
    });
}

module.exports.onStart();