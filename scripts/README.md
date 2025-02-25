# Cluster Scripts

This repository contains a collection of utility scripts designed to simplify managing your Kubernetes cluster.

## Installation

To get started, clone the repository and give executable permissions to the scripts:

```bash
git clone https://github.com/xstar97/cluster-scripts ./scripts
```

## Set Up Aliases

You can create alias commands for the available utility scripts by running:

```bash
./scripts/utils.sh gen_alias
```

To specify a custom configuration file for aliases, use:

```bash
./scripts/utils.sh gen_alias --config /path/to/aliases.yaml
```

Short alias command variants are also available:

```bash
genAlias
```

```bash
genAlias --config /path/to/aliases.yaml
```

## Updating Scripts

To ensure your scripts are up-to-date, use the following command to pull the latest changes:

```bash
updateScripts
```

## Usage

To view the available commands and get detailed usage information, run:

```bash
utils
```

The `-h` flag provides a description of each function along with example usage. Here are the available functions:

## Contributing

Feel free to contribute by submitting issues and pull requests. For major changes, please open an issue first to discuss what you would like to change.