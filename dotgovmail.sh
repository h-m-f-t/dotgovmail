#!/bin/bash
# 'dotgovmail'

#Variables
url="https://raw.githubusercontent.com/GSA/data/gh-pages/dotgov-domains/current-federal.csv"  #or .gov-domains-api 
force="0"
agency=""


function dl()	#download .gov domains from 18F, sort by federal agency
{
	if hash wget 2>/dev/null; then
		wget --output-document=govlist --quiet "$url"
   	elif
        	hash curl 2>/dev/null; then
        	curl -silent -o govlist "$url"
    	else
    		echo "[*] ERROR: Please install either wget or cURL."
    		exit 1
    	fi
	echo -n "downloading .gov domains... "

	if [[ "$opt" = "a" ]]; then
		awk -F , '$3 ~ /'"$agency"'/{print $1}' govlist |sort > fedlist
		echo ""$(wc -l fedlist|sed -e 's/^[ \t]*//'|awk '{print $1}') domains registered to $OPTARG.""
	else
		awk -F , '$2 == "Federal Agency"' govlist | cut -d, -f1|sort > fedlist
		echo ""$(wc -l fedlist|sed -e 's/^[ \t]*//'|awk '{print $1}') domains registered to federal agencies.""
	fi
}

function mxcheck()	#show .gov domains with mx records
{
	if [[ -e mail ]] && [[ "$force" != "1" ]]; then
		if [[ -e $(find mail -mtime -1w) ]]; then
			echo ">> 'mail' is at $(pwd) and is ~newish (< 1 week old). To force a check anyway, use '-f' as the first option."
			exit 1
		fi

	else
		dl
		echo -n "checking for domains that send email... "
		spin &
		spin_pid=$!
		for dom in $(cat fedlist); do echo $dom;host -t mx $dom; done|grep "handled"|cut -d " " -f1|sort -u > mail
		comm -23 fedlist mail > nomail
		end_spin
		if [[ "$opt" != "a" ]]; then
			echo "[*] 'mail', 'nomail' saved to $(pwd)."
		fi
	fi
}

function spfcheck()   #-s using the output of mxcheck(), check for SPF records
{
	if [[ ! -e mail ]]; then
		mxcheck;spfcheck
	else

		echo -n "checking for mail-sending domains with & w/o SPF records..."
		spin &
		spin_pid=$!
		for dom in $(cat mail); do host -t txt $dom; done|grep "spf"|cut -d " " -f1|sort -u > mailspf
		comm -23 mail mailspf > mailnospf  #show all lines in mailspf but not in mail
		end_spin
		echo -n " ...and for non-mail-sending domains with & w/o SPF records..."
		spin &
		spin_pid=$!
		for dom in $(cat nomail); do host -t txt $dom; done|grep "spf"|cut -d " " -f1|sort -u > nomailspf
		comm -23 nomail nomailspf > nomailnospf
		end_spin
		if [[ "$opt" != "a" ]]; then
			echo "[*] 'mailspf', 'mailnospf', 'nomailspf', 'nomailnospf' saved to $(pwd)."
		fi
	fi
}

function dmarc()
{
	if [[ ! -e mail ]]; then
		mxcheck;dmarc
	else
		echo -n "checking for mail-sending domains with & w/o DMARC records..."
		spin &
		spin_pid=$!
		for dom in $(cat mail); do host -t txt _DMARC.$dom; done|grep "DMARC1"|cut -d " " -f1|cut -d "." -f2,3|sort -u > maildmarc
		comm -23 mail maildmarc > mailnodmarc
		end_spin
		echo -n " ...and for non-mail-sending domains with & w/o DMARC records..."
		spin &
		spin_pid=$!
		for dom in $(cat nomail); do host -t txt _DMARC.$dom; done|grep "DMARC1"|cut -d " " -f1|cut -d "." -f2,3|sort -u > nomaildmarc
		comm -23 nomail nomaildmarc > nomailnodmarc
		end_spin
		if [[ "$opt" != "a" ]]; then
			echo "[*] 'maildmarc', 'mailnodmarc', 'nomaildmarc', 'nomailnodmarc' saved to $(pwd)."
		fi
	fi
}

function cleanup()
{
		rm -f govlist fedlist
}

