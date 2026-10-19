<div align="center">

# Termux:API skill

**Your phone's cameras, location and sensors, in reach of an agent that knows where termux-api fails silently**

[![Agent Skill](https://img.shields.io/badge/Agent_Skill-6E56CF?style=flat)](https://agentskills.io)
![Termux](https://img.shields.io/badge/Termux-000000?style=flat&logo=android&logoColor=white)
[![license](https://img.shields.io/badge/MIT-3DA639?style=flat)](LICENSE)
[![ci](https://github.com/rokokol/termux-api-skill/actions/workflows/build.yml/badge.svg)](https://github.com/rokokol/termux-api-skill/actions/workflows/build.yml)

</div>

Lets an agent use an Android phone through the [termux-api](https://wiki.termux.com/wiki/Termux:API) commands: take a photo with either camera, find where the phone is, read its battery, look at recent calls and messages, show a line on its screen, vibrate it or light the torch

The commands have their own help. This skill carries what the help leaves out: the calls that hang or exit 0 without an effect, what a Termux shell cannot do on Android, and recipes measured on a real phone

## Requirements

- An Android phone with [Termux](https://termux.dev), the Termux:API app and the `termux-api` package, and the permissions each command needs granted to Termux:API
- For an agent on another machine, an ssh host for the phone, named in the agent's instructions or memory

## Install

Clone the repository into the skills directory of your agent, for example:

```sh
git clone https://github.com/rokokol/termux-api-skill ~/.claude/skills/termux-api
```

## Usage

Ask the agent for something only the phone can do: "сфоткай с фронталки", "where is my phone", "сколько заряда на телефоне"
