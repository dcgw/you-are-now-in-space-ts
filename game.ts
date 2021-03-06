import {Dictionary} from "dictionary-types";
import {
    CollisionGroupManager,
    CollisionResolutionStrategy,
    DisplayMode,
    Engine,
    Physics,
    Sound, Texture
} from "excalibur";
import Preloader from "./preloader";
import resources from "./resources";
import GetReady from "./scenes/get-ready/get-ready";
import Intermission from "./scenes/intermission/intermission";
import Level1 from "./scenes/level-1/level-1";
import Level3 from "./scenes/level-3/level-3";
import Title from "./scenes/title/title";

export default class Game {
    public readonly width = 384;
    public readonly height = 288;

    public readonly playWidth = 320;
    public readonly playHeight = 200;

    public readonly playLeft = (this.width - this.playWidth) * 0.5;
    public readonly playTop = (this.height - this.playHeight) * 0.5;

    public readonly collisionGroups = {
        player: CollisionGroupManager.create("player"),
        aliens: CollisionGroupManager.create("aliens")
    };

    public active = false;
    public lives = 4;
    public stage = 1;
    public score = 0;

    public readonly engine = new Engine({
        viewport: {width: this.width, height: this.height},
        resolution: {width: this.width, height: this.height},
        displayMode: DisplayMode.Fixed,
        antialiasing: false,
        suppressHiDPIScaling: true,
        suppressPlayButton: true
    });

    public start(): void {
        const loader = new Preloader();
        for (const key of Object.keys(resources)) {
            const resource = (resources as Dictionary<Texture | Sound>)[key];
            resource.bustCache = false;
            loader.addResource(resource);
        }

        this.engine.input.pointers.primary.on("up", this.onClick);
        this.engine.input.keyboard.on("press", this.onClick);

        Physics.collisionResolutionStrategy = CollisionResolutionStrategy.Box;

        this.reset();

        this.engine.start(loader)
            .then(() => {
                this.engine.add("title", new Title(this));
                this.engine.add("get-ready", new GetReady(this));
                this.engine.add("intermission", new Intermission(this));
                this.engine.add("level-1", new Level1(this));
                this.engine.add("level-3", new Level3(this));
                this.engine.goToScene("title");
            }, reason => console.error("", reason));
    }

    public reset(): void {
        this.lives = 4;
        this.stage = 1;
        this.score = 0;
    }

    private readonly onClick = () => {
        this.engine.canvas.focus();
    }
}