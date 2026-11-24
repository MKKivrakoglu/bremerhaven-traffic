# Queue runtime

`queue-lib.sh` implements the file-backed notification queue. Queue files and locks are created under `QUEUE_DIR`; logs are written under `LOG_DIR`. Both default to ignored paths under `var/` and can be set in `config/runtime.env`.

`sendmail.sh` runs the worker loop. Its current adapter, `mail/email.sh`, simulates delivery by writing a message under `SIM_MAIL_DIR`. It does not connect to an SMTP server. Generated messages and queue nodes are runtime data and are excluded from Git.
