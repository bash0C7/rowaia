# Rowaia

Rowaia (ロワイア) is an AI agent for remote office workers, designed to streamline information processing. The name combines "Remote Work + AI + Assistant".

## Overview

This system uses the "OODA loop" (Observe-Orient-Decide-Act) as its basic structure, with Fluentd as the core information stream processing engine. The system operates completely offline for privacy protection.

## Architecture

Rowaia consists of two main Fluentd processes:

1. **Observe-Orient Process**: Collects information from various sources and analyzes it using local LLM
2. **Decide-Act Process**: Prioritizes the analyzed information and presents notifications with action suggestions

## Requirements

- Ruby 3.4.1 or higher
- Fluentd 1.12 or higher
- [Ollama](https://ollama.ai/) for local LLM execution
- A desktop assistant supporting SSTP (like SSP)

## Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/rowaia.git
cd rowaia
```

Install dependencies:

```bash
bundle install
```

Install Ollama and download the required model:

```bash
# Install Ollama from https://ollama.ai/
ollama pull hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest
```

Install a desktop assistant (e.g., SSP):
Download from http://ssp.shillest.net/

## Usage

Start the Observe-Orient process:

```bash
fluentd -c conf/observe_orient.conf
```

In another terminal, start the Decide-Act process:

```bash
fluentd -c conf/decide_act.conf
```

## Components

### Custom Fluentd Plugins

- **in_context**: Input plugin to read information from files
- **out_context**: Output plugin to process text with LLM and save results
- **filter_llm_generate**: Filter plugin to analyze text with LLM
- **out_sstp**: Output plugin to send desktop notifications via SSTP

### Dependencies

This project relies on the following gems:

- fluentd (~> 1.12)
- llmalfr
- fluent-plugin-llm-generate
- fluent-plugin-sstp

## Configuration

See the example configuration files in the `conf` directory:

- `observe_orient.conf`: Configuration for the first process (information collection and analysis)
- `decide_act.conf`: Configuration for the second process (prioritization and notification)

## License

Apache License, Version 2.0
