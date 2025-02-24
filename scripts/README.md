# Cluster Scripts

This repository contains a set of utility scripts for managing and configuring your cluster. The scripts can be easily cloned and set up on your system.

## Installation

To get started, clone the repository and set executable permissions:

```bash
git clone https://github.com/xstar97/cluster-scripts ./scripts
```

```
chmod -R +x scripts/
```

## Set Up Aliases

To create alias commands for the available utility scripts, run the following command:

```bash
./scripts/utils.sh gen_alias
```

```bash
./scripts/utils.sh gen_alias --config /path/to/aliases.yaml
```

## Usage

To view the available commands and get more information on how to use them, run:

```bash
utils
```

### dns

get cluster urls for a chart.

```bash
utils dns plex
```
outputs:

```yaml
plex:
  plex.plex.svc.cluster.local:32400 | TCP
```

## Updating Scripts

To keep your scripts up to date, run the following command to pull the latest changes using this alias command:

```bash
update-scripts
```
