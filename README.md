# dotgovmail
Show MX, SPF, and DMARC records for US federal agency domains.


```usage: ./dotgovmail <options> [<domain>]```

 -m will check federal agency 2nd-level domains for mail-sending.
 
 -s will check for SPF on mail-sending and non-mail-sending domains.
 
 -d will check for DMARC records at _dmarc.{domain}.gov.
 
 -a "{agency name}" will give a non-/mail-sending, non-/SPF, non-/DMARC breakdown by {agency}. (See all agencies available with -l.) Be sure to wrap {agency} in quotes.
 
 -f will force an update if the mail files are newer than 1 week. This must be the first option.

dotgovmail is intended to operate over organizations, like the federal goverment as a whole or on, say, the Appalachian Regional Commission. If you want to get similar results on just a single domain, run the following:

for mail:
```$ host -t mx [domain]```

for SPF:
```$ host -t txt [domain]```

for DMARC:
```$ host -t txt _dmarc.[domain]```
