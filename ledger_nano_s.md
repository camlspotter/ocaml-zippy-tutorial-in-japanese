# Ledger Nano S and my Mac

## OpenPGP app

In short: failed.

#### Details

`gpg --card-status` fails even if I followed the instruction of changing
`/usr/libexec/SmartCardServices/drivers/ifd-ccid.bundle/Contents/Info.plist`:

```shell
$ gpg --card-status
gpg: selecting openpgp failed: Operation not supported by device
gpg: OpenPGP card not available: Operation not supported by device
```

I guess I am hit by the issue here: https://github.com/LedgerHQ/ledger-app-openpgp-card/issues/18

## SSH/PGP agent

Instead, I have installed SSH/PGP app.

### SSH

In short: SSH public key generated.

#### Details

SSH key generation inside the device was no problem.  I just followed the instruciton here:
 
https://thoughts.t37.net/a-step-by-step-guide-to-securing-your-ssh-keys-with-the-ledger-nano-s-92e58c64a005

Note that there is no way to import an existing SSH private/public keys to the device.

### GPG

In short: GPG public key generated, but bit glitchy:

* Install `trezor-agent` and use `ledger-gpg` command.
* You may need to fix `/usr/local/lib/python3.7/site-packages/libagent/gpg/__init__.py`

#### Details

First, I installed `trezor-agent`:

```shell
$ brew install trezor-agent
```

Then, followed the instruction https://github.com/romanz/trezor-agent/blob/master/doc/README-GPG.md ,
but it failed:

```shell
$ ledger-gpg init "Jun FURUSE <jun.furuse@dailambdajp>" -v
...
gpg: Note: '--homedir' is not considered an option
gpg: error reading key: No secret key
Traceback (most recent call last):
  File "/usr/local/bin/ledger-gpg", line 11, in <module>
    sys.exit(gpg_tool())
  File "/usr/local/bin/ledger_agent.py", line 6, in <lambda>
    gpg_tool = lambda: libagent.gpg.main(DeviceType)
  File "/usr/local/lib/python3.7/site-packages/libagent/gpg/__init__.py", line 324, in main
    return args.func(device_type=device_type, args=args)
  File "/usr/local/lib/python3.7/site-packages/libagent/gpg/__init__.py", line 199, in run_init
    '--homedir', homedir]))
  File "/usr/local/lib/python3.7/site-packages/libagent/gpg/__init__.py", line 104, in check_call
    subprocess.check_call(args=args, stdin=stdin, env=env)
  File "/usr/local/Cellar/python/3.7.0/Frameworks/Python.framework/Versions/3.7/lib/python3.7/subprocess.py", line 328, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/usr/local/Cellar/gnupg/2.2.10/bin/gpg', '--list-secret-keys', 'Jun FURUSE <jun.furuse@dailambda.jp>', '--homedir', '/Users/jun/.gnupg/ledger']' returned non-zero exit status 2.
```

You can confirm the failure by typing the command by yourself:

```
$ /usr/local/Cellar/gnupg/2.2.10/bin/gpg --list-secret-keys 'Jun FURUSE <jun.furuse@dailambda.jp>' --homedir /Users/jun/.gnupg/ledger
gpg: Note: '--homedir' is not considered an option
gpg: error reading key: No secret key
```

If you flip the options, it works:

```
$ /usr/local/Cellar/gnupg/2.2.10/bin/gpg  --homedir /Users/jun/.gnupg/ledger --list-secret-keys 'Jun FURUSE <jun.furuse@dailambda.jp>'

sec   nistp256 2018-10-03 [SC]
      XXXX....
uid           [ultimate] Jun FURUSE <jun.furuse@dailambda.jp>
ssb   nistp256 2018-10-03 [E]
```

So, I fixed these option ordering in `/usr/local/lib/python3.7/site-packages/libagent/gpg/__init__.py`: 

```
*** ./python3.7/site-packages/libagent/gpg/__init__.py~	Wed Oct  3 06:06:33 2018
--- ./python3.7/site-packages/libagent/gpg/__init__.py	Wed Oct  3 06:18:45 2018
***************
*** 195,202 ****
                                      '--import-ownertrust', f.name]))
  
      # Load agent and make sure it responds with the new identity
!     check_call(keyring.gpg_command(['--list-secret-keys', args.user_id,
!                                     '--homedir', homedir]))
  
  
  def run_unlock(device_type, args):
--- 195,205 ----
                                      '--import-ownertrust', f.name]))
  
      # Load agent and make sure it responds with the new identity
! #JUN    check_call(keyring.gpg_command(['--list-secret-keys', args.user_id,
! #JUN                                    '--homedir', homedir]))
!     check_call(keyring.gpg_command(['--homedir', homedir,
!                                     '--list-secret-keys', args.user_id
!                                     ]))
  
  
  def run_unlock(device_type, args):
```

Rerun `ledger-gpg init ..`:

```shell
$ ledger-gpg init "Jun FURUSE <jun.furuse@dailambdajp>" -v
...
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
sec   nistp256 2018-10-03 [SC]
      XXXXX...
uid           [ultimate] Jun FURUSE <jun.furuse@dailambda.jp>
ssb   nistp256 2018-10-03 [E]
```

Now you have your GPG public key at `~/.gnupg/ledger/pubkey.asc`.  You can copy-and-paste it to gitlab.

Set `GNUPGHOME` in your bashrc (or equivalent):

```shell
export GNUPGHOME=~/.gnupg/ledger
```

With this env var setting, you test signing and verification:

```shell
$ echo 123 | gpg --sign | gpg --verify
gpg: using "Jun FURUSE <jun.furuse@dailambda.jp>" as default secret key for signing
gpg: Signature made Wed Oct  3 16:48:23 2018 CEST
gpg:                using ECDSA key xXXXX....
gpg:                issuer "jun.furuse@dailambda.jp"
gpg: Good signature from "Jun FURUSE <jun.furuse@dailambda.jp>" [ultimate]
```
