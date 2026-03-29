# Hermes Agent + ClawRouter Integration

Run Hermes Agent with **x402 USDC micropayments** and **smart model routing** via ClawRouter.

## What This Enables

| Feature | Benefit |
|---------|---------|
| **Smart Routing** | Automatically routes to cheapest capable model |
| **Token Compression** | 15-40% token reduction with 7-layer compression |
| **Response Caching** | ~200ms latency for repeated queries |
| **x402 Payments** | Pay only for what you use with USDC on Base |
| **No API Keys** | Authentication handled via wallet signatures |

## Quick Start

### 1. Start ClawRouter (in separate terminal)

```bash
npx @blockrun/clawrouter
```

This will:
- Start the proxy on `http://127.0.0.1:8402/v1`
- Generate/show your wallet address
- Show logs for routed requests

### 2. Fund Your Wallet (Optional)

Send USDC on **Base chain** to the wallet address shown on startup.

```bash
# Example: Fund with $10 USDC on Base
# Even with $0 balance, ClawRouter falls back to free tier (gpt-oss-120b)
```

### 3. Start Hermes Agent

```bash
# Option A: Use the startup script (starts ClawRouter automatically)
./start-with-clawrouter.sh

# Option B: Start ClawRouter manually, then Hermes
# Terminal 1:
npx @blockrun/clawrouter

# Terminal 2:
uv run hermes chat --model blockrun/auto
```

## Routing Profiles

| Profile | Description | Use Case |
|---------|-------------|----------|
| `blockrun/auto` | Balanced cost/quality | Default choice |
| `blockrun/eco` | Maximum savings | Simple tasks |
| `blockrun/premium` | Best quality | Complex reasoning |
| `blockrun/free` | Free tier only | Testing/no budget |

Switch profiles in conversation:
```
/model blockrun/eco
/model blockrun/premium
```

## Configuration Files

### `.env`
```bash
OPENAI_BASE_URL=http://127.0.0.1:8402/v1
LLM_MODEL=blockrun/auto
```

### `.config/cli-config.yaml`
```yaml
model:
  default: "blockrun/auto"
  base_url: "http://127.0.0.1:8402/v1"
```

## How It Works

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Hermes    │────▶│ ClawRouter   │────▶│  Best Model     │
│  Agent     │     │  :8402       │     │  for Request    │
└─────────────┘     └──────────────┘     └─────────────────┘
                          │
                          ├─► Analyze request (14 dimensions)
                          ├─► Compress tokens (7-layer)
                          ├─► Check cache
                          ├─► Select model
                          └─► x402 payment (USDC on Base)
```

## Debug Headers

Every response includes debug headers:

```
x-clawrouter-profile: auto
x-clawrouter-tier: MEDIUM
x-clawrouter-model: moonshot/kimi-k2.5
x-clawrouter-confidence: 0.87
x-clawrouter-savings: 73%
```

## Cost Comparison

| Provider | Monthly Spend | Tokens |
|----------|---------------|--------|
| Direct API | $100 | Full |
| ClawRouter | $22 | 15-40% compressed |
| **Savings** | **78%** | - |

## Troubleshooting

### ClawRouter not responding
```bash
# Check if proxy is running
curl http://127.0.0.1:8402/health

# Check logs
tail -f /tmp/clawrouter.log
```

### Wallet not funded
```bash
# ClawRouter falls back to free tier (gpt-oss-120b)
# Still works, just with slower models
```

### Connection refused
```bash
# Make sure ClawRouter is running first
npx @blockrun/clawrouter
```

## Links

- [ClawRouter Docs](https://blockrun.ai/clawrouter)
- [GitHub](https://github.com/BlockRunAI/ClawRouter)
- [x402 Protocol](https://github.com/x402-protocol)

## Supported Models

40+ models including:
- OpenAI: GPT-4.1, o3, o4
- Anthropic: Claude Opus, Sonnet, Haiku
- Google: Gemini 2.5 Pro, Flash
- DeepSeek: V3.2 Chat & Reasoner
- NVIDIA: GPT-OSS 120B (Free)

