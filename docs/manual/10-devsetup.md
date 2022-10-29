# Installing impulse locally (for development)
Installing impulse locally lets you test out the framework and schema, or develop a new schema. Follow the steps below to install it. When your ready to set it up on a live server, take a look at the [server install guide](https://vingard.github.io/impulsedocs/topics/00-installing.md.html).

## Warning
impulse is a **framework**, a framework is similar to a game engine, if there is an issue with your schema, it is not the frameworks fault. Please consult the developer of the schema for help regarding those issues. impulse was designed to be proprietary software, and as a result has some compatability issues with other admin mods or prop protection systems. This issue is planned to be addressed in future versions of the framework by using CAMI and CPPI.

## Installation
**Step 1** Install [mysqloo](https://github.com/FredyH/MySQLOO/releases) onto your game client.<br/>
**Step 2** Make sure you remove ULX if you have it already, it is not compatible with impulse.<br/>
**Step 3** Install [FPP](https://github.com/FPtje/Falcos-Prop-protection) onto your game client.<br/>
**Step 4** Install [XAMPP](https://www.apachefriends.org/index.html) to your computer, **you will need to select to install Apache and MySQL**. (*advanced users can skip this if they don't want to use XAMPP but you will have to declare database details for your alternative database in data/impulse/config.yml*)<br/>
**Step 5** Make sure you have XAMPP started, and have pressed the start button on MySQL and Apache.<br/>
**Step 6** In XAMPP, click the admin button next to MySQL. Then, in the top left, click the New button and create a database called 'impulse_development'.<br/>
**Step 7** Download the [impulse framework](https://github.com/vingard/impulse) and put it in your gamemodes folder.<br/>
**Step 8** Download your schema of choice and also put it in your gamemodes folder. If you don't have a schema, you can use the [skeleton schema](https://github.com/vingard/impulseskeleton).<br/>
**Step 9** Goto garrysmod/data on your server and create a folder called 'impulse'.<br/>
**Step 10** Inside the impulse folder create a file called config.yml, you can leave it empty.<br/>
**Step 11** Make sure the map you are running has a map config inside the schema, go into the schema gamemode folder, then check schema/config/maps/**MAP NAME HERE**.lua.<br/>
**Step 12** Set your gamemode to the folder name of the schema. You can do this by typing 'gamemode **SCHEMA NAME HERE**' on the menu.<br/>
**Step 13** Start a **peer-to-peer game** confirm if everything is working. If it's not working, check the console for errors and read the message on the in-game error screen.<br/>
**Step 14** Give yourself superadmin, to do this open your console and type 'impulse_setgroup YOUR_STEAMID_HERE superadmin', after you give yourself this, you will probably want to reload your game for the changes to update.<br/>
**Step 15** Your done, remember, whenever you want to start impulse again, just open XAMPP, start MySQL and Apache and set your gamemode to the schema folder name. Then start a peer-to-peer game.<br/>

## Issues with your database connecting
In some cases you may have issues with your database connecting, this can happen when your computer is already using ports needed or your XAMPP config has been altered before. In this case, you'll need to find the details of your XAMPP MySQL server and set them in the config.yml file. By default impulse will use the default XAMPP values, but you can override them as shown below. 
```
db:
 ip: "localhost"
 username: "root"
 password: "secretpass"
 database: "impulse_development"
 port: 3306 
```

## Advanced settings
You can configure your **config.yml** file to do a bunch of helpful things for development.

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

### Seperating databases
If you work on several schemas, you'll probably want to use a different database for each one. Changing the name of the database in config.yml each time you switch is a pain, so, you can just add this to your config.yml file to auto switch depending on the schema you are playing:
```
schemadb:
 impulseskeleton: "impulse_development_skeleton"
 impulseotherschema: "impulse_development_otherone"
```