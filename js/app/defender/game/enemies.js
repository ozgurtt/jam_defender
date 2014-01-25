/*global _li*/

_li.define(
    'defender.game.enemies',
    function (texture, camera) {
        'use strict';

        var init,
            actions,
            fall,
            enemies = [],
            options = {
                y: 0,
                asset: 'assets/images/bunny.png',
                relative: true,
                radius: 400
            };

        init = function (data) {
            options.container = camera.call();
            options.x = data.distance;
            options.rotation = data.rotation;

            actions[data.action](data);

            return enemies;
        };

        actions = {
            add: function (data) {
                var number = data.number,
                    i = 0;

                for (i; i < number; i += 1) {
                    var enemy = texture.call(options);

                    enemy.fall = fall.bind(enemy);
                    enemies.push(enemy);
                }
            }
        };

        fall = function (velocity, planet, index) {
            this.position.y += velocity * Math.cos(this.rotation);
            this.position.x -= velocity * Math.sin(this.rotation);

            if (this.pivot.y - Math.sqrt(this.position.y * this.position.y + this.position.x * this.position.x) < planet.radius + this.height / 2) {
                planet.parent.removeChild(this);
                enemies.splice(index, 1);
            }
        };

        this.on(init);
    },
    [
        'defender.renderer.texture',
        'defender.game.camera'
    ]
);