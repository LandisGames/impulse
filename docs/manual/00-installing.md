# Installing impulse on a server
This guide will show you how to install impulse, on a server. Before we start, it should be understood impulse is made to be developed in a locally hosted peer-to-peer server, and it is made to be ran in production on a game server. To learn how to setup impulse, for development on your local machine, take a look at [the dev setup guide](https://vingard.github.io/impulsedocs/topics/10-devsetup.md.html).

## Warning
impulse is a **framework**, a framework is similar to a game engine, if there is an issue with your schema, it is not the frameworks fault. Please consult the developer of the schema for help regarding those issues. impulse was designed to be proprietary software, and as a result has some compatability issues with other admin mods or prop protection systems. This issue is planned to be addressed in future versions of the framework by using CAMI and CPPI.

## Installation
**Step 1** Install [mysqloo](https://github.com/FredyH/MySQLOO/releases) onto your server.<br/>
**Step 2** Make sure you remove ULX if you have it already, it is not compatible with impulse.<br/>
**Step 3** Install [FPP](https://github.com/FPtje/Falcos-Prop-protection) onto your server.<br/>
**Step 4** Turn off MySQL strict mode on your MySQL database.<br/>
**Step 5** Download the [impulse framework](https://github.com/vingard/impulse) and put it in your gamemodes folder.<br/>
**Step 6** Download your schema of choice and also put it in your gamemodes folder. If you don't have a schema, you can use the [skeleton schema](https://github.com/vingard/impulseskeleton).<br/>
**Step 7** (*not required, but reccomended*) Install and setup [GExtension](https://www.gmodstore.com/market/view/2899).<br/>
**Step 8** Goto garrysmod/data on your server and create a folder called 'impulse'.<br/>
**Step 9** Inside the impulse folder create a file called config.yml and paste in the config below:<br/>

```
db:
 ip: "mysql server ip here"
 username: "db username"
 password: "db pass"
 database: "db name"
 port: 3306
```

**Step 10** Replace the values in the config.yml file with those of your database.<br/>
**Step 11** Make sure the map you are running has a map config inside the schema, go into the schema gamemode folder, then check schema/config/maps/**MAP NAME HERE**.lua.<br/>
**Step 12** Set the gamemode of your server to the folder name of the schema.<br/>
**Step 13** That's it. Join the server to confirm if everything is working. If it's not working, check the console for errors and read the message on the in-game error screen.<br/>
**Step 14** *You probably will want to edit some of the schema config. In your schema folder, navigate to config/sh_config.lua to configure your server.*<br/>

## Extra setup
Here's some extra setup you can do to get access to extra features.

### API features
If you want anti-family sharing features and slack logging, you'll need to provide your Steam API key and a Slack webhook URL. Just add this to the config.yml file:
```
apis:
 steam_key: "XXXXXXXXXXXXXXXXXXXXXXX"
 slack_webhook: "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"
```

### Signals
Signals is a system in impulse that allows for simple cross-server communication. You'll need to create a signals database first. Then, add the stuff below, and configure it for your config.yml:
```
signals:
 serverid: 1
 ip: "127.0.0.1"
 username: "root"
 password: ""
 database: "impulse_development_signals"
 port: 3306
```
Remember to make your serverid unique, each server on the same signals database needs a new serverid, for example, server 1 has an serverid of 1, 2 has serverid of 2, ect.