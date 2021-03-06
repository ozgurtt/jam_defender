/*global _li*/

_li.define(
    'defender.game.weapon',
    function (texture, camera, player) {
        'use strict';

        var init,
            options,
            fire,
            _weapons = [];

        options = {
            asset: 'assets/images/bullet.png',
            x: 80,
            y: 0,
            radius: 400,
            relative: true,
            at: 2
        };

        init = function (getWeapons) {
            var weapon,
                _camera = camera.call(),
                _player = player.call();

            if (getWeapons) {
                return _weapons;
            } else {
                options.container = _camera;
                options.rotation = -_camera.rotation;
                weapon = texture.call(options);
                weapon.fire = fire.bind(weapon);
                _weapons.push(weapon);
                if (_player.state.current.name !== 'move') {
                    _player.state.setAnimationByName('fire', false);
                }
                return false;
            }

        };

        fire = function (velocity) {
            this.position.y -= velocity * Math.cos(this.rotation);
            this.position.x += velocity * Math.sin(this.rotation);
        };

        this.on(init);
    },
    [
        'defender.renderer.texture',
        'defender.game.camera',
        'defender.game.player'
    ]
);