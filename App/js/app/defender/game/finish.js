/*global _li*/

_li.define(
	'defender.game.finish',
	function (texture) {
		'use strict';

		var init,
			intro;

		init = function () {
			var options = {
				radius: 400,
				x: window.innerWidth / 2,
				y: window.innerHeight / 2,
				at: 0,
				asset: 'assets/images/gameover.png'
			};

			if (!intro) {
				intro = texture.call(options);
			}

			return intro;
		};

		this.on(init);
	},
	[
		'defender.renderer.texture'
	]
);