# Deployment (CI/CD)

FestNoz is deployed with [Kamal](https://kamal-deploy.org) (`config/deploy.yml`) on a
self-hosted server. The whole pipeline lives in `.github/workflows/`:

| Workflow | File | Trigger |
| --- | --- | --- |
| `CI` | `ci.yml` | every pull request, every push on `main` |
| `Deploy` | `deploy.yml` | automatically when `CI` succeeds on `main`, or manually |
| `Rollback` | `rollback.yml` | manually, with the version to go back to |

`CI` runs four jobs in parallel: Brakeman + bundler-audit, RuboCop, the Rails
test suite (Minitest on a PostgreSQL 17 service container) and the frontend
suite (Vitest). `Deploy` only starts once `CI` is green, so a red build never
reaches production.

## Why a self-hosted runner

The production server has a private address (`192.168.1.11`) and the container
registry Kamal pushes to listens on `localhost:5555`. Neither is reachable from
a GitHub-hosted runner, so `Deploy` and `Rollback` use `runs-on: self-hosted`.

The simplest — and recommended — setup is to install the runner **on the server
itself**: `localhost:5555` then resolves to the registry both when Kamal pushes
the image and when Docker pulls it.

If you install the runner on another machine of the LAN, you also have to:

1. set `registry.server` to `192.168.1.11:5555` in `config/deploy.yml`, and
2. declare that registry as insecure in `/etc/docker/daemon.json` on **both**
   machines (`{"insecure-registries": ["192.168.1.11:5555"]}`), then restart
   Docker.

## Installing the runner

On the server, as a user that belongs to the `docker` group:

```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
# Grab the latest release from
# https://github.com/winnieoursbrun/festnoz/settings/actions/runners/new
curl -o actions-runner-linux-x64.tar.gz -L <url shown by GitHub>
tar xzf actions-runner-linux-x64.tar.gz
./config.sh --url https://github.com/winnieoursbrun/festnoz --token <token shown by GitHub>
sudo ./svc.sh install
sudo ./svc.sh start
```

The runner needs: `docker` (with `buildx`), `git`, `ssh`, and the usual build
packages so that `ruby/setup-ruby` can install Ruby 3.4.8 (`build-essential`,
`libyaml-dev`, `libpq-dev`, `pkg-config`). The `Set up Kamal` step checks the
Docker/git/ssh prerequisites and fails with an explicit message if one is
missing.

The runner user must also be able to `ssh root@192.168.1.11` without a
passphrase — that is how Kamal drives the server. Either configure the key in
the runner user's `~/.ssh`, or provide it through the secrets below.

## Required secrets

Set them in **Settings → Secrets and variables → Actions**:

| Secret | Used by | Content |
| --- | --- | --- |
| `RAILS_MASTER_KEY` | CI (backend tests), Deploy, Rollback | contents of `config/master.key` |
| `POSTGRES_PASSWORD` | Deploy, Rollback | password of the `festnoz` PostgreSQL role (the one in `config/database_password.txt`) |
| `KAMAL_SSH_PRIVATE_KEY` | Deploy, Rollback | *optional* — private key allowed on the server. Leave unset to use the runner user's own SSH config. |
| `KAMAL_SSH_KNOWN_HOSTS` | Deploy, Rollback | *optional* — output of `ssh-keyscan 192.168.1.11` |

`RAILS_MASTER_KEY` is required by the backend test job too: Devise reads its JWT
secret from the encrypted credentials, so the suite cannot boot without it.

The `Set up Kamal` composite action (`.github/actions/kamal-setup`) recreates
`config/master.key` and `config/database_password.txt` from those secrets — the
two files `.kamal/secrets` reads. Both are git-ignored (so Kamal keeps tagging
images with the plain commit SHA) and both are deleted at the end of every run,
including when the job fails.

## Deploying

* **Automatic** — merge to `main`. `CI` runs, and on success `Deploy` builds the
  image on the runner and runs `kamal deploy` against the exact commit CI
  validated.
* **Manual** — Actions → *Deploy* → *Run workflow*, then pick a branch or tag.
  Tick *Release a stale Kamal deploy lock* if a previous run was cancelled and
  left the lock behind (equivalent to `kamal lock release`).

Deploy and Rollback share the `festnoz-production` concurrency group, so two
deploys can never run at the same time; a queued run waits instead of being
cancelled.

## Rolling back

Kamal tags every image with the commit SHA. Actions → *Rollback* → *Run
workflow*, and give the SHA of the release to return to. The workflow prints
`kamal app containers` first, which lists the versions still present on the
server.

From the server you can get the same list with:

```bash
bin/kamal app containers
```

## Troubleshooting

* **`Deploy` never starts after a merge** — `workflow_run` only fires for
  workflows living on the default branch. Merge the pipeline to `main` first;
  until then, use the manual trigger.
* **`Kamal::Cli::LockError`** — a previous run died holding the lock. Re-run the
  deploy with *force_unlock*, or run `bin/kamal lock release` on the server.
* **`connection refused` on `localhost:5555`** — the local registry is down;
  restart it on the server (`docker start <registry container>`).
* **Backend tests fail on `Missing encryption key`** — the `RAILS_MASTER_KEY`
  secret is absent or out of date.
