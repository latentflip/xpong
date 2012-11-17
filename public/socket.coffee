define ['//'+document.location.hostname+':9990/socket.io/socket.io.js'], (io) ->
  window.socket ||= io.connect('//'+document.location.host)
  return socket
