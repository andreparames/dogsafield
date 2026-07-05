# Actual Budget CLI usage

## Setup

- **Config file:** `cli/.actualrc.json` (server URL, password, sync ID)
- **Working directory:** `cli/`
- **Executable:** `.\node_modules\.bin\actual.cmd` (NOT `npx actual`)

## PowerShell quoting

PowerShell strips double quotes from JSON arguments passed to Node.js.
**Always use `.cmd` + `--%`** when passing `--data`:

```
.\node_modules\.bin\actual.cmd --% <command> --data "{\"key\":\"value\"}"
```

Do NOT use:
- `npx actual ...` — same quoting problem
- single quotes `'...'` — quotes get stripped
- backtick escaping `{"key":"val"}` — also gets mangled

## Common commands

```powershell
# List budgets
.\node_modules\.bin\actual.cmd budgets list --format table

# List accounts
.\node_modules\.bin\actual.cmd accounts list --format table

# List categories (get IDs)
.\node_modules\.bin\actual.cmd categories list --format table

# Run AQL query
.\node_modules\.bin\actual.cmd query run --file "C:\path\to\query.json" --format table

# Update a transaction (USE THIS PATTERN)
.\node_modules\.bin\actual.cmd --% transactions update <id> --data "{\"category\":\"<category-id>\"}"

# Sync to server
.\node_modules\.bin\actual.cmd sync

# Download budget
.\node_modules\.bin\actual.cmd budgets download <syncId>

# Get budget month
.\node_modules\.bin\actual.cmd budgets month 2026-07 --format table

# List transactions
.\node_modules\.bin\actual.cmd --% transactions list --account <id> --start 2026-04-01 --end 2026-06-30 --format table
```

## Category IDs (for transaction updates)

| Category | ID |
|---|---|
| General | af375fd4-d759-46b3-bffe-74a856151d57 |
| Fees | e3fa30d9-f93a-41fa-ac31-462ed5d67a58 |
| Food (other) | 5835dc7f-5d6a-4372-8bbe-4f7f9e68b711 |
| Bills | d4b0f075-3343-4408-91ed-fae94f74e5bf |
| Restaurants | 82d26b75-0e68-48a5-bc50-525d0dd46411 |
| Eats | b97e170b-cb39-46cc-9262-5e237bff0480 |
| TVDE | d07fd895-ab09-4a63-8aac-67c75bbc452e |
| Taxes | f68262eb-eb52-4765-95c5-3006c809a059 |
| ATM | 1a0eb4ab-a658-49bb-ae8b-ec1b5769d206 |
| Gifts | d95633b9-ef49-4714-b8ba-965401cf38d1 |
| Shit | 30096038-1222-4017-8ada-ffc05cc2a942 |
| Investments | 747b1746-04e1-46c9-89a9-52297aac461d |
| Savings | 6bbd8472-25d4-4cee-8a11-5bd9f7e83d61 |

## Account IDs

| Account | ID |
|---|---|
| Conta a Ordem | 3271c3ab-6dea-472e-8432-c35cf7f5e506 |
| Cetelem Black | e9cc5be8-c31f-4d88-89a3-5a6487dcafdd |
| Wizink | 3f515613-69ed-4839-930f-085336eb02b3 |
| CC Activo | 158039be-fdc5-46c4-ad67-9758a089ac3a |
| Bankintercard | e31e1b02-ab42-4dfd-908c-ee9edc26e3b2 |
| Unibanco | 75757d5a-f184-4420-9af7-7bd9fda53b9a |
| Revolut | 94243a08-0aca-4f85-a31a-2c698f1baa15 |
| BIG | 376aaf33-079a-4fff-9915-6b58f43b3a72 |
| Openbank | a6441077-6c6d-4fcf-9807-4b8f61f00ce7 |
| Activo Gold | 79a00237-6da1-4ef0-94ca-561dac05d0ea |

## AQL queries

Write query JSON files and use `--file` to avoid quoting entirely:

```json
{
  "table": "transactions",
  "select": ["date", "amount", "category.name", "payee.name", "notes"],
  "filter": {
    "date": { "$gte": "2026-04-01", "$lte": "2026-06-30" },
    "is_parent": false
  },
  "order-by": "date:desc"
}
```

Then run: `.\node_modules\.bin\actual.cmd query run --file query.json --format table`

## Tips

- Credit card payments from checking to credit card accounts are **inter-account transfers** — leave category blank
- HIPAY charges on Cetelem are **Eats** (Uber Eats / Glovo food delivery, not fees/interest)
- Use `--format table` for human-readable, `--format csv` for export