function spin()
{
    local i sp n
    sp='/-\|'
    n=${#sp}
    printf ' '
    while sleep 0.1; do
        printf "%s\b" "${sp:i++%n:1}"
    done
}

function end_spin()
{
	kill $spin_pid
	wait $spin_pid 2>/dev/null
	printf '\n'
}

function usage()
{
	echo "usage: ./dotgovmail <options> [<domain>]
 -a "{agency name}" will give a non-/mail-sending, non-/SPF, non-/DMARC breakdown by {agency}. (See all agencies available with -l.) Be sure to wrap {agency} in quotes. When running -a, all other options are run by default (i.e., there is no need to select -m, -s, or -d options with -a).

 -d will check for DMARC records at _dmarc.{domain}.gov for all mail-sending and non-mail sending domains.

 -f will force an update if the mail files are newer than 1 week. This must be the first option.

 -l will show all available federal agencies to select from.

 -s will check for SPF on all mail-sending and non-mail-sending domains.


dotgovmail is intended to operate over organizations, like the federal goverment as a whole or on all domains owned by the Department of the Interior. If you want to get similar results on just a single domain, run the following:

for mail:
$ host -t mx [domain]

for SPF:
$ host -t txt [domain]

for DMARC:
$ host -t txt _dmarc.[domain]"
}

function ag-list()
{
	echo "
AMTRAK
Administrative Conference of the United States
Advisory Council on Historic Preservation
African Development Foundation
American Battle Monuments Commission
Appalachian Regional Commission
Appraisal Subcommittee
Armed Forces Retirement Home
Central Intelligence Agency
Christopher Columbus Fellowship Foundation
Civil Air Patrol
Comm for People Who Are Blind/Severly Disabled
Commodity Futures Trading Commission
Congressional Office of Compliance
Consumer Financial Protection Bureau
Consumer Product Safety Commission
Corporation for National & Community Service
Council of Inspector General on Integrity and Efficiency
Court Services and Offender Supervision
Defense Nuclear Facilities Safety Board
Delta Regional Authority
Denali Commission
Department of Agriculture
Department of Commerce
Department of Defense
Department of Education
Department of Energy
Department of Health And Human Services
Department of Homeland Security
Department of Housing And Urban Development
Department of Justice
Department of Labor
Department of State
Department of Transportation
Department of Veterans Affairs
Department of the Interior
Department of the Treasury
Director of National Intelligence
Environmental Protection Agency
Equal Employment Opportunity Commission
Executive Office of the President
Export/Import Bank of the U.S.
Farm Credit Administration
Federal Communications Commission
Federal Deposit Insurance Corporation
Federal Elections Commission
Federal Energy Regulatory Commission
Federal Housing Finance Agency
Federal Housing Finance Agency Office of Inspector General
Federal Labor Relations Authority
Federal Maritime Commission
Federal Mediation and Conciliation Service
Federal Reserve System
Federal Retirement Thrift Investment Board
Federal Trade Commission
General Services Administration
Government Printing Office
Gulf Coast Ecosystem Restoration Council (GCERC)
Harry S. Truman Scholarship Foundation
Institute of Museum and Library Services
Inter-American Foundation
International Broadcasting Bureau
James Madison Memorial Fellowship Foundation
Legal Services Corporation
Library of Congress
Marine Mammal Commission
Medicaid and CHIP Payment and Access Commission
Medical Payment Advisory Commission
Merit Systems Protection Board
Millennium Challenge Corporation
Morris K. Udall Foundation
National Aeronautics and Space Administration
National Archives and Records Administration
National Capital Planning Commission
National Council on Disability
National Credit Union Administration
National Endowment for the Arts
National Endowment for the Humanities
National Gallery of Art
National Indian Gaming Commission
National Labor Relations Board
National Mediation Board
National Nanotechnology Coordination Office
National Science Foundation
National Security Agency
National Transportation Safety Board
Networking Information Technology Research and Development (NITRD)
Non-Federal Agency
Nuclear Regulatory Commission
Occupational Safety & Health Review Commission
Office of Government Ethics
Office of Personnel Management
Overseas Private Investment Corporation
Pension Benefit Guaranty Corporation
Postal Rate Commission
Railroad Retirement Board
Recovery Accountability and Transparency Board
Securities and Exchange Commission
Selective Service System
Small Business Administration
Smithsonian Institution
Social Security Administration
Social Security Advisory Board
Stennis Center for Public Service
Tennessee Valley Authority
Terrorist Screening Center
The Intelligence Community
The Judicial Branch (Courts)
The Legislative Branch (Congress)
The United States World War One Centennial Commission
U. S. Access Board
U. S. Holocaust Memorial Museum
U. S. International Trade Commission
U. S. Office of Special Counsel
U. S. Peace Corps
U. S. Postal Service
U.S. Agency for International Development
U.S. Capitol Police
U.S. Chemical Safety and Hazard Investigation Board
U.S. Commission of Fine Arts
U.S. Trade and Development Agency
US Interagency Council on Homelessness
United Stated Global Change Research Program
United States Office of Government Ethics"
}

##### Main
echo
if [[ $# < 1 ]]; then
	usage
else
	echo "Starting dotgovmail on $(date)"
	while getopts ":a:dflms" opt; do
		case "$opt" in
	  		a	)	agency=$OPTARG
					mkdir "$agency" 2>/dev/null;cd "$agency"
	  				mxcheck;spfcheck;dmarc
	  				echo "[*] 'mail*' and 'nomail*' files saved at $(pwd)."
					;;
			d 	)	dmarc
					;;
	  		f	)   force="1"
					;;
	  		l	)	ag-list|less >&2
					;;
	  		m	)	mxcheck
					;;
	  		s	)	spfcheck
	  				;;
			:	)	echo "-$OPTARG requires an argument." >&2
					exit 1
					;;
			\?	)	echo "invalid argument: -$OPTARG" >&2
					echo;usage
					exit 1
					;;
			*	)	usage
					exit 1
  		esac
	done
fi
cleanup
exit 0
