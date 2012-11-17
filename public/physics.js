// Generated by CoffeeScript 1.3.3
(function() {

  define(['./vector'], function(Vector) {
    var Physics, config;
    config = {
      width: 500,
      height: 500
    };
    return Physics = {
      collideBallWithLine: function(ball, line) {
        var collisionLine, normal;
        collisionLine = line.perpendicularJoining(ball.position);
        normal = Vector.scale(-1, Vector.normalize(Vector.subtract(collisionLine.to, collisionLine.from)));
        if (ball.radius >= collisionLine.length()) {
          line.onCollision();
          return ball.velocity = Vector.reflect(ball.velocity, normal);
        }
      },
      collideBallWithPlayer: function(ball, player) {
        var normal, overlapDistance, overlapVector, radiusSum;
        if (player.nextHit > 0) {
          return;
        }
        overlapVector = Vector.subtract(player.position, ball.position);
        radiusSum = ball.radius + player.radius;
        overlapDistance = Vector.length(overlapVector) - radiusSum;
        if (overlapDistance <= 0) {
          normal = Vector.normalize(overlapVector);
          player.onCollision();
          ball.velocity = Vector.reflect(ball.velocity, normal);
          ball.velocity = Vector.subtract(ball.velocity, player.velocity);
          return ball.position = Vector.add(ball.position, Vector.scale(overlapDistance, normal));
        }
      },
      collideBallWithEdges: function(ball) {
        var r, x, y;
        x = ball.position[0];
        y = ball.position[1];
        r = ball.radius;
        if (x <= r) {
          return ball.velocity = Vector.reflect(ball.velocity, [1, 0]);
        } else if (x >= config.width - ball.radius) {
          return ball.velocity = Vector.reflect(ball.velocity, [-1, 0]);
        } else if (y <= r) {
          return ball.velocity = Vector.reflect(ball.velocity, [0, 1]);
        } else if (y >= config.height - ball.radius) {
          return ball.velocity = Vector.reflect(ball.velocity, [0, -1]);
        }
      }
    };
  });

}).call(this);