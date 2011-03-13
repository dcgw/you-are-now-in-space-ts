package net.noiseinstitute.youarenowinspace {
    import net.noiseinstitute.youarenowinspace.behaviours.BrokenFormationBehaviour;
    import net.noiseinstitute.youarenowinspace.entities.Alien;

    public class AlienFormationController {

        private static const ALIENS_HORIZONTAL:uint = 8;
        private static const ALIEN_COLOURS:Vector.<String> = Vector.<String>(
                [Alien.RED, Alien.BROWN, Alien.GREY, Alien.GREEN]);

        private static const LEFT_MARGIN:int = 22;
        private static const BOTTOM_MARGIN:int = 11;
        private static const BREAKAWAY_MARGIN:int = 80;
        private static const MOVE_AMOUNT:Number = 6;

        private var _aliens:Vector.<Vector.<Alien>> = new Vector.<Vector.<Alien>>();

        public function get aliens ():Vector.<Alien> {
            var value:Vector.<Alien> = new Vector.<Alien>();
            for each (var v:Vector.<Alien> in _aliens) {
                value = value.concat(v);
            }
            return value;
        }

        private var soundController:SoundController;

        private var stage:int;
        private var playX:int;
        private var playY:int;
        private var playWidth:int;
        private var playHeight:int;

        private var moveAmount:Number;

        private var time:Number = 0;
        private var moveInterval:Number = 32;
        private var directionLeft:Boolean = true;
        private var moveUp:Boolean = false;
        private var formationSize:Number;
        private var _breakaway:Boolean = false;

        private var separationX:Number = 36;
        private var separationY:Number = 24;

        private var formationX:Number = LEFT_MARGIN;
        private var formationY:Number = BOTTOM_MARGIN;
        private var formationW:Number = separationX * ALIENS_HORIZONTAL - (separationX - Alien.WIDTH);

        public function AlienFormationController (stage:int, x:int, y:int, width:int, height:int) {
            this.stage = stage;
            playX = x;
            playY = y;
            playWidth = width;
            playHeight = height;

            moveAmount = MOVE_AMOUNT+stage*2-1;

            soundController = new SoundController();

            var i:int = 0;
            for each (var colour:String in ALIEN_COLOURS) {
                _aliens[i] = new Vector.<Alien>();
                for (var j:int = 0; j < ALIENS_HORIZONTAL; ++j) {
                    _aliens[i][j] = new Alien(colour);
                    _aliens[i][j].x = playX + j * separationX + LEFT_MARGIN;
                    _aliens[i][j].y = playY + playHeight - _aliens[i][j].height - BOTTOM_MARGIN - i * separationY;
                }
                ++i;
            }
        }

        public function get allDead ():Boolean {
            return formationSize == 0;
        }

        public function get breakaway ():Boolean {
            return _breakaway;
        }

        public function update ():void {
            if (allDead) {
                return;
            }

            // Find where the aliens are and how many
            var leftmost:Number = playX + playWidth;
            var rightmost:Number = playX;
            var upmost:Number = playY + playHeight;
            formationSize = 0;
            var nonBrokenFormationSize:int = 0;

            var alien:Alien;
            for each(alien in aliens) {
                if (!alien.dead) {
                    formationSize++;

                    // If they're in formation
                    if (!alien.behaviour) {
                        nonBrokenFormationSize++;

                        if (alien.x < leftmost) {
                            leftmost = alien.x;
                        }
                        if (alien.x > rightmost) {
                            rightmost = alien.x;
                        }
                        if (alien.y < upmost) {
                            upmost = alien.y;
                        }
                    }
                }
            }

            time++;
            if (time >= moveInterval) {
                time = 0;

                // Update the movement interval
                moveInterval = formationSize;

                // Update the size of the formation
                formationX = leftmost;
                formationY = upmost;
                formationW = rightmost + Alien.WIDTH - formationX;

                // Make a sound
                if (!allDead) {
                    soundController.makeSound();
                }

                // Move the formation
                if (formationX <= playX || formationX >= (playX + playWidth) - formationW) {
                    if (moveUp) {
                        moveUp = false;
                    } else {
                        directionLeft = !directionLeft;
                        moveUp = true;
                    }
                }

                var moveAmtX:Number = moveUp ? 0 : (directionLeft ? -moveAmount : moveAmount);
                var moveAmtY:Number = moveUp ? -moveAmount : 0;

                formationX += moveAmtX;
                formationY += moveAmtY;

                for each(alien in aliens) {
                    if (!alien.dead && !alien.behaviour) {
                        alien.x += moveAmtX;
                        alien.y += moveAmtY;
                    }
                }

                if (upmost <= playY + BREAKAWAY_MARGIN) {
                    _breakaway = true;
                }
            }

            if (_breakaway && nonBrokenFormationSize > 0) {
                var selected:int = Math.floor(Math.random() * nonBrokenFormationSize);

                var i:int = 0;
                for each(alien in aliens) {
                    if (!alien.dead && !alien.behaviour) {
                        if (i == selected) {
                            alien.behaviour = new BrokenFormationBehaviour(alien);
                            break;
                        }
                        ++i;
                    }
                }
            }
        }
    }
}
