---
title: What is the event sourcing pattern?
permalink: /:title:output_ext
description: "Event sourcing consists in storing all changes that happened to the application state as a sequence of events instead of only storing the current state of the application. The sum of all events makes  the current application state."
layout: post
date: 2022-11-28
image: what-is-the-event-sourcing-pattern.webp
image_alt: What is the event sourcing pattern?
image_credit: vitsinkevich
keywords: "software,software architecture,design patterns,es,event sourcing,table soccer"
tags: [software-architecture, design-patterns]
---

Event sourcing consists in storing all changes that happened to an application as a sequence of events instead of only storing the current state of the application. The sum of all events is the current application state. When I heard about this pattern a few years ago, I was really confused. I used to only persist the current application state in a database and that was fine! So I asked myself do I need that?

I will show you an example to help you understand what this pattern stands for. People used to explain it with a bank account but I wanted to find something funnier: a table soccer game. A complete example is available on a [Github repository](https://github.com/arnolanglade/table-soccer).

Let’s start! A group of developers who are fans of table soccer wants to create an application to see who’s the best player. They decided to save the results of matches and rank themselves.

```ts
export class Game {
    constructor(
        private redTeam: Team,
        private blueTeam: Team,
        private gameScore: Score,
    ) {}

    public recordScore(redPlayerScore: number, bluePlayerScore: number) {
        return new Game(
            this.redTeam,
            this.blueTeam,
            new Score(redPlayerScore, bluePlayerScore),
        );
    }

    // example: ['arn0', 'momos', 'Popeye', 'coco', 10, 1]
    public toState(): [string, string, string, string, number, number] {
        return [
            ...this.redTeam.toState(),
            ...this.blueTeam.toState(),
            ...this.gameScore.toState()
        ];
    }
}
```

The `Game` Aggregate has a `recordScore` method to record the score at the end of the game. Then we get the current state of `Game` with the `toState` method to save it in the database.

That works perfectly for the one versus one games but what happens for two versus two games? Let’s focus on one of the players, we will call him Popeye. Actually, Popeye is not a really good player even if he is full of goodwill. He is smart, he always wants to play with the best player to have more chances to win. We cannot know who is the best player with only the result of the game. Who has really scored? Popeye or its teammate?

Event sourcing is the solution. Instead of saving the score of the game, we will store what really happens. We will refactor the `Game` aggregate to make it compliant with the event sourcing pattern.

First, we will rework the aggregate construction. We still want to encapsulate its current state but we want to record all events that happened too. In the following example, we added an `events` argument to the primary constructor and a named constructor (secondary construct) called `start` to the `Game` class. From a business point of view, its goal is to initialize the game and from a technical point of view, it lets us record the `GameStarted` event.

```ts
export class Game {
    constructor(
        private redTeam: Team,
        private blueTeam: Team,
        private gameScore: Score,
        private events: Event[] = []
    ) {}
    
    public static start(
        redAttacker: Player,
        redDefender: Player,
        blueAttacker: Player,
        blueDefender: Player
    ): Game {
        const redTeam = Team.ofTwoPlayer(redAttacker, redDefender);
        const blueTeam = Team.ofTwoPlayer(blueAttacker, blueDefender);

        return new Game(
            redTeam,
            blueTeam,
            Score.playersHaveNotScored(),
            [new GameStarted(redTeam, blueTeam)],
        );
    }
}
```

Then we will add a new method to `Game` to record all goals scored by any players. That will let us know who is the best striker in the game. In the following example, we record two events: `GoalScored` and `GameEnded`. The first one is recorded every time a player scores and the second one is recorded when the first team has 10 points meaning the game is over.

```ts
export class Game { 
   // …
   public goalScoredBy(player: Player): Game {
        const teamColor = this.redTeam.isTeammate(player) ? TeamColor.Red : TeamColor.Blue;
        const gameScore = this.gameScore.increase(teamColor);

        this.events.push(new GoalScored(teamColor, player, gameScore))

        if (!gameScore.canIncrease(teamColor)) {
            this.events.push(new GameEnded(this.redTeam, this.blueTeam, gameScore))
        }

        return new Game(
            this.redTeam,
            this.blueTeam,
            gameScore,
            this.events,
        );
    }
    // …
}
```

**Note:** We can drop the `recordScore` method because we won’t want to only record the score of the game at the end of the game.

Finally, the last thing to refactor is the persistence mechanism. We need to rework the `toState` because we won’t store a snapshot of the `Game` state but we want to save all events raised during the game. This method will return all serialized events and metadata like the name of the aggregate. Normally, we should persist some extra metadata like the aggregate id or the date when the event has been raised. Then, those data will be used in the `Game` repository to persist changes in the database.

```ts
export class Game { 
    // …
    public toState(): [[string, string]] {
        return this.events.map((event: Event) => ['Game', event.toState()]);
    }
    // …
}
```

Last thing, we will add a named constructor to be able to build the object from the persisted state (a list of events). The `fromEvents` will iterate on all events to compute and set the current state of a game.

```ts
export class Game { 
    // …
    public static fromEvents(events: Event[]): Game {
        let redTeam, blueTeam, score;
        events.forEach((event: Event) => {
            switch (true) {
                case event instanceof GameStarted:
                    redTeam = event.redTeam;
                    blueTeam = event.blueTeam;
                    break;
                case event instanceof GameEnded:
                    score = event.score;
                    break;
            }

        });

        return new Game(redTeam, blueTeam, score, events);
    }
    // …
}
```

Now, we have all the data we need to know if Popeye really helps his teammate. In the following code example, we can see that Momos and arn0 were not in a good shape. Coco and Popeye won easily but we can see that Popeye did not score. Perhaps, he is a good defender, who knows?

```ts
let game = Game.startTwoVersusTwo('arn0', 'momos', 'Popeye', 'coco')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('momos')
game = game.goalScoredBy('arn0')
game = game.goalScoredBy('arn0')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('momos')
game = game.goalScoredBy('momos')
game = game.goalScoredBy('arn0')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('coco')
game = game.goalScoredBy('coco')
```

I explained to you how to save `Game` aggregate events and create the aggregate from events in the previous sections of the blog post. The last missing feature is the leaderboard! How to create it? It won’t be as simple as querying a SQL table in the database because we need to get all game events for each game and compute them to know who is the better striker. Even though it can be fast in the beginning, the more games you have, the longer it will be.

To prevent this problem, we need to create data projections. That means we will compute a representation of the data we want to query from the event stream. We will compute the new projection of the leaderboard each time a game ends.

Last but not least, We often associate CQRS with the event sourcing pattern even if there are two different patterns.

Don’t forget that a complete example is available on a [Github repository](https://github.com/arnolanglade/table-soccer).

Any resemblance to real and actual names is purely coincidental!

Thanks to my proofreader [@LaureBrosseau](https://twitter.com/LaureBrosseau).
