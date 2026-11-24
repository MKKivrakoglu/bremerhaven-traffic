# Bremerhaven Traffic

Recovered shell CGI and web application for displaying vessel traffic near Bremerhaven. The original deployment was split across a Linux server's `www`, `cgi-bin`, cron, data, and private queue directories. This repository brings the source together and keeps machine-specific settings and generated runtime data out of Git.

## Repository layout

- `www/` contains the recovered static site and the WaterTraffic application.
- `cgi-bin/` contains Bash CGI endpoints for login, sessions, and vessel data.
- `data/` contains the AIS input script used by the watcher.
- `cronjobs/` contains the data watcher and cleanup jobs.
- `queue/` contains the asynchronous notification queue and its simulated mail adapter.
- `config/` contains safe examples. Real settings belong in ignored local files.
- `scripts/runtime.sh` resolves project paths and loads local runtime settings.
- `var/` is created on the server for queue state, logs, and simulated mail.

The files under `www/experiments/` and `www/archive/` are recovered web snapshots. The original archives and full server snapshot remain in the parent workspace and are intentionally not part of this repository.

## Local server setup

1. Copy `config/runtime.env.example` to `config/runtime.env` and set the server-specific paths.
2. Copy `config/mariadb.cnf.example` to `config/mariadb.cnf`, then set a database user and password locally. Keep the file readable only by the account that runs the CGI and data jobs.
3. Create the configured queue, log, state, and session directories with permissions for the relevant server accounts.
4. Configure the web server to serve `www/` and execute the scripts in `cgi-bin/` as CGI. Install Bash, the MariaDB client, `ncat`, and `pwgen` where required.
5. Copy `cronjobs/cronjob.example` to the server's crontab after replacing the project path and reviewing each schedule.

The scripts accept environment overrides such as `DB_DEFAULTS_FILE`, `QUEUE_DIR`, `LOG_DIR`, `STATE_DIR`, and `SESSION_DIR`. `config/runtime.env` provides the same settings to cron and CGI processes when the server does not pass them through.

## Recovered behavior and limits

The notification adapter in `queue/mail/email.sh` writes messages to a local simulation directory; it does not send mail. The recovered CGI login is a legacy prototype and should be reviewed and hardened before being exposed to the public internet. The cleanup job deletes database rows older than eight days; review its retention period before enabling it.

Logs, queued messages, local credentials, server snapshots, coursework, and the previous Git history are kept out of this public repository. They remain in the local recovery material.
