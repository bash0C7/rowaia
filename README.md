# Rowaia - AI-powered Assistant for Remote Office Workers

Rowaia is an AI agent system designed to help remote office workers automate information processing and decision-making using the OODA (Observe, Orient, Decide, Act) loop methodology.

## Concept

Rowaia automates the workflow of remote office workers by:

1. **Observe**: Collecting information from notes, files, and other data sources
2. **Orient**: Analyzing and summarizing collected information
3. **Decide**: Evaluating the situation and prioritizing tasks
4. **Act**: Providing notifications and guidance for action

## Architecture

Rowaia is built on Fluentd with custom plugins:

- **in_context**: Input plugin that reads files and directories
- **out_context**: Output plugin that summarizes data using LLM
- **filter_llm_generate**: Filter plugin that processes data with LLM for decision making
- **out_sstp**: Output plugin that sends notifications

## Requirements

- Ruby 2.6+
- Fluentd 1.12+
- [LLMAlfr](https://github.com/bash0C7/llmalfr) gem
- [fluent-plugin-llm-generate](https://github.com/bash0C7/fluent-plugin-llm-generate) gem
- Ollama with Japanese language model

## Installation

```bash
# Clone repository
git clone https://github.com/yourusername/rowaia.git
cd rowaia

# Install dependencies
bundle install

# Install Ollama and language model
# See https://ollama.ai for installation
ollama pull hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest

# Install plugins
gem build rowaia.gemspec
gem install rowaia-0.1.0.gem
```

## Configuration

### Observe & Orient Phase

```
<source>
  @type exec
  command cat /path/to/your/files/*
  format none
  tag observation
  run_interval 1800s  # 30 minutes
</source>

<match observation>
  @type context
  buffer_type memory
  buffer_path /tmp/fluentd/buffer
  output_path /tmp/fluentd/context
  flush_interval 1800s  # 30 minutes
</match>
```

### Decide & Act Phase

```
<source>
  @type context
  path /tmp/fluentd/context
  tag decision
  run_interval 1800s  # 30 minutes
</source>

<filter decision>
  @type llm_generate
  prompt_template I need to triage this information: <%= record["message"] %>. Categorize as 1:red, 2:yellow, 3:green, 4:black priority, and explain your reasoning.
</filter>

<match decision>
  @type sstp
  sstp_server 127.0.0.1
  sstp_port 9801
  sender Rowaia
  script_template \h\s[8]<%= record["llm_output"] %> \uThoughts?\e
</match>
```

## Usage

Start Fluentd with your configurations:

```bash
# Start Observe & Orient phase
fluentd -c conf/observe_orient.conf

# Start Decide & Act phase in another terminal
fluentd -c conf/decide_act.conf
```

## Customization

- Modify source paths in configuration to target your information sources
- Adjust prompt templates for different analysis needs
- Change notification format and target

## License

Apache-2.0