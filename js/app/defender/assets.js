/*global _li, PIXI*/

_li.define(
    'defender.assets',
    function (intro) {
        'use strict';

        var init,
            assets;

        assets = [
            // rocks
            'assets/images/rock.png',
            'assets/images/bomb.png',

            // planet
            'assets/images/planet.png',

			// bullet
			'assets/images/bullet.png',

            // spineboy
            'assets/spine/spineboy/spineboy.atlas',
            'assets/spine/spineboy/spineboy.json',
            'assets/spine/spineboy/spineboy.png'
        ];

        init = function () {
            var loader = new PIXI.AssetLoader(assets, false);

            loader.onComplete = intro.call;
            loader.load();
        };

        this.on(init);
    },
    [
        'defender.intro'
    ]
);