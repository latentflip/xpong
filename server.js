var express = require('express')
  , app = express()
  , http = require('http')
  , server = http.createServer(app)
  , io = require('socket.io').listen(server)
  , port = process.argv[2] || '9990'
  , fs = require('fs')
  , exec = require('child_process').exec
  ;
  
app.use('/public', express.static(__dirname+'/public'))
app.use('/jam', express.static(__dirname+'/jam'))

server.listen(port)

statics = [
  ['', 'index.html'],
  ['remote','remote.html']
];


statics.forEach(function(p) { 
  var path, url;
  if (p.toString() === p) {
    path = url = '/'+p;
  } else {
    url = '/'+p[0];
    path = '/'+p[1];
  }
  app.get(url, function(req, res) {
    res.sendfile(__dirname + path);
  });
});


var players = [];
var gamespace;
var playerId = 0;

registerPlayer = function() {
  playerId++
  if(gamespace) {
    gamespace.emit('player:new', playerId);
  } else {
    players.push(playerId);
  }
  return playerId
}

io.sockets.on('connection', function (socket) {
  socket.on('gamespace:register', function(data) {
    gamespace = socket;
    gamespace.emit('gamespace:register:ack')
    players.forEach(function(playerId) {
      gamespace.emit('player:new', playerId);
    });
  });

  socket.on('player:register', function(data) {
    var id = registerPlayer();
    socket.on('move', function(pos) {
      if (gamespace) { 
        gamespace.emit('player:'+id+':move', pos);
      }
    });
  });
});
