# dotgovmail
Show MX, SPF, and DMARC records for US federal agency domains.


```usage: ./dotgovmail <options> [<agency>]```

-a "{agency name}" will give a non-/mail-sending, no-/SPF, no-/DMARC breakdown by {agency}. (See all agencies available with -l.) Be sure to wrap {agency} in quotes. When running -a, all other options are run by default (i.e., there is no need to select -m, -s, or -d options with -a).

-d will check for DMARC records at _dmarc.{domain}.gov for all mail-sending and non-mail sending domains.

-f will force an update if the mail files are newer than 1 week. This must be the first option.

-l will show all available federal agencies to select from.

-m will check all federal agency 2nd-level domains for mail-sending.
 
-s will check for SPF on all mail-sending and non-mail-sending domains.
 
**dotgovmail** is intended to operate over organizations, like the federal goverment as a whole or on all domains owned by the Department of the Interior. If you want to get similar results on just a single domain, run the following:

for mail:
```$ host -t mx [domain]```

for SPF:
```$ host -t txt [domain]```

for DMARC:
```$ host -t txt _dmarc.[domain]```
